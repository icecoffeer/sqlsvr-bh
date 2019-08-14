SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTCHK](
  @cls char(10),
  @num char(10),
  @ckinv smallint = 0,
    /* 0: 库存不足不能继续
       1: 库存不足生成缺货列表
       2: 库存不足生成配货单
       3: 库存不足生成缺货列表和配货单
       4: 库存不足回写配货池		 --Added by Jianweicheng 回写配货池 2003.01.03
       5：库存不足生成缺货列表同时回写配货池
       6：库存不足生成配货单同时回写配货池
       7：库存不足生成缺货列表和配货单同时回写配货池
       库存不足指不允许负库存的仓位 */
  @avalt float = 0,
    /* 可忽略缺货比 */
  @bvalt float = 0,
    /* 完全缺货比 */
  /* 2000-4-10 */
  @ckord smallint = 0,
    /* 0: 不处理
       1: 出货数<定单未配数时生成新的出货单 */
  @VStat smallint = 1,
  @outnum char(10) = null output,
    /* ckinv.bit1 = 1 or ckord = 1 时生成的单号,备注=缺货待配 */
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) as
begin
  declare
    @return_status int,    @bstat smallint, @optvalue_Chk int, @poMsg varchar(255)
  exec OPTREADINT 65, 'ChkStatDwFunds', 0, @optvalue_Chk output
  if @cls <> '批发'
    set @optvalue_chk = 0
  if @optvalue_Chk = 0
  begin
    if (@VStat <> 1) and (@VStat <> 7)
      raiserror('复核选项未开启，传入VSTAT参数错误',16,1)
  end
  select @bstat = stat from stkout where num like @num and cls like @cls
  if @VStat = 7  --预审
  begin
    exec @return_status = STKOUTCHK_PRECHK
      @CLS = @cls, @NUM = @num, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
    if @return_status <> 0 raiserror(@poMsg,16,1)
  end
  else if @VStat = 1
  begin
    if @bStat in (0, 7)
    begin
      exec @return_status = STKOUTCHK_RSVALC  --待配
        @CLS = @cls,  @NUM = @num,  @CKINV = @CKINV,  @AVALT = @AVALT,
        @BVALT = @BVALT,  @CKORD = @CKORD, @VStat = 15, @outnum = @OUTNUM OUTPUT, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
      if @return_status <> 0 raiserror(@poMsg,16,1)
    end
    exec @return_status = STKOUTCHKex  --审核
      @CLS = @cls,  @NUM = @num,  @CKINV = @CKINV,  @AVALT = @AVALT,
      @BVALT = @BVALT,  @CKORD = @CKORD, @VStat = 1, @outnum = @OUTNUM OUTPUT, @ChkFlag = @ChkFlag, @Msg = @poMsg OUTPUT
    if @bStat in (0, 7) begin if @return_status < 0 return 0 end
    else if @return_status <> 0 raiserror(@poMsg,16,1)

  end
  else if @VStat = 6
  begin
    if @bStat in (0, 7)
    begin
      exec @return_status = STKOUTCHK_RSVALC  --待配
        @CLS = @cls,  @NUM = @num,  @CKINV = @CKINV,  @AVALT = @AVALT,
        @BVALT = @BVALT,  @CKORD = @CKORD,  @VStat = 15, @outnum = @OUTNUM OUTPUT, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
      if @return_status <> 0 raiserror(@poMsg,16,1)

      exec @return_status = STKOUTCHKex  --审核
        @CLS = @cls,  @NUM = @num,  @CKINV = @CKINV,  @AVALT = @AVALT,
        @BVALT = @BVALT,  @CKORD = @CKORD,  @VStat = 1, @outnum = @OUTNUM OUTPUT, @ChkFlag = @ChkFlag, @Msg = @poMsg OUTPUT
      if @return_status > 0 raiserror(@poMsg,16,1)
      if @return_status < 0 return 0
    end
    exec @return_status = STKOUTCHKChkex  --复核
      @CLS = @cls,  @NUM = @num, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
    if @bStat in (0, 7) begin if @return_status < 0 return 0 end
    else if @return_status <> 0 raiserror(@poMsg,16,1)
  end else
  begin
    set @return_status = 1
    raiserror('未知的VSTAT参数值。', 16,1)
  end

  return @return_status
end
GO
