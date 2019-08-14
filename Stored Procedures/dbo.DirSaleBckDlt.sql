SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirSaleBckDlt]
  @cls char(10), @num char(10), @new_oper int
with encryption as
begin
  declare @return_status int, @errmsg varchar(200) /* 2000-8-13 */,@OptionValue_RCPCST CHAR(1)
  execute @return_status = DirDlt @cls, @num, @new_oper, @errmsg output
  /* 2000-8-13 */
  if @return_status <> 0
    raiserror(@errmsg, 16, 1)
    IF @CLS = '直销退'  -- add by cyb 2002.08.31
    begin
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		delete from CSTBILL WHERE OUTNUM = @num AND CLS = @CLS
	  end
    end

  return @return_status
end
GO
