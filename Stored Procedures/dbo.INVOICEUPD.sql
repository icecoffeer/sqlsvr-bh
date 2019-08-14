SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[INVOICEUPD]
(
  @new_num char(14),
  @ToStat int,
  @Oper Varchar(30),
  @errmsg varchar(200)='' output
) as
begin
  declare
    @return_status int,
    @new_stat smallint,
    @old_num char(14),
    @old_stat smallint

  select @old_num = MODNUM from INVOICE(nolock) where NUM = @new_num

  select
    @return_status = 0

  select
    @old_stat = STAT
    from INVOICE where NUM = @old_num
  if @old_stat <> 100 and @old_stat <> 600
    begin
      set @errmsg = '被修正的不是已审核或已复核的单据.';
      return(1)
    end

  execute @return_status = INVOICECHK @NUM = @new_num, @TOSTAT = @old_stat, @OPER = @Oper, @MSG = @errmsg output;
  if @return_status <> 0
    begin
    	return @return_status;
    	set @errmsg = '审核修正单出错' + @errmsg;
    end;
  select @old_stat = @old_stat + 34;
  execute @return_status = INVOICECHK @NUM = @old_num, @TOSTAT = @old_stat, @OPER = @Oper, @MSG = @errmsg output;
  if @return_status <> 0
    begin
    	return @return_status;
    	set @errmsg = '修改被修正单据状态出错' + @errmsg;
    end;
  return @return_status
end
GO
