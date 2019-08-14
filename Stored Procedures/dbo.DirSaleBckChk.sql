SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirSaleBckChk]
  @cls char(10), @num char(10), @mode smallint
with encryption as
begin
  declare @return_status int, @errmsg varchar(200) /* 2000-8-13 */,@OptionValue_RCPCST CHAR(1)
  execute @return_status = DirChk @cls, @num, @mode, 0, @errmsg output
  /* 2000-8-13 */
  if @return_status <> 0
    raiserror(@errmsg, 16, 1)
  --客户帐期控制 add by cyb 2002.08.01
  if @cls = '直销退'
  begin
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		delete from cstbill where outnum = @num and cls = @cls
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

  return @return_status
end
GO
