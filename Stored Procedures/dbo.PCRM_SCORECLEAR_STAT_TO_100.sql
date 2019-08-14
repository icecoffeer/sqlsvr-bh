SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCORECLEAR_STAT_TO_100] (
  @piNum char(14),                    --单号
  @piOperGid int,                     --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vCardNum varchar(20)
  declare @vOper varchar(50)
  declare @vSettleNo int
  declare @vScore decimal(24, 2)
  declare @vTotalScore decimal(24, 2)
  declare @vAdjScore money
  declare @vSort varchar(20)
  declare @vLine int
  declare @vRet int

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  set @vTotalScore = 0
  set @vLine = 1
  delete from CRMScoreClearSortDtl where Num = @piNum
  declare c_CardNum cursor for 
    select CardNum from CRMScoreClearScoreDtl(nolock) where Num = @piNum
  open c_CardNum
  fetch next from c_CardNum into @vCardNum
  while @@fetch_status = 0 
  begin
    set @vScore = 0;
    select @vScore = Score from CRMCardScoDtl(nolock) where CardNum = @vCardNum
    select @vTotalScore = @vTotalScore + @vScore
    update CRMScoreClearScoreDtl set Score = @vScore where Num = @piNum and CardNum = @vCardNum
    declare c_Sort cursor for
      select ScoreSort, Score from CRMCardSortScore where CardNum = @vCardNum
    open c_Sort
    fetch next from c_Sort into @vSort, @vScore
    while @@fetch_status = 0
    begin
      insert into CRMScoreClearSortDtl (Num, Line, CardNum, Sort, Score)
        values(@piNum, @vLine, @vCardNUm, @vSort, @vScore)
      set @vAdjScore = @vScore * (-1)  
      exec @vRet = PCRM_CARD_SCORE '修正', @vCardNum, @vSort, '104', @vAdjScore, @vScore, @piOperGid, @poErrMsg
      if @vRet <> 0 
      begin
        close c_Sort
        deallocate c_Sort
        close c_CardNum
        deallocate c_CardNum
        return(@vRet)
      end 
      set @vLine = @vLine + 1
      fetch next from c_Sort into @vSort, @vScore  
    end
    close c_Sort
    deallocate c_Sort   
    
    fetch next from c_CardNum into @vCardNum
  end
  close c_CardNum
  deallocate c_CardNum
    
  update CRMScoreClear set 
    STAT = 100,
    MODIFIER = @vOper,
    TotalScore = @vTotalScore,
    LSTUPDTIME = getdate(),
    SETTLENO = @vSettleNo,
    CHECKER = @vOper,
    CHKDATE = getdate()
  where NUM = @piNum
  exec PCRM_SCORECLEAR_ADD_LOG @piNum, 0, 100, @piOperGid

  return(0)
end
GO
