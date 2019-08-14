SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_NET_SEND_ONESTORE]
  (
  @piSN     varchar(32),
  @piRcv    int,
  @piOper   int,
  @poErrMsg varchar(255) output
  )
  as
  begin
    set nocount on;
    declare @vNID   int;
    declare @vUID   int;
    declare @vZID   int;
    declare @vItem  int;
    select @vUID = USERGID, @vZID = ZBGID
      from SYSTEM;
    if @@rowcount = 0
    begin
      set @poErrMsg = '门店信息访问出错!';
      return(1);
    end;

    exec GETNETBILLID @vNID output
    insert into NSPVOUCHER([ID], SRC, SN, STAT, PHASE, FILDATE, SALEAMT, ENSN,
                                BESOPER, BESSRC, HANDOPER, HANDSRC, SNDTIME,
                                RCV , RCVTIME , FRCCHK , NTYPE , NSTAT , NNOTE, HANDTIME)
        select @vNID, @vUID, @piSN, STAT, PHASE, FILDATE, SALEAMT, ENSN,
               BESOPER, BESSRC, HANDOPER, HANDSRC, getdate(),
               @piRcv, null, 1, 0, 0, null, HANDTIME
          from SPVOUCHER
          where SN = @piSN;

    select @vItem = isnull(max(ITEMNO), 0) + 1
      from SPVOUCHERLOG (nolock)
      where SN = @piSN;
/*    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
         select spv.SN, @vItem, spv.STAT, spv.STAT, @piOper, getdate(), @vUID, '由网络发送到门店：' + cast(@piRcv as varchar)
           from SPVOUCHER spv (nolock)
          where spv.SN = @piSN;
*/
    update SPVOUCHER
       set SNDTIME = getdate()
     where SN = @piSN;

    return (0);
  end
GO
