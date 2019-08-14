SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_MBRPROMTYPE_STAT_TO_100] (
  @piNum varchar(14),                    --单号
  @piOper varchar(40),                   --操作人
  @poErrMsg varchar(255) output          --出错信息
) as
begin
  declare
    --@vOper varchar(80),
    @vSettleNo int,
    @vUserGid int,
    @vUUID  varchar(32),
    @vSubjCode varchar(20),
    @vSubjName varchar(50),
    @vAllMbr int,
    @vCount int,
    @vCardNum varchar(20),
    @vCarrier int,
    @vStore int

  select @vUserGid = UserGid  from FASystem(nolock)
  --select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vSubjCode = subjcode, @vSubjName = subjName, @vAllMbr = allMbr, @vStore = store
    from CRMMBRPROMTYPEBILL
  where num = @piNum

  if @vAllMbr = 1
  begin
    select @vCount = count(1) from CRMMBRPROMSUBJINV(nolock) where subjcode = @vSubjCode
    if @vCount > 0
    begin
      set @poErrMsg = '会员促销主题 ' + @vSubjName + ' 已经登记，不允许再登记为全部会员'
      return(1)
    end
  end else
  begin
    select @vCount = count(1) from CRMMBRPROMSUBJINV(nolock) where subjcode = @vSubjCode and allmbr = 1
    if @vCount > 0
    begin
      set @poErrMsg = '会员促销主题 ' + @vSubjName + ' 已经登记为全部会员，不允许再登记为指定会员'
      return(1)
    end
  end

  declare c_dtl cursor for
    select cardnum, carrier from CRMMBRPROMTYPEBILLDTL(nolock) where num = @piNum
  open c_dtl
  fetch next from c_dtl into @vCardNum, @vCarrier
  while @@fetch_status = 0
  begin
    if @vCarrier = 1
    begin
      set @poErrMsg = '卡 ' + @vCardNum + ' 的持卡人为空'
      return(1)
    end

    select @vCount = count(1) from CRMMBRPROMSUBJINV a(nolock), CRMMBRPROMSUBJINVDTL b(nolock)
    where a.uuid = b.RULEUUID and b.MBRGID = @vCarrier and a.subjcode = @vSubjCode
    if @vCount > 0
    begin
      set @poErrMsg = '卡 ' + @vCardNum + ' 已经登记，不允许重复登记'
      return(1)
    end
    fetch next from c_dtl into @vCardNum, @vCarrier
  end
  close c_dtl
  deallocate c_dtl

  exec HD_CREATEUUID @vUUID output
  insert into CRMMBRPROMSUBJINV(UUID, SUBJCODE, ALLMBR, OPER, OPERTIME, SRCNUM, STORE)
  values(@vUUID, @vSubjCode, @vAllMbr, @piOper, getDate(), @piNum, @vStore)
  if @vAllMbr <> 1
  begin
    insert into CRMMBRPROMSUBJINVDTL(RULEUUID, MBRGID, CARDNUM)
    select @vUUID, CARRIER, CARDNUM from CRMMBRPROMTYPEBILLDTL where num = @piNum
  end

  update CRMMBRPROMTYPEBILL set
    Stat = 100, SettleNo = @vSettleNo,
    Checker = @piOper, ChkDate = getdate(),
    Modifier = @piOper, LstUpdTime = getdate()
  where Num = @piNum
  exec PCRM_MBRPROMTYPE_ADD_LOG @piNum, 0, 100, @piOper

  return(0)
end
GO
