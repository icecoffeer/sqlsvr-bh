SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_NET_RECEIVE]
  (
  @bill_id int,
  @src_id  int,
  @oper char(30),
  @msg  varchar(255) output
  )
  as
  begin
    set nocount on;

    declare @vRnt   int;
    declare @vExv   int;
    declare @vUID   int;
    declare @vZID   int;
    declare @SigStatJmp char(1);

    set @vRnt = 0;
    select @vUID = USERGID, @vZID = ZBGID
      from SYSTEM;
/*    if @@rowcount = 0
    begin
      set @msg = '门店信息访问出错!';
      return(1);
    end;
*/
    select @SigStatJmp = upper(OPTIONVALUE)      ----'在状态流转的过程中，是否允许跳过中间的状态。Y:允许跳过;N:禁止跳过中间状态'
      from HDOPTION (nolock)
      where MODULENO = 612
        and upper(OPTIONCAPTION) = 'STAT_JUMP';

    if @SigStatJmp = 'N'
    begin
      set @msg = '系统设置中，禁止跳过中间状态!目前还不能在这种情况下接收';
      return(1);
    end;

    -- 临时表 #spv_net_rcv 用来记录日志的中间数据
    create table #spv_net_rcv( SN       varchar(32)
                             , ITEMNO   int
                             , FROMSTAT int
                             , TOSTAT   int
                             , OPER     int
                             , OPERTIME datetime
                             , SRC      int
                             , NOTE     varchar(100));

    /*********************************************************************
    -- 把网络表中那些已经接收的券（其发送时间早于或等于接收时间）删除
    delete NSPVOUCHER
      from SPVOUCHER sp
     where NSPVOUCHER.SN = sp.SN
       and NSPVOUCHER.[ID] = @bill_id
       and NSPVOUCHER.SRC = @src_id
       and NSPVOUCHER.SNDTIME <= sp.RCVTIME   ---- 丢弃已经接收的券
       and NSPVOUCHER.NTYPE = 1;
    *********************************************************************/

    -- if @vUID = @vZID 则本店为总部, else 本店为门店
    if @vUID = @vZID
    begin             ---- 门店 -> 总部  update , no insert
      delete NSPVOUCHER
       where [ID] = @bill_id
         and SRC = @src_id
         and SRC = @vZID          ---- 仅接受来自门店的券, 不是的都删除,其实就是删除总部发给总部的券
         and NTYPE = 1;
      set @vRnt = @vRnt + @@error;

      --准备日志数据
      --          SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
      insert into #spv_net_rcv(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
      select lg.SN, isnull(max(ITEMNO), 0) + 1, isnull(max(sp.STAT), 0)
           , max(nsp.STAT),0 , getdate() , max(nsp.SRC) , '网络数据成功接收并处理。'
        from SPVOUCHER sp (nolock), NSPVOUCHER nsp (nolock),  SPVOUCHERLOG lg  (nolock)  ----由于门店不能制作券，故总部的 SPVOUCHER 或 SPVOUCHERLOG  表里没有的券就不接收
       where sp.SN = nsp.SN                                                              ----因此在这里只需要内连接，而不需要外连接。这与后面的门店接收不同。
         and sp.SN = lg.SN
         and nsp.[ID] = @bill_id
         and nsp.SRC = @src_id
         and nsp.NTYPE = 1
       group by lg.SN;
      select @vRnt = @vRnt + @@error, @vExv = @@rowcount;
      if @vExv = 0 -- 关于此券的原有日志丢失，
      begin
        insert into #spv_net_rcv(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
        select sp.SN, 1, sp.STAT
             , nsp.STAT, 0, getdate(), nsp.SRC, '[原有日志丢失,在接收时补充]，网络数据成功接收并处理。'
          from SPVOUCHER sp (nolock), NSPVOUCHER nsp (nolock)   ----由于门店不能制作券，故总部的 SPVOUCHER  表里没有的券就不接收
         where sp.SN = nsp.SN                                   ----因此在这里只需要内连接，而不需要外连接。这与后面的门店接收不同。
           and nsp.[ID] = @bill_id
           and nsp.SRC = @src_id
           and nsp.NTYPE = 1;
        select @vRnt = @vRnt + @@error, @vExv = @@rowcount;
      end;

      update #spv_net_rcv
         set NOTE = '动作[' + cast(nsp.STAT as varchar) + ']在门店[' + st.CODE + '-' + st.[NAME] + ']重复执行或重复发送' + left(isnull(NOTE, ''), 70)
        from NSPVOUCHER nsp, SPVOUCHER sp, STORE st
       where nsp.SN = #spv_net_rcv.SN
         and nsp.SN = sp.SN
         and nsp.[ID] = @bill_id
         and nsp.SRC = @src_id
         and nsp.NTYPE = 1
         and nsp.SRC = st.GID
         and nsp.STAT <= sp.STAT;

      --接收数据，因为只有总部有制作券的可能，因此这里(门店 -> 总部)没有 insert,只有update
      update SPVOUCHER
         set SPVOUCHER.STAT     = nsp.STAT
           , SPVOUCHER.RCVTIME  = getdate()
           , SPVOUCHER.SNDTIME  = NULL
           --, SPVOUCHER.PHASE    = nsp.PHASE
           --, SPVOUCHER.BESOPER	= nsp.BESOPER
           --, SPVOUCHER.BESSRC	= nsp.BESSRC
           , SPVOUCHER.HANDOPER = nsp.HANDOPER
           , SPVOUCHER.HANDSRC	= nsp.HANDSRC
           , SPVOUCHER.HANDTIME	= nsp.HANDTIME  --ShenMin
        from NSPVOUCHER nsp
       where SPVOUCHER.SN = nsp.SN
         and nsp.[ID] = @bill_id
         and nsp.SRC = @src_id
         and nsp.NTYPE = 1
         and nsp.STAT > SPVOUCHER.STAT;
      set @vRnt = @vRnt + @@error;

      insert into SPVOUCHERLOG
            select *
              from #spv_net_rcv;
       delete NSPVOUCHER
         from #spv_net_rcv rcv
         where NSPVOUCHER.[ID] = @bill_id
           and NSPVOUCHER.SRC = @src_id
           and NSPVOUCHER.SN = rcv.SN;
      set @vRnt = @vRnt + @@error;

    end else               ----  总部 -> 门店  delete and insert,
    begin
      delete NSPVOUCHER
       where [ID] = @bill_id
         and SRC = @src_id
         and SRC <> @vZID          ---- 仅接受来自总部的券, 不是的都删除
         and NTYPE = 1;
      set @vRnt = @vRnt + @@error;
      --准备日志数据
      --          SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
      insert into #spv_net_rcv(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
      select nsp.SN, isnull(max(ITEMNO), 0) + 1, isnull(max(sp.STAT),0)
           , max(nsp.STAT),0 , getdate() , max(nsp.SRC) , '网络数据成功接收并处理。'
        from NSPVOUCHER nsp (nolock) left outer join SPVOUCHER sp (nolock)               ----由于总部可以制作券，故门店的SPVOUCHER表里没有的券也必须接收, 典型的例子是“总部新制作的券下发”。
                                             on nsp.SN = sp.SN                           ----因此在这里必须用外连接，以保证所有的券都能接收到。这与前面的总部接收不同。
                                     left outer join SPVOUCHERLOG lg (nolock)
                                             on nsp.SN = lg.SN
        where nsp.[ID] = @bill_id
          and nsp.SRC = @src_id
          and nsp.NTYPE = 1
        group by nsp.SN;
      set @vRnt = @vRnt + @@error;

      update #spv_net_rcv
         set NOTE = '动作[' + cast(nsp.STAT as varchar) + ']重复执行或重复发送' + left(isnull(NOTE, ''), 70)
        from NSPVOUCHER nsp, SPVOUCHER sp
       where nsp.SN = #spv_net_rcv.SN
         and nsp.SN = sp.SN
         and nsp.[ID] = @bill_id
         and nsp.SRC = @src_id
         and nsp.NTYPE = 1
         and nsp.STAT <= sp.STAT;

      -- 这里(门店 -> 总部)，以总部的数据为准，我们的做法是: 先删除(将要导入的券)再导入
      -- 把要接收的券（其发送时间迟于接收时间）删除
      delete NSPVOUCHER
        from SPVOUCHER sp
        where sp.SN = NSPVOUCHER.SN
          and NSPVOUCHER.[ID] = @bill_id
          and NSPVOUCHER.SRC = @src_id
          and NSPVOUCHER.SRC = @vZID          ---- 仅接受来自总部的券
          and NSPVOUCHER.NTYPE = 1
          and NSPVOUCHER.STAT <= sp.STAT;
      set @vRnt = @vRnt + @@error;

      delete SPVOUCHER
        from NSPVOUCHER nsp
        where SPVOUCHER.SN = nsp.SN
          and nsp.[ID] = @bill_id
          and nsp.SRC = @src_id
          --and SPVOUCHER.RCVTIME < nsp.SNDTIME
          and nsp.SRC = @vZID          ---- 仅接受来自总部的券
          and nsp.NTYPE = 1
          and nsp.STAT > SPVOUCHER.STAT;
      set @vRnt = @vRnt + @@error;


      -- 导数据, 从网络表到表本身
      insert into SPVOUCHER(SN, STAT, PHASE, FILDATE, SALEAMT, ENSN, BESOPER, BESSRC, HANDOPER, HANDSRC, RCVTIME,SNDTIME,HANDTIME)
           select SN, STAT, PHASE, FILDATE, SALEAMT, ENSN, BESOPER, BESSRC, HANDOPER, HANDSRC, SNDTIME, null, HANDTIME
             from NSPVOUCHER (nolock)
            where [ID] = @bill_id
              and SRC = @src_id
              and SRC = @vZID          ---- 仅接受来自总部的券
              and NTYPE = 1;
      set @vRnt = @vRnt + @@error;
      insert into SPVOUCHERLOG
            select *
              from #spv_net_rcv;
      set @vRnt = @vRnt + @@error;
      delete NSPVOUCHER
         from #spv_net_rcv rcv
         where NSPVOUCHER.[ID] = @bill_id
           and NSPVOUCHER.SRC = @src_id
           and NSPVOUCHER.SN = rcv.SN;
      set @vRnt = @vRnt + @@error;
    end;
    return (@vRnt);
  end
GO
