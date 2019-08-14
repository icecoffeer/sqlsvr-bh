SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PCRM_CARDTYPESUBJECTINV_UPDINV]
(
  @piSTOREGID     int,             --门店
  @piCARDTYPE     varchar(10),     --卡类型
  @piUserWrh      int,             --员工仓位
  @piQty          int,             --数量   约束：必须大于0
  @piFromSubject  int,             --来源科目。指定该科目数量减少。传入值为 -1，表示没有科目数量减少。
  @piToSubject    int,             --目标科目。指定该科目数量增加。传入值为 -1，表示没有科目数量增加。
  @piOper         varchar(30),     --操作员工
  @piNote         varchar(255),    --库存变化说明
  @poErrMsg       varchar(255) output  --返回出错信息。
)
as
begin
  declare @vZBGid int
  declare @vUserGid int
  declare @vCount int
  declare @vQty int
  declare @vFromSubjectName varchar(30)
  declare @vToSubjectName varchar(30)
  declare @vUUID varchar(32)
  
  if @piQty <= 0 
  begin
    select @poErrMsg  = '数量不能小于等于0！'
    return(1)                  
  end
 
  select @vZBGid = ZBGid, @vUserGid = UserGid 
  from FASystem(nolock)
  
  if (@vZBGid is null) or (@vUserGid is null) 
  begin
    select @poErrMsg  = '系统数据（FASystem）配置错误！'
    return(1)
  end  

  ---来源科目
  if (@piFromSubject is not null) and (@piFromSubject <> -1) 
  begin
    ---检查来源科目
    select @vCount = count(1)
    from CRMCardTypeInvSubject(nolock)
    where Code = @piFromSubject

    if @vCount = 0
    begin      
      select poErrMsg = '来源科目：' + Convert(varchar, @piFromSubject, 6) + ' 不存在！'
      return(1)
    end 
    
    --来源科目名称
    select @vFromSubjectName = Name
    from CRMCardTypeInvSubject(nolock)
    where Code = @piFromSubject
    
    ---检查库存
    select @vCount = Count(1)
    from CRMCardTypeInvs(nolock)
    where Store = @piStoreGid and Ltrim(Rtrim(CardType)) = Ltrim(Rtrim(@piCardType)) and 
      UserWrh = @piUserWrh and Subject = @piFromSubject
    
    if @vCount = 0
    begin
      select @poErrMsg = '来源科目：' + @vFromSubjectName + '库存为0，不能做该操作。'
      return(1)
    end
    
    ---取当前库存
    select @vQty = IsNull(Sum(Qty), 0)
    from CRMCardTypeInvs(nolock)
    where Store = @piStoreGid and Ltrim(Rtrim(CardType)) = Ltrim(Rtrim(@piCardType)) and 
      UserWrh = @piUserWrh and Subject = @piFromSubject
   
    ---检查当前库存 
    if @vQty < @piQty 
    begin
      select @poErrMsg = '来源科目：' + @vFromSubjectName + '当前库存为：' + convert(varchar, @vQty, 10) + '，减少库存为：' + convert(varchar, @piQty, 10) + ' 库存不足！'
      return(1)
    end
      
    ---更新库存
    update CRMCardTypeInvs set Qty = Qty - @piQty, LstUpdTime = getdate()
    where Store = @piStoreGid and Ltrim(Rtrim(CardType)) = Ltrim(Rtrim(@piCardType)) and 
      UserWrh = @piUserWrh and Subject = @piFromSubject
      
    ---记录库存日志
    exec HD_CREATEUUID @vUUID output  
    insert into CRMCardTypeInvsLog(UUID, Store, CardType, UserWrh, Subject, OldQty, Qty, Oper, Note)
    values(@vUUID, @piStoreGid, @piCardType, @piUserWrh, @piFromSubject, @vQty, 0 - @piQty, @piOper,  @piNote)
  end
  
  ---目标科目
  if (@piToSubject is not null) and (@piToSubject <> -1)  
  begin
    ---检查科目是否存在
    select @vCount = count(1) 
    from CRMCardTypeInvSubject(nolock)
    where Code = @piToSubject

    if @vCount = 0 
    begin
      select @poErrMsg = '目标科目：' + convert(varchar,@piToSubject, 10) + ' 不存在！'
      return(1)
    end
    
    ---目标科目名称
    select @vToSubjectName = Name
    from CRMCardTypeInvSubject(nolock)
    where Code = @piToSubject
 
    ---业务逻辑检查
    if @piToSubject = 100  ---已采购
    begin
      if @vZBGid <> @piStoreGid 
      begin
        select @poErrMsg = '非总部不能做采购操作！'
        return(1)
      end

      if @piFromSubject not in (-1, 200) 
      begin
        select @poErrMsg = '目标科目为：' + @vToSubjectName + '，来源科目应该为空或已收货！'
        return(1)
      end 
    end

    if @piToSubject = 200 ---收货
    begin
      if @piFromSubject not in(100, 400)  ---已采购,已制卡(回退) 新卡 
      begin
        select @poErrMsg = '目标科目为：' + @vToSubjectName + '，来源科目必须为：' + '已采购或者已制卡！'
        return(1)
      end

      if @vZBGid <> @piStoreGid 
      begin
        select @poErrMsg = '非总部不能做收货操作！'
        return(1)
      end
    end
    
    if @piToSubject = 400 ---已制卡
    begin
      if @piFromSubject not in (-1, 200, 300, 500) 
      begin
        select @poErrMsg = '目标科目为：' + @vToSubjectName + '，来源科目必须为：' + '已收货或者空或者已回收或者已发卡！'
        return(1)
      end

      if @vZBGid <> @piStoreGid 
      begin
        select @poErrMsg = '非总部不能做制卡操作！'
        return(1)
      end
    end

    if @piToSubject = 500 ---已发卡
    begin
      if @piFromSubject not in (300, 400, 600) 
      begin
        select @poErrMsg = '目标科目为：' + @vToSubjectName + '，来源科目必须为：' + '已回收或已制卡或者可使用！'
        return(1)
      end
    end
    
    if @piToSubject = 600 
    begin
      if @piFromSubject not in (-1, 500) 
      begin
        select @poErrMsg = '目标科目为：' + @vToSubjectName + '，来源科目必须为：' + '已发卡或空！'
        return(1)
      end                    
    end
    
    select @vQty = IsNull(Sum(Qty), 0)
    from CRMCardTypeInvs(nolock)
    where Store = @piStoreGid and Ltrim(Rtrim(CardType)) = Ltrim(Rtrim(@piCardType)) and 
      UserWrh = @piUserWrh and Subject = @piToSubject

    ---更新库存
    select @vCount = count(1)
    from CRMCardTypeInvs(nolock)
    where Store = @piStoreGid and Ltrim(Rtrim(CardType)) = Ltrim(Rtrim(@piCardType)) and 
      UserWrh = @piUserWrh and Subject = @piToSubject

    if @vCount = 0 
      insert into CRMCardTypeInvs(Store, CardType, UserWrh, Subject, Qty, LstUpdTime)
      values(@piStoreGid, @piCardType, @piUserWrh, @piToSubject, @piQty, getdate())
    else
      update CRMCardTypeInvs set Qty = Qty + @piQty, LstUpdTime = getdate()
      where Store = @piStoreGid and Ltrim(Rtrim(CardType)) = Ltrim(Rtrim(@piCardType)) and 
        UserWrh = @piUserWrh and Subject = @piToSubject
      
    ---记录日志
    exec HD_CREATEUUID @vUUID output  
    insert into CRMCardTypeInvsLog(UUID, Store, CardType, UserWrh, Subject, OldQty, Qty, Oper,  Note)
    values(@vUUID, @piStoreGid, @piCardType, @piUserWrh, @piToSubject, @vQty, @piQty, @piOper, @piNote)
  end
  return(0)
end
GO
