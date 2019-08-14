SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirUpd]
  @cls char(10),
  @num char(10),
  @errmsg varchar(200) = '' output          /* 2000-8-13 */
with encryption as
begin
  declare
    @m_modnum char(10),   @m_oper int,     @m_stat smallint,
    @max_num char(10),    @neg_num char(10),
    @mode smallint,       @return_status int,      @conflict smallint,
    @OptionValue_RCPCST CHAR(1)
  declare @RistrictCurDayOpt int, @m_FILDATE DATETIME --CHAR(10) CLASS
  select @m_FILDATE = CONVERT(DATETIME,CONVERT(CHAR(10),fildate,102) )
  from diralc where CLS = @cls
  	and NUM = (select MODNUM from diralc where CLS = @cls and NUM = @num)  --Fanduoyi 1717
  exec optreadint 0, '禁止进货单和进货退货单隔天冲单修正', 0, @RistrictCurDayOpt output
  if @RistrictCurDayOpt = 1
    if @m_FILDATE < CONVERT(DATETIME,CONVERT(CHAR(10),GETDATE(),102) )
    BEGIN
      raiserror('禁止进货单和进货退货单隔天冲单修正！[同名选项]', 16, 1)
      SET @errmsg = '禁止进货单和进货退货单隔天冲单修正！[同名选项]'
      return -1
    end

/* 修正直配单时，@m_stat应该由被修正单中取，修正如下 */
  select
    @m_modnum = MODNUM,    @m_oper = CHECKER
  from DIRALC where CLS = @cls and NUM = @num
  select @m_stat = STAT from DIRALC where CLS = @cls and NUM = @m_modnum

  if @m_stat = 1 select @mode = 0
  if @m_stat = 6 select @mode = 2

  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from DIRALC where CLS = @cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  -- 2002-06-14
  if @cls = '直配进'
  begin
    execute @return_status = DLTDECORDQTY 'DIRALC', @cls, @m_modnum

    update DIRALC set STAT = 0 where CLS = @cls and NUM = @num
    execute @return_status = DirChk @cls, @num, @mode, 0
    if @return_status <> 0 return @return_status

    execute @return_status = DirDltNum @cls, @m_modnum, @m_oper, @neg_num, @errmsg output /* 2000-8-13 */
    if @return_status <> 0 return @return_status
    update DIRALC set STAT = 3 where CLS = @cls and NUM = @neg_num

  end
  else
  begin

    execute @return_status = DirDltNum @cls, @m_modnum, @m_oper, @neg_num, @errmsg output /* 2000-8-13 */
    IF @CLS = '直销' or @cls = '直销退'   -- add by cyb 2002.08.31
    begin
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		delete from CSTBILL WHERE OUTNUM = @m_modnum AND CLS = @CLS
	  end
    end

    if @return_status <> 0 return @return_status
    update DIRALC set STAT = 3 where CLS = @cls and NUM = @neg_num

    update DIRALC set STAT = 0 where CLS = @cls and NUM = @num
    execute @return_status = DirChk @cls, @num, @mode, 0
    if @return_status <> 0 return @return_status
/* add by cyb 2002.07.31*/
    if @cls = '直销' or @cls = '直销退'
    begin
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		insert into CSTBILL (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPTOTAL,OTOTAL)
			SELECT SETTLENO,FILDATE,CLS,RECEIVER,NUM,ALCTOTAL,0,ALCTOTAL
			    FROM DIRALC
                            WHERE NUM = @num
				AND CLS = @CLS
				AND ALCTOTAL <>0
				and paymode = '应收款'
				and RECEIVER not in (select gid from store)
	  end
    end

  end

  /* 2000-1-25: 单据附件 */
  update BILLAPDX set NUM = @num
  where BILL = 'DIRALC' and CLS = @cls and NUM = @m_modnum

  /* 2000-8-17 */
  if @cls not in ('直销','直销退') /*2002-01-17*/
    UPDATE DIRALCDTL SET RCPQTY=0, RCPAMT=0, PAYQTY=0, PAYAMT=0 WHERE CLS=@CLS AND NUM=@NUM
  else
    UPDATE DIRALCDTL SET PAYQTY=0, PAYAMT=0 WHERE CLS=@CLS AND NUM=@NUM

  return @return_status
end
GO
