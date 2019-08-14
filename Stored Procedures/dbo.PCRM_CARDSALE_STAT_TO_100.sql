SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDSALE_STAT_TO_100] (
  @piNum char(14),                    --单号
  @piOperGid int,                     --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vCount int  
  declare @vCardNum varchar(20)
  declare @vOper varchar(50)
  declare @vSettleNo int

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  declare c_Inv cursor for 
    select CardNum from CRMCardSaleDtl where Num = @piNum
  open c_Inv
  fetch next from c_Inv into @vCardNum
  while @@fetch_status = 0 
  begin
    select @vCount = Count(1) from CRMCardInv where CardNum = @vCardNum and Stat = 1
    if @vCount = 0 
    begin
      set @poErrMsg = '处于已领用状态的卡号(' + Rtrim(@vCardNum) + ')不存在！';
      close c_Inv
      deallocate c_Inv
      return(1)	
    end
    update CRMCardInv set Stat = 2 where CardNum = @vCardNum
    delete from CRMCardStoreInv where CardNum = @vCardNum
    fetch next from c_Inv into @vCardNum
  end
  close c_Inv
  deallocate c_Inv
    
  update CRMCARDSALE set 
    STAT = 100,
    MODIFIER = @vOper,
    LSTUPDTIME = getdate(),
    SETTLENO = @vSettleNo,
    CHECKER = @vOper,
    CHKDATE = getdate()
  where NUM = @piNum
  exec PCRM_CARDSALE_ADD_LOG @piNum, 0, 100, @piOperGid

  return(0)
end
GO
