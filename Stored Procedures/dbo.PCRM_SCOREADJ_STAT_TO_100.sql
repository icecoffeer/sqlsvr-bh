SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREADJ_STAT_TO_100]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vRecCnt int 
  declare @vSettleNo int
  declare @vOper varchar(50)
  declare @vMedium varchar(10)
  declare @vCardNum varchar(20)
  declare @vScoreSort varchar(20)
  declare @vScore decimal(24, 2)
  declare @vRevScore decimal(24, 2)

  --如果是非IC卡需要写卡数据库
  if object_id('c_Card') is not null deallocate c_Card
  declare c_Card cursor for
  select CARDNUM, SCOREADJ, SCORESORT
  from CRMSCOREADJDTL where NUM = @piNum
  open c_Card
  fetch next from c_Card into @vCardNum, @vScore, @vScoreSort
  while @@fetch_status = 0
  begin
    select @vMedium = t.MEDIUM
    from CRMCARDTYPE t, CRMCARD c
    where c.CARDTYPE = t.CODE
      and c.CARDNUM = @vCardNum
    if @@rowcount = 0
    begin
      set @poErrMsg = '找不到卡 ' + @vCardNum + ' 的卡介质!';
      close c_Card
      deallocate c_Card
      return(1)
    end

    if @vMedium <> 'IC卡'
    begin
      select @vRecCnt = count(1) from CRMCARDSORTSCORE where CARDNUM = @vCardNum and SCORESORT = @vScoreSort
      if @vRecCnt <> 0 
      begin
        select @vRevScore = SCORE from CRMCARDSORTSCORE where CARDNUM = @vCardNum and SCORESORT = @vScoreSort
      end else
      begin
        set @vRevScore = 0
      end
      update CRMSCOREADJDTL set REVSCORE = @vRevScore where current of c_Card
      
      exec @vRet = PCRM_CARD_SCORE '修正', @vCardNum, @vScoreSort, '104', @vScore, @vRevScore, @piOperGid, @poErrMsg output
      if @vRet <> 0
      begin
        close c_Card
        deallocate c_Card
        return(@vRet)
      end      
    end

    fetch next from c_Card into @vCardNum, @vScore, @vScoreSort
  end
  close c_Card
  deallocate c_Card

  --更新单据信息
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vRevScore = sum(REVSCORE), @vScore = sum(SCOREADJ)
  from CRMSCOREADJDTL where NUM = @piNum
  update CRMSCOREADJ set 
    STAT = 100, 
    SETTLENO = @vSettleNo, 
    CHECKER = @vOper,
    CHKDATE = getdate(),
    MODIFIER = @vOper,
    LSTUPDTIME = getdate(),
    REVSCORE = @vRevScore,
    SCORE = @vScore
  where NUM = @piNum
  exec PCRM_SCOREADJ_ADD_LOG @piNum, 0, 100, @piOperGid

  return(0)
end

GO
