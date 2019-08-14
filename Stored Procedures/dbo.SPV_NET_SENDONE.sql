SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_NET_SENDONE]
  (
  @piSN     varchar(32),
  @piOper   int,
  @poErrMsg varchar(255) output
  )
  as
  begin
    set nocount on;
    declare @vRnt   int;
    declare @vNID   int;
    declare @vUID   int;
    declare @vTop   int;
    declare @vItem  int;
    declare @vDate  datetime;
    set @vRnt = 0;

    select @vUID = USERGID
      from SYSTEM;
    if @@rowcount = 0
    begin
      set @poErrMsg = '门店信息访问出错!';
      return(1);
    end;

    set @vDate = getdate();

     create table #SPV_SENDONE(RNO  int identity(1, 1) not for replication primary key,
                              [ID] int null,
                              SRC int null,
                              SN char(32) null,
                              STAT int null,
                              PHASE int null,
                              FILDATE datetime null,
                              SALEAMT decimal(24, 2) null,
                              ENSN char(64) null,
                              BESOPER  char(30) null,
                              BESSRC   char(30) null,
                              HANDOPER char(30) null,
                              HANDSRC  char(30) null,
                              SNDTIME datetime null,
                              RCV int null,
                              RCVTIME datetime null,
                              FRCCHK smallint null,
                              NTYPE smallint null,
                              NSTAT smallint null,
                              NNOTE varchar(100) null,
                              HANDTIME datetime null);

    insert into #SPV_SENDONE([ID], SRC , SN , STAT , PHASE , FILDATE , SALEAMT , ENSN ,
                                    BESOPER, BESSRC, HANDOPER, HANDSRC, SNDTIME ,
                                    RCV , RCVTIME , FRCCHK , NTYPE , NSTAT , NNOTE, HANDTIME)
           select 0, @vUID, @piSN, sp.STAT, sp.PHASE, sp.FILDATE, sp.SALEAMT, sp.ENSN,
                  sp.BESOPER, sp.BESSRC, sp.HANDOPER, sp.HANDSRC, @vDate,   --这里的 ID 自段值设为0，这只是为了填充一个非空值，
                  st.GID, null, 1, 0, 0, null, HANDTIME                                              --它的真正的值将在后面设置
            from SPVOUCHER sp (nolock) , [STORE] st (nolock)
            where sp.SN = @piSN
              and st.GID <> @vUID; ---- 本门店不需要发送

    select @vTop = max(RNO), @vItem = min(RNO)
      from #SPV_SENDONE;
    while @vItem <= @vTop
    begin
      exec GETNETBILLID @vNID output;
      update #SPV_SENDONE
         set [ID] = @vNID
       where RNO = @vItem;

      set @vItem = @vItem + 1;
    end;

    insert into NSPVOUCHER([ID], SRC, SN, STAT, PHASE, FILDATE, SALEAMT, ENSN,
                            BESOPER, BESSRC, HANDOPER, HANDSRC, SNDTIME,
                            RCV , RCVTIME , FRCCHK , NTYPE , NSTAT , NNOTE, HANDTIME)
                  select   [ID], SRC, SN, STAT, PHASE, FILDATE, SALEAMT, ENSN,
                           BESOPER, BESSRC, HANDOPER, HANDSRC, SNDTIME,
                           RCV, RCVTIME, FRCCHK, NTYPE, NSTAT, NNOTE, HANDTIME
                  from     #SPV_SENDONE

    select @vItem = isnull(max(ITEMNO), 0) + 1
        from SPVOUCHERLOG  (nolock)
        where SN = @piSN;

    update SPVOUCHER
         set SNDTIME = @vDate
       where SN = @piSN;
/*    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
         select @piSN, @vItem, spv.STAT, spv.STAT, @piOper, getdate(), @vUID, '由网络发送到所有门店'
           from SPVOUCHER spv  (nolock)
          where spv.SN = @piSN
*/
    return (@vRnt);
  end
GO
