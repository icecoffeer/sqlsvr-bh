SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CURRENCY_SENDALL]
(
  @piRcvGid integer, --接收门店
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vSrc int,
    @vID int,
    @vCode varchar(15)

  ---控制非总部不能发送
  select @vSrc = UserGid from FASystem(nolock) where UserGid = ZBGid
  if @@ROWCOUNT = 0
  begin
    set @poErrMsg = '非总部不能发送零售付款方式资料'
    return(1)
  end

  delete from NCURRENCY where Src = @vSrc and Rcv = @piRcvGid

  declare curNCURRENCY cursor for
    select Code
    from CURRENCY(nolock)

  open curNCURRENCY
  fetch next from curNCURRENCY into @vCode
  while @@fetch_status = 0
  begin
    ---取得ID号
    execute GetNetBillId @vID output
    
    ---零售付款方式资料
    insert into NCURRENCY(SRC, ID, RCV, RCVTIME, TYPE, NSTAT, NNOTE,
    CODE, NAME, FAVRATE, CASHIER, CHANGE, ByDevice, SndtoFg, FAVRPTRATE, FAVRPTRATEDENO, HighLmtDis, PayByCash, BEGINDATE, ENDDATE, DisUseAcnt, IsInSumTotal)
    select @vSrc, @vID, @piRcvGid, null, 0, 0, '', CODE, NAME, FAVRATE,
      CASHIER, CHANGE, ByDevice, SndtoFg, FAVRPTRATE,
      FAVRPTRATEDENO, HighLmtDis, PayByCash, BEGINDATE, ENDDATE, DisUseAcnt, IsInSumTotal
    from CURRENCY(nolock)
    where Code = @vCode;

    --支持DTS
    exec LOGNETOBJSEQ 1009, @vSrc,  @vID, @piRcvGid, 1

    fetch next from curNCURRENCY into @vCode
  end
  close curNCURRENCY
  deallocate curNCURRENCY
    
  return(0)
end
GO
