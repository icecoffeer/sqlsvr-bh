SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_IUS_INV](
  @p_subwrh int,
  @p_gdgid int,
  @err_msg varchar(200) = '' output
) as
begin
  insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE,
    WRH, QTY, ADJFLAG, BILLCOST, A_ADJCOST)
    select @@spid, '库存', '', '', '',
    WRH, sum(QTY), '000', sum(COST), 0
    from SUBWRHINV
    where GDGID = @p_gdgid and SUBWRH = @p_subwrh
    group by WRH, SUBWRH
    
  return(0)
end
GO
