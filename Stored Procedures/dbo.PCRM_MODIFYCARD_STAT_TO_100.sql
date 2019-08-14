SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MODIFYCARD_STAT_TO_100] (
  @piNum char(14),                    --单号
  @piOper varchar(70),                --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare 
    @vRet int,
    @vMedium varchar(10),
    @vCardNum varchar(20),
    @vBalance money,
    @vAdjust money,
    @vSettleNo int, 
    @vStore int
    
  select @vStore = Store from CRMModifyCard(nolock) where Num = @piNum
  select @vCardNum = CARDNUM from CRMMODIFYCARDDTL(nolock) where NUM = @piNum

  select @vMedium = t.MEDIUM
  from CRMCARDTYPE t(nolock), CRMCARD c(nolock)
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
    select @vBalance = Balance, @vAdjust = Adjust from CRMMODIFYCARDDTL(nolock) where NUM = @piNum   
    exec @vRet = PCRM_CARD_DEPOSIT '修正', @vCardNum, @vBalance, @vAdjust, @piOper, @vStore, @poErrMsg output
    if @vRet <> 0 
    begin
      return(1)	
    end
  end

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  update CRMMODIFYCARD set 
    STAT = 100,
    CHECKER = @piOper,
    CHKDATE = getdate(),
    MODIFIER = @piOper,
    LSTUPDTIME = getdate(),
    SETTLENO = @vSettleNo
  where NUM = @piNum
  exec PCRM_MODIFYCARD_ADD_LOG @piNum, 0, 100, @piOper

  return(0)
end
GO
