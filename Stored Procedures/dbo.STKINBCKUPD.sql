SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINBCKUPD](
  @cls char(10),
  @new_num char(10),
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200) = '' output /* 2000-11-02 */
) with encryption as
begin
  declare
    @return_status int,
    @max_num char(10),
    @neg_num char(10),
    @old_num char(10),
    @conflict smallint,
    @mode smallint,
    @new_oper int,
    @old_stat smallint,
    @new_stat smallint

 --ShenMin
  declare
    @Oper char(30),@wrh int,
    @OldNum char(10)
  set @Oper = Convert(Char(1), @ChkFlag)
  select @OldNum = MODNUM,@wrh = wrh from STKINbck where CLS = @cls and NUM = @new_num
  exec @return_status = WMSFILTER 'STKINBCK', @piCls = @Cls, @piNum = @OldNum, @piToStat = 2, @piOper = @Oper,@piWrh = @wrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return -1
    end

  select
    @return_status = 0

  declare @RistrictCurDayOpt int, @m_FILDATE DATETIME --CHAR(10) CLASS

  select @m_FILDATE = CONVERT(DATETIME,CONVERT(CHAR(10),fildate,102) )
  from STKINbck where CLS = @cls
  	and NUM = (select MODNUM from STKINbck where CLS = @cls and NUM = @new_num)  --Fanduoyi 1717

  exec optreadint 0, '禁止进货单和进货退货单隔天冲单修正', 0, @RistrictCurDayOpt output
  if @RistrictCurDayOpt = 1
    if @m_FILDATE < CONVERT(DATETIME,CONVERT(CHAR(10),GETDATE(),102) )
    BEGIN
      raiserror('禁止进货单和进货退货单隔天冲单修正！[同名选项]', 16, 1)
      SET @errmsg = '禁止进货单和进货退货单隔天冲单修正！[同名选项]'
      return -1
    END

  /* check $ update the new bill */
  select
    @new_stat = STAT,
    @old_num = MODNUM,
    @new_oper = FILLER
    from STKINBCK where CLS = @cls and NUM = @new_num
  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据.', 16, 1)
    return(1)
  end

  /* check & update the old bill */
  select
    @old_stat = STAT
    from STKINBCK where CLS = @cls and NUM = @old_num
  if @old_stat <> 1 and @old_stat <> 6 begin
    raiserror('被修改的不是已审核或已复核的单据.', 16, 1)
    return(1)
  end

  /* 2000-11-02 */
  if @old_stat=6 and (select payflag from system)=1
  begin
    select @errmsg = '已复核的单据不能修正'
    raiserror(@errmsg, 16, 1)
    return(1)
  end

  /* find the @neg_num */
  select @conflict = 1, @max_num = @new_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from STKINBCK where CLS = @cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end
  execute @return_status = STKINBCKDLTNUM @cls, @old_num, @new_oper, @neg_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  update STKINBCK set STAT = 2 where CLS = @cls and NUM = @old_num
  update STKINBCK set STAT = 3 where CLS = @cls and NUM = @neg_num

  if @old_stat = 1 select @mode = 0
  else select @mode = 2
  execute @return_status = STKINBCKCHK @cls, @new_num, @mode

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  /* 2000-1-25: 单据附件 */
  update BILLAPDX set NUM = @new_num
  where BILL = 'STKINBCK' and CLS = @cls and NUM = @old_num

  /* 2000-08-17 */
  UPDATE STKINBCKDTL SET PAYQTY=0, PAYAMT=0 WHERE CLS=@CLS AND NUM=@NEW_NUM

  return @return_status
end
GO
