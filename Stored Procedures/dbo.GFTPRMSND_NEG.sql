SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_NEG]
(
  @piNum char(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare @vRet int
  declare @vNum varchar(14)
  declare @vOper varchar(50)
  declare @vSettleNo int
  declare @vGftGid int
  declare @vQty money
  declare @vWrhGid int
  declare @vVdrGid int
  declare @vCls varchar(10)
  declare @vPosNo varchar(10)
  declare @vFlowNo varchar(14)
  declare @vTmpQty money
  declare @vTotal money

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid;
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  exec GENNEXTBILLNUMEX null, 'GFTPRMSND', @vNum output

  insert into GFTPRMSND(NUM, STAT, FILLER, FILDATE, SRC, LSTUPDTIME, NOTE, CLIENT, CTRNAME, SNDCLS, SETTLENO, SNDTIME, PRNTIME, PAYAMT, TAG, MODNUM)
  select @vNum, 120, @vOper, getdate(), SRC, getdate(), NOTE, CLIENT, CTRNAME, SNDCLS, @vSettleNo, null, null, -PAYAMT, TAG, @piNum
  from GFTPRMSND where NUM = @piNum;
  insert into GFTPRMSNDBILL(NUM, LINE, CLS, POSNO, FLOWNO, NOTE, AMT)
  select @vNum, LINE, CLS, POSNO, FLOWNO, NOTE, AMT
  from GFTPRMSNDBILL where NUM = @piNum;
  insert into GFTPRMSNDGIFT(NUM, LINE, RCODE, GROUPID, GFTGID, PAYPRC, COSTPRC, QTY, BCKQTY)
  select @vNum, LINE, RCODE, GROUPID, GFTGID, PAYPRC, COSTPRC, -QTY, BCKQTY
  from GFTPRMSNDGIFT where NUM = @piNum;
  insert into GFTPRMSNDRULE(NUM, LINE, RCODE, TAG, [COUNT], BCKCOUNT)
  select @vNum, LINE, RCODE, TAG, [COUNT], BCKCOUNT
  from GFTPRMSNDRULE where NUM = @piNum;
  insert into GFTPRMSNDSALE(NUM, LINE, CLS, POSNO, FLOWNO, GDGID, QTY, AMT, BCKQTY, BCKAMT, ADDQTY, ADDAMT, SALETIME, DEDUCTAMT)
  select @vNum, LINE, CLS, POSNO, FLOWNO, GDGID, QTY, AMT, BCKQTY, BCKAMT, ADDQTY, ADDAMT, SALETIME, DEDUCTAMT
  from GFTPRMSNDSALE where NUM = @piNum;

  exec HDDEALLOCCURSOR 'c_gftsnd' --确保游标被释放
  declare c_gftsnd cursor for
  select GFTGID, sum(QTY), sum(QTY * PAYPRC) from GFTPRMSNDGIFT
  where NUM = @piNum group by GFTGID
  open c_gftsnd
  fetch next from c_gftsnd into @vGftGid, @vQty, @vTotal
  while @@fetch_status = 0
  begin
    select @vWrhGid = WRH, @vVdrGid = BILLTO from GOODS(nolock) where GID = @vGftGid
    execute @vRet = LOADIN @vWrhGid, @vGftGid, @vQty, 0, null, 0
    if @vRet <> 0
    begin
      close c_gftsnd
      deallocate c_gftsnd
    end
    select @vSettleNo = MAX(NO) from MONTHSETTLE(nolock)
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
      LS_Q, LS_A, LS_T, LS_I, LS_R)
    values(convert(datetime, convert(char, getdate(), 102)),
      @vSettleNo, @vWrhGid, @vGftGid, 1, 1, @vVdrGid, -@vQty, -@vTotal, 0, 0, 0)

    set @vTmpQty = -1 * @vQty
    exec GFTPRMSND_ADDGIFTLOG @piNum, @vGftGid, @vTmpQty, @piOperGid
    fetch next from c_gftsnd into @vGftGid, @vQty, @vTotal
  end
  close c_gftsnd
  deallocate c_gftsnd

  --回写赠品规则
  exec @vRet = GFTPRMSND_UPDATERULE @vNum, @poErrMsg output
  if @vRet <> 0 return(@vRet)

  return(0);
end
GO
