SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[FETCHBILLADJCOST](
  @pi_bill char(10),
  @pi_cls char(10),
  @pi_num char(10),
  @pi_line smallint,
  @pi_subwrh int,
  @pi_adjflag char(3),
  @usergid int,
  @po_adjcost money output,
  @err_msg varchar(200) = '' output
) as
begin
  select @po_adjcost = case 
    when substring(@pi_adjflag, 1, 1) = '1' then isnull(sum(ADJINCOST), 0)
    when substring(@pi_adjflag, 2, 1) = '1' then isnull(sum(ADJOUTCOST), 0)
    when substring(@pi_adjflag, 3, 1) = '1' then isnull(sum(ADJALCAMT), 0)
    else 0 end
    from IPA2DTL
    where STORE = @usergid and BILL = @pi_bill and BILLCLS = @pi_cls
    and BILLNUM = @pi_num and BILLLINE = @pi_line and SUBWRH = @pi_subwrh
    and LACTIME is not null
  return(0)
end
GO
