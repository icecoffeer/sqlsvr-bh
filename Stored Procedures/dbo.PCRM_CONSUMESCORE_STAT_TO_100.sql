SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CONSUMESCORE_STAT_TO_100] (
  @piNum char(14),                    --单号
  @piOperGid int,                     --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  /*declare @vRet int
  declare @vRecCnt int  
  declare @vMedium varchar(10)
  declare @vCardNum varchar(20)
  declare @vOldScore money
  declare @vScore money
  declare @vSubject varchar(4)*/
  declare @vOper varchar(50)
  declare @vSettleNo int

  /*select @vCardNum = CARDNUM
  from CRMCONSCORE where NUM = @piNum

  select @vMedium = t.MEDIUM
  from CRMCARDTYPE t, CRMCARD c
  where c.CARDTYPE = t.CODE
    and c.CARDNUM = @vCardNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到卡 ' + @vCardNum + ' 的卡介质';
    return(1)
  end
  
  --如果是非IC卡需要写卡数据库
  if @vMedium <> 'IC卡'
  begin
    --更新单据汇总
    select @vRecCnt = count(1) from CRMCARDSCODTL where CARDNUM = @vCardNum
    if @vRecCnt <> 0 
    begin
      select @vOldScore = SCORE from CRMCARDSCODTL where CARDNUM = @vCardNum
    end else
    begin
      set @vOldScore = 0
    end;    
    update CRMCONSCORE set OLDSCORE = @vOldScore where NUM = @piNum

    --写卡
    if object_id('c_Score') is not null deallocate c_Score
    declare c_Score cursor for 
    select SUBJECT, SCORE
    from CRMCONSCORESCODTL where NUM = @piNum
    open c_Score
    fetch next from c_Score into @vSubject, @vScore
    while @@fetch_status = 0
    begin
      exec @vRet = PCRM_CARD_SCORE '后台消费', @vCardNum, @vSubject, @vScore, @vOldScore, @piOperGid, @poErrMsg output
      if @vRet <> 0
      begin
        close c_Score
        deallocate c_Score
        return(@vRet)
      end

      fetch next from c_Score into @vSubject, @vScore
    end
    close c_Score
    deallocate c_Score
  end*/

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  update CRMCONSCORE set 
    STAT = 100,
    MODIFIER = @vOper,
    LSTUPDTIME = getdate(),
    SETTLENO = @vSettleNo
  where NUM = @piNum
  exec PCRM_CONSUMESCORE_ADD_LOG @piNum, 0, 100, @piOperGid

  return(0)
end
GO
