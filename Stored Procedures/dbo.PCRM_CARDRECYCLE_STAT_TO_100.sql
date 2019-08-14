SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_CARDRECYCLE_STAT_TO_100] (
  @piNum char(14),                    --单号
  @piOper varchar(30),                --操作人
  @piOperGid int,                     --操作员Gid
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare
    @vRecycleType varchar(20),
    @vCardNum varchar(20),
    @vCardType varchar(10),
    @vSettleNo int,
    @vBoxNum varchar(32),
    @vBoxNumStat int,
    @vBoxNumStatName varchar(20),
    @vBalance money,
    @vCardCost money,
    @vParValue money,
    @vStoreGid int,
    @vCount int,
    @vRtn int,
    @vCarrier int

  --得到总部Gid
  select @vStoreGid = UserGid from FASystem(nolock)

  select @vRecycleType = RecycleType from CRMCardRecycle(nolock) where Num = @piNum
  if @@rowcount = 0 
  begin
    set @poErrMsg = '找不到单号为 ' + @piNum + ' 的发卡回退单'
    return(1)
  end

  declare c_CardNum cursor for
      select distinct a.CardNum, b.Code
      from CRMCardRecycleDtl a (nolock), CRMCardType b (nolock)
      where a.Num = @piNum
      and a.CardType = ltrim(rtrim(b.Name)) + '[' + ltrim(rtrim(b.Code)) + ']'

  --处理发卡回退单明细
  open c_CardNum
  fetch next from c_CardNum into @vCardNum, @vCardType
  while @@fetch_status = 0 
  begin
    --检查卡号是否在发卡回退当前值表中存在，存在，则给出提示
    --根据回收类型检查录入的卡号在卡盒中是否存在。回收类型为卡类型，若在卡盒中存在，则给出提示；
    --回收类型为卡盒，若在卡盒中不存在，则给出提示。
    select @vCount = count(1) from CRMCardRecycleInv where CardNum = @vCardNum
    if @vCount <> 0
    begin
      set @poErrMsg = '卡号: ' + @vCardNum + '已被发卡回退，不允许重复回退！'
      set @vRtn = 1
      break
    end

    select @vCount = count(1) from CRMCardBox a, CRMCardBoxDtl b, CRMBoxInvStat c
    where a.BoxNum = b.BoxNum and a.State = c.Stat and b.CardNum = @vCardNum

    select @vBoxNum = a.BoxNum, @vBoxNumStat = a.State, @vBoxNumStatName = c.Name from CRMCardBox a, CRMCardBoxDtl b, CRMBoxInvStat c
    where a.BoxNum = b.BoxNum and a.State = c.Stat and b.CardNum = @vCardNum

    if @vRecycleType = '卡类型'
    begin
      if @vCount <> 0
      begin
        set @poErrMsg = '回退类型为卡类型,但卡号: ' + @vCardNum + ' 在卡盒里存在！'
        set @vRtn = 1
        break
      end
    end
    else if @vRecycleType = '卡盒'
    begin
      if @vCount = 0
      begin
        set @poErrMsg = '回退类型为卡盒,但卡号: ' + @vCardNum + ' 在卡盒里不存在！'
        set @vRtn = 1
        break
      end

      if (@vBoxNumStat = 2) or (@vBoxNumStat = 3)
      begin
        set @poErrMsg = '回退类型为卡盒,但卡号:' + @vCardNum + '所在的卡盒:' + @vBoxNum + '状态为' + @vBoxNumStatName + '，不允许发卡回退！'
        set @vRtn = 1
        break
      end
    end

    --检查每张卡的数据库余额+卡成本是否等于该卡卡类型面额,如果存在不等的卡,则系统给出提示信息.
    select @vBalance = a.Balance, @vCarrier = Carrier, @vParValue = b.ParValue, @vCardCost = b.CardCost from CRMCardH a, CRMCardType b
    where a.CardType = b.Code and a.CardNum = @vCardNum

    if @vBalance + @vCardCost <> @vParValue
    begin
      set @poErrMsg = '卡号:' + @vCardNum + '的余额为' + convert(varchar(10), @vBalance + @vCardCost) + '与该卡面额' + convert(varchar(10), @vParValue) + '不等，不允许发卡回退！'
      set @vRtn = 1
      break
    end

    --回收类型为"卡类型"
    if @vRecycleType = '卡类型'
    begin
      --减少总部 可使用 增加 已发卡
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, 600, 500, @piOper, '可使用减少，已发卡增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --减少总部 已发卡 增加已制卡
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, 500, 400, @piOper, '已发卡减少，已制卡增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --减少总部 已制卡 增加已入库
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, 400, 200, @piOper, '已制卡减少，已入库增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --删除CRMCardInv表中对应数据
      delete from CRMCardInv where CardNum = @vCardNum
    end
    else if @vRecycleType = '卡盒'
    begin
      --增加总部 可使用
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, -1, 600, @piOper, '可使用增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --减少总部 可使用 增加 已发卡
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, 600, 500, @piOper, '可使用减少，已发卡增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --减少总部 已发卡 增加已制卡
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, 500, 400, @piOper, '已发卡减少，已制卡增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --减少总部 已制卡 增加已入库
      exec @vCount = PCRM_CardTypeSubjectInv_UPDINV @vStoreGid, @vCardType, -1, 1, 400, 200, @piOper, '已制卡减少，已入库增加', @poErrMsg output
      if @vCount <> 0 
      begin
        set @vRtn = 1
        break
      end

      --删除盒明细数据，删除卡盒的数据，删除CRMCardInv
      delete from CRMCardBoxDtl where BoxNum = @vBoxNum and CardNum = @vCardNum
      update CRMCardBox set Capacity = Capacity - 1, TotalBalance = TotalBalance - ParValue - CardCost, TotalCardCost = TotalCardCost - CardCost where BoxNum = @vBoxNum
      --记录卡盒明细日志
      insert into CRMCardBoxCardLog(BoxNum, CardNum, Opertime, Oper, Store, Emp, Note, BillNum, Carrier)
      values(@vBoxNum, @vCardNum, getdate(), @piOper, @vStoreGid, 0, '发卡回退', @piNum, @vCarrier)

      select @vCount = count(1) from CRMCardBoxDtl(nolock) where BoxNum = @vBoxNum
      if @vCount = 0
      begin
        --记录卡盒完成回退日志
        insert into CRMCardBoxLog(BoxNum, OperTime, Oper, Store, Note, BillNum)
        values(@vBoxNum, getdate(), @piOper, @vStoreGid, '发卡回退完成', @piNum)
      end

      delete from CRMCardInv where CardNum = @vCardNum
    end
    --插入发卡回退当前值表
    insert into CRMCARDRECYCLEINV(CardNum, CardType, Balance, BoxNum, IsCardClean, LstupdTime)
    values(@vCardNum, @vCardType, @vBalance, @vBoxNum, '否', getdate())

    fetch next from c_CardNum into @vCardNum, @vCardType
  end
  close c_CardNum
  deallocate c_CardNum

  if @vRtn <> 0
    return(1)

  --更新发卡回退单主表
  select @vSettleNo = Max(No) from MonthSettle(nolock)
  update CRMCardRecycle set Stat = 100, SettleNo = @vSettleNo, Checker = @piOper, ChkDate = getdate(), Modifier = @piOper, LstUpdTime = getdate() where Num = @piNum

  --记录相关日志
  exec PCRM_CARDRECYCLE_ADD_LOG @piNum, 0, 100, @piOper
  return(0)
end
GO
