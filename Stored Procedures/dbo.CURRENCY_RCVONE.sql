SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CURRENCY_RCVONE](
  @Src int, --来源单位
  @ID int,
  @Msg varchar(255) output
)
as
begin
  declare
    @Code varchar(20),
    @Rcv int,
    @UserGid int

  ---总部不能接收
  If Exists(Select 1 from SYSTEM where ZBGID = USERGID)
  begin
    set @Msg = '总部不能接收零售付款方式资料'
    return(1)
  end

  --非本单位的零售付款方式资料
  select @UserGid = UserGid from FASystem(nolock)
  select @Rcv = Rcv from NCURRENCY(nolock) where Src = @Src and ID = @ID
  if @Rcv <> @UserGid
  begin
    set @Msg = '非接收单位不能接收零售付款方式资料'
    return(1)
  end

  select @Code = Code from NCURRENCY(nolock)
  where Src = @Src and ID = @ID

  ---接收
  delete from CURRENCY where Code = @Code

  insert into CURRENCY(CODE, NAME, FAVRATE, CASHIER, CHANGE, ByDevice,
     SndtoFg, FAVRPTRATE, FAVRPTRATEDENO, HighLmtDis, PayByCash, BEGINDATE, ENDDATE, DisUseAcnt, IsInSumTotal)
  select CODE, NAME, FAVRATE, CASHIER, CHANGE, ByDevice,
     SndtoFg, FAVRPTRATE, FAVRPTRATEDENO, HighLmtDis, PayByCash, BEGINDATE, ENDDATE, DisUseAcnt, IsInSumTotal
  from NCURRENCY(nolock)
  where Src = @Src and ID = @ID

  delete from NCURRENCY where Src = @Src and ID = @ID

  return(0)
end
GO
