SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PRMOFFSETCHK]
(
  @num varchar(14),
  @cls varchar(10),
  @toStat int,  --100 审核
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  declare
    @return_status int,
    @stat int,
    @m_launch datetime,
    @vdrgid int,
    @igatheringmode int,
    @sgatheringmode varchar(10),
    @PayDirect smallInt,  --收付方向
    @storegid int,
    @optusecntr int,
    @ChgBookNum varchar(14),
    @curdate datetime,
    @CreateOnCheck int,/*zhujie2009.4.3*/
    @gdgid int,
    @RAmt money,
    @settleno int,
    @AgmTableName varchar(32), --来源促销补差协议类型
    @vAgmNum char(14),
    @vRtnStat smallint;

  select @settleno = max(no) from monthsettle;
  select @return_status = 0;
  select @curdate = convert(datetime, convert(char, getdate(), 102));
  exec OPTREADINT 0, 'usecntr', 0, @optusecntr OUTPUT
  --读取促销补差单审核时是否生成费用单选项。optionvalue = 0-不生成; 1-生成费用单; 2-不生成费用单，但需要记录账款
  exec OptReadInt 727, 'CreateOnCheck', 0, @CreateOnCheck OUTPUT;

  select @stat = STAT,
    @m_launch = LAUNCH,
    @vdrgid = VDRGID,
    @igatheringmode = GATHERINGMODE,
    @PayDirect = PAYDIRECT
  from PRMOFFSET(nolock)
  where NUM = @num;
  if (@stat <> 0) and (@toStat = 100)
  begin
    set @Msg = '审核的不是未审核的单据.';
      return(1)
  end

  if @PayDirect = -1
  begin
    --取促销补差来源协议号，因目前只有返点协议需要，暂不考虑来源单据有多张的情况
    select top 1 @AgmTableName = AGMTABLENAME, @vAgmNum = AGMNUM
    from PRMOFFSETDTL(nolock) where NUM = @num;
    if @AgmTableName = 'PRMRTNPNTAGM'
    begin
      --检查来源促销返点协议的返点状态
      select @vRtnStat = RTNSTAT from PRMRTNPNTAGM(nolock) where NUM = @vAgmNum
      if @vRtnStat = 0
      begin
        update PRMRTNPNTAGM set RTNSTAT = 1 where NUM = @vAgmNum
        exec @return_status = PRMRTNPNTAGM_ON_MODIFY @Num = @vAgmNum, @ToStat = 300, @Oper = @Oper, @Msg = @Msg output
        if @return_status <> 0 return @return_status
      end
      else begin
        set @Msg = '来源促销返点协议的返点状态不是未返点。不能审核。'
        return 1
      end
    end
  end

  declare @checker int;
  select @checker = Gid from Employee
  where RTRIM(Name) + '[' + RTRIM(Code) + ']' = @oper;
  declare @curStat int
  select @curStat = STAT from PrmOffset (nolock) where NUM = @Num
  update PRMOFFSET set STAT = 100, Checker = @checker, ChkDate = GETDATE(), SettleNo = @SettleNo where NUM = @num;
  exec PrmOffsetADDLOG @Num, @curStat, 100, @Oper

  /*  if (@m_launch is null or @m_launch < getdate())
    execute @return_status = PRMOFFSETOCR @num, '', 800, @Oper, NULL;
  if @return_status <> 0
      return(@return_status); Delete by ShenMin, 取消生效状态*/

  --回写已结数量，回写PRMOFFSETAGMDTL.INUSE，生成费用单
  if @PayDirect = 1
  begin
    --回写已结数量
    exec PRMOFFSETLENDUPD @num, 1;
    
    --回写PRMOFFSETAGMDTL.INUSE
    exec UPDAGMDTLINUSE @NUM
  end;

  declare c_lac cursor for
    select STOREGID from PRMOFFSETLACDTL where NUM = @num for read only;

  open c_lac;
  fetch next from c_lac into @storegid;
  while @@fetch_status = 0
  begin
    --生成费用单
    if @CreateOnCheck = 1 and @optusecntr = 1
    begin
      --创建费用单
      exec @return_status = PRMOFFSET_CHGBOOK_CREATE @Num, @storegid, @ChgBookNum output, @checker, @Msg output
      if @return_status <> 0 break
      update PrmOffset set ChgNum = @ChgBookNum where num=@num
    end
    ----收付方向为付款的，由于是时候计算账款并生成促销补差单，故当CreateOnCheck = 2时，此类促销补差单应在审核时记录供应商账款报表(应结)
    else if @CreateOnCheck = 2 and @PayDirect = -1
    begin
      --若选项设置为通过供应商结算单计算，则记录供应商账款报表
      declare c_Dtl cursor for select GDGID, RAMT from PRMOFFSETDTLDTL(nolock)
         where NUM = @num and STOREGID = @storegid;
      open c_Dtl
      fetch next from c_Dtl into @gdgid, @RAmt
      while @@fetch_status = 0
      begin
        --记录出货日报(记录DI1-零售核算额)
        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, LS_I_B, PARAM)
        values (@SettleNo, @curdate,1, @gdgid, @RAmt, 0)

        --记录账款报表(记录DT3-应结额)
        exec AppUpdVdrDrpt @store = @StoreGid, @settleno = @SettleNo, @date = @curdate, @vdrgid = @VdrGid,
             @wrh = 1, @gdgid = @gdgid, @dq1 = 0, @dq2 = 0, @dq3 = 0, @dq4 = 0, @dq5 = 0, @dq6 = 0,
          @dt1 = 0, @dt2 = 0, @dt3 = @RAmt, @dt4 = 0, @dt5 = 0, @dt6 = 0, @dt7 = 0, @di2 = @RAmt

        --记录库存调整报表(记录DI3-核算调价额)
        if @RAmt <> 0
          insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@curdate, @SettleNo, 1, @gdgid, 0, @RAmt)

        fetch next from c_Dtl into @gdgid, @RAmt;
      end
      close c_Dtl
      deallocate c_Dtl
    end;
    --下一个门店
    fetch next from c_lac into @storegid;
  end;
  close c_lac;
  deallocate c_lac;
  if @return_status <> 0 return(@return_status)

  -- 自动发送
  DECLARE @autoSend int;
  EXEC OptReadInt 727, 'AutoSend', 0, @autoSend OUTPUT;
  IF @autoSend <> 0
  BEGIN
      DECLARE @lac_storeGid int;
      DECLARE lac CURSOR FOR SELECT StoreGid FROM PrmOffsetLacDtl WHERE Num = @num
          AND StoreGid <> (SELECT UserGid FROM System) ;
      OPEN lac;
      FETCH NEXT FROM lac INTO @lac_storeGid;
      WHILE @@FETCH_STATUS = 0
      BEGIN
          EXEC @return_status = PrmOffsetSnd @num, @lac_storeGid, 1, @Msg OUTPUT;
          IF @return_status <> 0 BREAK;
          FETCH NEXT FROM lac INTO @lac_storeGid;
      END;

      CLOSE lac;
      DEALLOCATE lac;
  END;
  RETURN (@return_status);
end
GO
