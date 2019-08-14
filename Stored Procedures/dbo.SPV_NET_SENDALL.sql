SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_NET_SENDALL]
  (
  @piOper   int,
  @poErrMsg varchar(255) output
  )
  as
  begin
    set nocount on;
    declare @vRnt   int;
--     declare @vNID   int;
--     declare @vUID   int;
--     declare @vZID   int;
--     declare @vItem  int;
    declare @vSN    varchar(32);
    declare @vMsg   varchar(255);
    declare @vlp    int;
    declare @vLast  int;
    set @vRnt = 0;

--     select @vUID = USERGID, @vZID = ZBGID
--       from SYSTEM;
--     if @@rowcount = 0
--     begin
--       set @poErrMsg = '门店信息访问出错!';
--       return(1);
--     end;

    create table #spv_net_sndall(RNO int identity(1, 1) not for replication
                               , SN  varchar(32)
                               , primary key(RNO));
    insert into #spv_net_sndall(SN)
      select SN
        from SPVOUCHER (nolock);
    if @@rowcount = 0
       return(0);

    select @vlp = min(RNO), @vLast = max(RNO)
      from #spv_net_sndall;
    while @vlp <= @vLast
    begin
      select @vSN = SN  --, @vStore = GID
        from #spv_net_sndall
        where RNO = @vlp;
      exec @vRnt = SPV_NET_SENDONE @vSN, @piOper, @vMsg output ;
      if @vRnt > 0
      begin
        set @poErrMsg = @vMsg;
        return @vRnt;
      end;
      set @vlp = @vlp + 1;
    end;

--       exec GETNETBILLID @vNID output;
--       insert into NSPVOUCHER([ID], SRC , SN , STAT , PHASE , FILDATE , SALEAMT , ENSN , SNDTIME ,
--                                     RCV , RCVTIME , FRCCHK , NTYPE , NSTAT , NNOTE)
--            select @vNID, st.GID, @vSN, sp.STAT, sp.PHASE, sp.FILDATE, sp.SALEAMT, sp.ENSN, getdate(),
--                   @vUID, null, 1, 0, 0, null
--             from SPVOUCHER sp (nolock) , [STORE] st (nolock)
--             where sp.SN = @vSN
--               and st.GID <> @vUID; ---- 本门店不需要发送
--
--       select @vItem = isnull(max(ITEMNO), 0) + 1
--         from SPVOUCHERLOG  (nolock)
--         where SN = @vSN;
--
--       update SPVOUCHER
--          set SNDTIME = getdate()
--        where SN = @vSN;
--       insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
--          select @vSN, @vItem, spv.STAT, spv.STAT, @piOper, getdate(), @vUID, '由网络发送到所有门店'
--            from SPVOUCHER spv  (nolock)
--           where spv.SN = @vSN

--       set @vlp = @vlp + 1;
--     end;

    return (@vRnt);
  end
GO
