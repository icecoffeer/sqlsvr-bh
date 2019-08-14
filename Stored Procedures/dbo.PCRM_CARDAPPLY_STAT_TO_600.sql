SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDAPPLY_STAT_TO_600] (
  @piNum char(14),                    --单号
  @piOperGid int,                     --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vCount int  
  declare @vCardNum varchar(20)
  declare @vOper varchar(50)
  declare @vCheck int

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  declare c_Inv cursor for 
    select CardNum, CheckAbort from CRMCardApplyDtl(nolock) where Num = @piNum
  open c_Inv
  fetch next from c_Inv into @vCardNum, @vCheck
  while @@fetch_status = 0 
  begin
    if @vCheck = 1 
    begin
      select @vCount = Count(1) from CRMCardInv(nolock) where CardNum = @vCardNum and Stat = 1
      if @vCount = 0 
      begin
        set @poErrMsg = '处于已领用状态的卡号(' + Rtrim(@vCardNum) + ')不存在！'
        close c_Inv
        deallocate c_Inv
        return(1)	
      end
      update CRMCardInv set Stat = 0 where CardNum = @vCardNum
      delete from CRMCardStoreInv where CardNum = @vCardNum
    end
    fetch next from c_Inv into @vCardNum, @vCheck
  end
  close c_Inv
  deallocate c_Inv
    
  update CRMCARDAPPLY set 
    STAT = 600,
    MODIFIER = @vOper,
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_CARDAPPLY_ADD_LOG @piNum, 100, 600, @piOperGid

  return(0)
end
GO
