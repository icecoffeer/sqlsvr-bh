SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINUPD]
  @cls char(10),
  @new_num char(10),
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200)='' output
as
begin
  declare
    @return_status int,
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    @new_stat smallint,
    @new_oper int,
    @old_num char(10),
    @old_stat smallint,
    @mode smallint,
    @old_mst_wrh int, @old_mst_ordnum char(10),
    @old_dtl_wrh int, @gdgid int, @qty money, @wrh int

 --ShenMin
  declare
    @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  select @old_num = MODNUM,@wrh = wrh from STKIN where CLS = @cls and NUM = @new_num
  exec @return_status = WMSFILTER 'STKIN', @piCls = @cls, @piNum = @old_num, @piToStat = 2, @piOper = @Oper,@piWrh = @wrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return -1
    end

  declare @RistrictCurDayOpt int, @m_FILDATE DATETIME --CHAR(10) CLASS

  select @m_FILDATE = CONVERT(DATETIME,CONVERT(CHAR(10),fildate,102) )  --DIRALC审核时间
  from STKIN where CLS = @cls
  	and NUM = (select MODNUM from STKIN where CLS = @cls and NUM = @new_num)  --Fanduoyi 1717

  exec optreadint 0, '禁止进货单和进货退货单隔天冲单修正', 0, @RistrictCurDayOpt output
  if @RistrictCurDayOpt = 1
    if @m_FILDATE < CONVERT(DATETIME,CONVERT(CHAR(10),GETDATE(),102) )
    BEGIN
      raiserror('禁止进货单和进货退货单隔天冲单修正！[同名选项]', 16, 1)
      SET @errmsg = '禁止进货单和进货退货单隔天冲单修正！[同名选项]'
      return -1
    END

  select
    @return_status = 0

  select
    @new_stat = STAT,
    @old_num = MODNUM,
    @new_oper = FILLER
    from STKIN where CLS = @cls and NUM = @new_num
  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据.', 16, 1)
    return(1)
  end

  select
    @old_stat = STAT
    from STKIN where CLS = @cls and NUM = @old_num
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

  /*
    2000-9-14 在单量处理:
    在这里先加库存在单量,
    然后StkinChk减库存在单量,
    在StkinDltNum时@incordqty=0不再增加库存在单量
  */
  execute @return_status = DLTDECORDQTY 'STKIN', @cls, @old_num
  if @return_status <> 0 return(@return_status)

  select @old_mst_wrh = null,
         @old_mst_ordnum = null
  select @old_mst_wrh = wrh,
         @old_mst_ordnum = ordnum
    from stkin
    where cls=@cls and num=@old_num
  if @old_stat = 1 select @mode = 0
  else select @mode = 2
  execute @return_status = STKINCHK @cls, @new_num, @mode
  if @return_status <> 0 return @return_status

  /* find the @neg_num */
  select @conflict = 1, @max_num = @new_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from STKIN where CLS = @cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  execute @return_status = STKINDLTNUM @cls, @old_num, @new_oper, @neg_num, /*2000-9-14*/@errmsg output, 0
  update STKIN set STAT = 2 where CLS = @cls and NUM = @old_num
  update STKIN set STAT = 3 where CLS = @cls and NUM = @neg_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  /* 2000-1-25: 单据附件 */
  update BILLAPDX set NUM = @new_num
  where BILL = 'STKIN' and CLS = @cls and NUM = @old_num

  /* 2000-08-17 保证PAYQTY=0*/
  UPDATE STKINDTL SET PAYQTY=0, PAYAMT=0 WHERE CLS=@CLS AND NUM=@NEW_NUM

  return @return_status
end
GO
