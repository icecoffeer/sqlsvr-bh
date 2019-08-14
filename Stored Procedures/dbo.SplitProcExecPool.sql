SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SplitProcExecPool]
(
  @Oper varchar(30),
  @SplitType smallint,  --操作模式 0-分解型, 1-组合型
  @msg varchar(255) output,
  @SumNum varchar(4000) output  --本次生成的所有加工入库单单号（以","分隔）
) as
begin
  declare
    @NewNum varchar(14),
    @ProcTaskNum varchar(14), --加工任务单号
    @Algavgtag varchar(255),  --成本平摊算法
    @BgnTime datetime,        --开始时间
    @EndTime datetime,        --结束时间
    @Subject varchar(255),    --加工主题
    @SettleNo int,            --期号
    @Src int,                 --来源单位
    @Mode smallint,           --加工模式
    @vRet int,
    @Line int,
    @PscpCode varchar(40),
    @PscpGid int,
    @GdGid int,
    @Qty money,
    @Total money,
    @CstPrc money,
    @InvPrc money,
    @InPrc money,
    @RtlPrc money,
    @Wrh int,
    @RawWrhCode varchar(20),
    @RawWrh int,
    @Ret smallint

  set @SumNum = '';

  select @RawWrhCode = ISNULL(optionvalue, '') from hdoption(nolock) where moduleno = 647 and optioncaption = 'RAWWRHDEFAULT';
  if @RawWrhCode = ''
    begin
      set @msg = '未配置加工原料仓位';
      set @Ret = 1;
    end
  select @RawWrh = Gid from Warehouse(nolock) where Code = @RawWrhCode;
  declare c_Recipe cursor for
    select distinct PSCPCODE, PSCPGID, PROCTASKNUM
    from TMPPROCEXECPOOL(nolock)
    where SPID = @@SPID;
  open c_Recipe;
  fetch next from c_Recipe into @PscpCode, @PscpGid, @ProcTaskNum;
  while @@fetch_status = 0
  begin
    exec @vRet = GenNextBillNumEx '', 'ProcExec', @NewNum output
    if @vRet <> 0
    begin
      Set @Msg = '取加工入库单新单号失败';
      close c_Recipe;
      deallocate c_Recipe;
      set @Ret = 2;
    end;
    select @SettleNo = MAX(NO) from MONTHSETTLE(nolock);
    select @Src = USERGID from system(nolock);
    if @SplitType = 0
      select @Mode = 2;
    else
    	select @Mode = 1;
    select @Algavgtag = ALGAVGTAG, @BgnTime = BGNTIME, @Endtime = ENDTIME, @Subject = SUBJECT
    from PROCTASK(nolock)
    where NUM = @ProcTaskNum;

    insert into ProcExec(Num, BoCls, TaskNum, Stat, BgnTime, EndTime,
      Filler, FilDate, Subject, Note, Algavgtag,
      SettleNo, Modifier, LstUpdTime, Src, Chkemp, ChkTime, Mode)
      values (@NewNum, '', @ProcTaskNum, 0, @BgnTime, @EndTime,
      @Oper, getdate(), @Subject, '从加工入库池模块生成', @Algavgtag,
      @SettleNo, @Oper, getdate(), @Src, @Oper, getdate(), @Mode);
      if @@error <> 0
        begin
          select @Msg = '生成加工入库单失败';
          EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @Oper, '失败', @Msg;
          set @Ret = 3;
        end
    if @SplitType = 0
      begin
      	select top 1 @GdGid = P.GdGid, @Qty = T.RawQty, @CstPrc = P.CstPrc, @InvPrc = P.InvPrc, @RtlPrc = P.RtlPrc
        from ProcTaskRaw p(nolock), TMPPROCEXECPOOL T(nolock)
        where T.SPID = @@Spid
          and p.Num = @ProcTaskNum
          and T.ProcTaskNum = @ProcTaskNum
          and P.PscpGid = @PscpGid
          and T.PscpGid = @PscpGid
          and P.GdGid = T.RAWGID;
        insert into ProcExecRaw(Num, Line, PscpCode, GdGid, Qty, Total, CstPrc, InvPrc, RtlPrc, Wrh, PscpGid)
        values (@NewNum, 1, @PscpCode, @GdGid, @Qty, @CstPrc * @Qty, @CstPrc, @InvPrc, @RtlPrc, @RawWrh, @PscpGid)
        if @@error <> 0
          begin
            select @Msg =  '生成加工入库单原料失败';
            EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @NewNum, @Oper, '失败', @Msg;
            set @Ret = 4;
          end
      end;
    else
    	begin
        set @Line = 1;
        declare c_Raw cursor for
          select P.GdGid, T.RawQty, T.RawQty * P.CstPrc, P.CstPrc, P.InvPrc, P.RtlPrc
          from ProcTaskRaw p(nolock), TMPPROCEXECPOOL T(nolock)
          where T.SPID = @@Spid
            and p.Num = @ProcTaskNum
            and T.ProcTaskNum = @ProcTaskNum
            and P.PscpGid = @PscpGid
            and T.PscpGid = @PscpGid
            and P.GdGid = T.RAWGID;

        open c_Raw;
        fetch next from c_Raw into @GdGid, @Qty, @Total, @CstPrc, @InvPrc, @RtlPrc;
        while @@fetch_status = 0
        begin
          insert into ProcExecRaw(Num, Line, PscpCode, GdGid, Qty, Total, CstPrc, InvPrc, RtlPrc, Wrh, PscpGid)
            values(@NewNum, @Line, @PscpCode, @GdGid, @Qty, @Total, @CstPrc, @InvPrc, @RtlPrc, @RawWrh, @PscpGid);
          if @@error <> 0
            begin
              select @Msg =  '生成加工入库单原料失败';
              EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @NewNum, @Oper, '失败', @Msg;
              set @Ret = 4;
            end
          set @Line = @Line + 1
          fetch next from c_Raw into @GdGid, @Qty, @Total, @CstPrc, @InvPrc, @RtlPrc
        end
        close c_Raw
        deallocate c_Raw
      end;

    if @SplitType = 0 --分解型
      begin
        set @Line = 1
        declare c_Product cursor for
          select P.GdGid, T.ProdQty, T.ProdQty * P.CstPrc, P.CstPrc, P.InPrc, P.RtlPrc, P.Wrh
          from ProcTaskProd p(nolock), TMPPROCEXECPOOL T(nolock)
          where T.SPID = @@Spid
            and p.Num = @ProcTaskNum
            and T.ProcTaskNum = @ProcTaskNum
            and P.PscpGid = @PscpGid
            and T.PscpGid = @PscpGid
            and P.GdGid = T.PRODGID;

        open c_Product
        fetch next from c_Product into @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh
        while @@fetch_status = 0
        begin
          insert into ProcExecProd(Num, Line, PscpCode, GdGid, Qty, Total, CstPrc, InPrc, RtlPrc, Wrh, PscpGid)
            values(@NewNum, @Line, @PscpCode, @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh, @PscpGid)
          if @@error <> 0
            begin
              select @Msg = '生成加工入库单产品失败';
              EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @NewNum, @Oper, '失败', @Msg;
              set @Ret = 5;
            end
          set @Line = @Line + 1
          fetch next from c_Product into @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh
        end
        close c_Product
        deallocate c_Product
      end;
    else --组合型
      begin
        select top 1 @GdGid = P.GdGid, @Qty = T.ProdQty, @CstPrc = P.CstPrc, @InPrc = P.InPrc, @RtlPrc = P.RtlPrc, @Wrh = P.Wrh
        from ProcTaskProd p(nolock), TMPPROCEXECPOOL T(nolock)
        where T.SPID = @@Spid
          and p.Num = @ProcTaskNum
          and T.ProcTaskNum = @ProcTaskNum
          and P.PscpGid = @PscpGid
          and T.PscpGid = @PscpGid
          and P.GdGid = T.PRODGID;
        insert into ProcExecProd(Num, Line, PscpCode, GdGid, Qty, Total, CstPrc, InPrc, RtlPrc, Wrh, PscpGid)
          values(@NewNum, @Line, @PscpCode, @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh, @PscpGid)
        if @@error <> 0
          begin
            select @Msg =  '生成加工入库单产品失败';
            EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @NewNum, @Oper, '失败', @Msg;
            set @Ret = 5;
          end
      end;

  --删除临时表数据
    delete from TMPPROCEXECPOOL
    where SPID = @@Spid
          and PROCTASKNUM = @ProcTaskNum
          and PSCPGID = @PscpGid
    delete from TMPPROCEXECRAWDTL
    where SPID = @@Spid

    EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @NewNum, @Oper, '成功', ''
    exec PROCEXEC_ADD_LOG @NewNum, 0, 0, @Oper,'';
   /* exec @vRet = PROCEXEC_CHKTO100 @NewNum, @Oper, '', 100, @Msg output
    if @vRet <> 0
      begin
        select @Msg = '审核失败';
        EXEC Write_SplitProcExec_Log  @ProcTaskNum, @PscpCode, '', @NewNum, @Oper, '失败', @Msg;
      end; */
   /* if @SumNum = ''
      set @SumNum = @NewNum ;
    else*/
    	set @SumNum = @SumNum + @NewNum + ',';
    fetch next from c_Recipe into @PscpCode, @PscpGid, @ProcTaskNum;
  end
  close c_Recipe;
  deallocate c_Recipe;

  return(@Ret)
end
GO
