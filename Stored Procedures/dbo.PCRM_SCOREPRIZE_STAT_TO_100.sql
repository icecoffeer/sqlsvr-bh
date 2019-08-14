SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREPRIZE_STAT_TO_100]
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
  declare @vScore decimal(24, 2)
  declare @vRevScore decimal(24, 2)
  declare @vScoreSort varchar(20)
  declare @vCardRevScore decimal(24, 2)
  declare @vHstNum varchar(26)
  declare @vLine int

  --如果是非IC卡需要写卡数据库
  set @vRevScore = 0
  if object_id('c_Card') is not null deallocate c_Card
  declare c_Card cursor for
  select CARDNUM, SCORE, SCORESORT
  from CRMSCOREPRIZECARDDTL where NUM = @piNum
  open c_Card
  fetch next from c_Card into @vCardNum, @vScore, @vScoreSort
  set @vLine = 1
  while @@fetch_status = 0
  begin
    select @vMedium = t.MEDIUM, @vCardRevScore = Dtl.Score
    from CRMCARDTYPE t(nolock), CRMCARD c(nolock), CRMCardScoDtl Dtl(nolock)
    where c.CARDTYPE = t.CODE
      and Dtl.CardNum = c.CardNum
      and c.CARDNUM = @vCardNum
      
    if @@rowcount = 0
    begin
      set @poErrMsg = '找不到卡 ' + @vCardNum + ' 的卡介质';
      close c_Card
      deallocate c_Card
      return(1)
    end    
    
    if @vMedium <> 'IC卡'
    begin
      select @vRecCnt = count(1) from CRMCARDSORTSCORE where CARDNUM = @vCardNum
      if @vRecCnt <> 0 
      begin
        select @vRevScore = SCORE from CRMCARDSORTSCORE where CARDNUM = @vCardNum and SCORESORT = @vScoreSort
      end else
      begin
        set @vRevScore = 0
      end
      
      if @vRevScore < @vScore 
      begin
        set @poErrMsg = '审核单据出错：兑奖积分大于当前积分'
        close c_Card
        deallocate c_Card
        return(1)
      end
      
      update CRMSCOREPRIZECARDDTL set REVSCORE = @vRevScore, CardRevScore = @vCardRevScore where current of c_Card

      exec @vRet = PCRM_CARD_SCOREEX '修正', @vCardNum, @vScoreSort, '107', @vScore, @vRevScore, @piOperGid, @vHstNum output, @poErrMsg output
      insert into CRMScorePrizeScoreDtl(Num, Line, CardNum, HstNum, RevScore, Score, ScoreSort)   
        values(@piNum, @vLine, @vCardNum, @vHstNum, @vRevScore, @vScore, @vScoreSort)
      set @vLine = @vLine + 1  
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
  deallocate c_Card--*/

  --更新单据信息
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vRevScore = sum(CARDREVSCORE), @vScore = sum(SCORE)  
  from CRMSCOREPRIZECARDDTL where NUM = @piNum
  update CRMSCOREPRIZE set 
    STAT = 100, 
    SETTLENO = @vSettleNo, 
    MODIFIER = @vOper,
    LSTUPDTIME = getdate(),
    REVSCORE = @vRevScore,
    SCORE = @vScore
  where NUM = @piNum
  exec PCRM_SCOREPRIZE_ADD_LOG @piNum, 0, 100, @piOperGid

  return(0)
end
GO
