SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alc_EndRecProd]
(
  @piPDANum varchar(40),           --PDA编号
  @piEmpCode varchar(10),          --员工代码
  @poErrMsg varchar(255) output    --返回错误信息，当返回值不等于0时有效
)
as
begin
  declare
    @empgid int,
    @alcNum varchar(14),
    @gdgid int,
    @recqty money,
    @alcqty money,
    @rqty money,
    @diffqty money,
    @malcnum varchar(14),
    @stkinnum char(10),
    @stkinnote varchar(100)

  --取得操作员GID。

  select @empgid = e.GID
    from EMPLOYEE e(nolock)
    where e.CODE = @piEmpCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '员工代码 ' + rtrim(@piEmpCode) + ' 无效。'
    return 1
  end

  --在调用该过程之前，RF_ALCGOODS 表中必须已经包含数据。

  if not exists(select 1 from RF_ALCGOODS(nolock))
  begin
    set @poErrMsg = '没有待收货数据。'
    return(1)
  end

  --在调用该过程之前，RF_RECGOODS 表中必须已经包含数据。

  if not exists(select 1 from RF_RECGOODS(nolock)
    where EMPCODE = @piEmpCode
    and PDANUM = @piPDANum)
  begin
    set @poErrMsg = '无可上传的收货数据。'
    return(1)
  end

  /*
  1.如果一次收多张配货单，分摊已收货数到不同的配货单上。
  2.下列游标查询语句不必使用聚合函数，因为数据在插入 RF_ALCGOODS 时，已经根据 ALCNUM 和 GDGID 进行了归并。
  */

  declare c_endAlc cursor for
    select ALCNUM, GDGID, ALCQTY, RECQTY
    from RF_ALCGOODS(nolock)
  open c_endAlc
  fetch next from c_endAlc into @alcNum, @gdgid, @alcqty, @recqty
  while @@fetch_status = 0
  begin
    set @diffqty = @alcqty - @recqty
    if @diffqty > 0
    begin
      --以下查询语句不必使用聚合函数，因为在往 RF_RECGOODS 插入记录时已经对数据做了归并。

      select @rqty = RECQTY
        from RF_RECGOODS(nolock)
        where GDGID = @gdgid
        and EMPCODE = @piEmpCode
        and PDANUM = @piPDANum

      if @@rowcount > 0 and @rqty > 0
      begin
        update RF_ALCGOODS set
          RECQTY = RECQTY + case when @diffqty >= @rqty then @rqty else @diffqty end
          where ALCNUM = @alcNum
          and GDGID = @gdgid

        update RF_RECGOODS set
          RECQTY = RECQTY - case when @diffqty >= @rqty then @rqty else @diffqty end
          where GDGID = @gdgid
          and EMPCODE = @piEmpCode
          and PDANUM = @piPDANum
      end
    end
    fetch next from c_endAlc into @alcNum, @gdgid, @alcqty, @recqty
  end
  close c_endAlc
  deallocate c_endAlc

  /*
  1.如果已收货数大于待收货数之和，将分配剩余的已收货数分摊到最后一张配货单上。
  2.以下游标查询语句不必使用聚合函数，因为在往 RF_RECGOODS 表中插入记录时，已经根据 GDGID，EMPCODE 和 PDANUM 做了归并。
  */

  declare c_rec cursor for
    select GDGID, RECQTY
    from RF_RECGOODS(nolock)
    where RECQTY > 0
    and EMPCODE = @piEmpCode
    and PDANUM = @piPDANum
  open c_rec
  fetch next from c_rec into @gdgid, @recqty
  while @@fetch_status = 0
  begin
    --RF_ALCGOODS 中必然有记录。

    select @malcnum = max(ALCNUM)
      from RF_ALCGOODS(nolock)
      where GDGID = @gdgid

    --RF_ALCGOODS 的业务主键是 ALCNUM + GDGID。

    update RF_ALCGOODS set
      RECQTY = RECQTY + @recqty
      where ALCNUM = @malcnum
      and GDGID = @gdgid

    --RF_RECGOODS 的业务主键是 GDGID + EMPCODE + PDANUM。

    update RF_RECGOODS set
      RECQTY = RECQTY - @recqty
      where GDGID = @gdgid
      and EMPCODE = @piEmpCode
      and PDANUM = @piPDANum

    fetch next from c_rec into @gdgid, @recqty
  end
  close c_rec
  deallocate c_rec

  --一段防御性代码。

  if exists(select 1 from RF_RECGOODS(nolock)
    where RECQTY > 0
    and EMPCODE = @piEmpCode
    and PDANUM = @piPDANum)
  begin
    set @poErrMsg = '分摊已收货数时出错，数量未分摊完毕。'
    return(1)
  end

  --回写配货进货单：操作员及备注。

  declare c_RF_AlcGoods cursor for
    select NUM, NOTE
    from STKIN(nolock)
    where CLS = '配货'
    and SRCNUM in (select distinct ra.ALCNUM
      from RF_ALCGOODS ra(nolock), RF_RECGOODS rr(nolock)
      where ra.GDGID = rr.GDGID
      and rr.EMPCODE = @piEmpCode
      and rr.PDANUM = @piPDANum
      and ra.RECQTY > 0)
    and SRC = (select ZBGID from SYSTEM(nolock))
    and STAT in (1, 6)
  open c_RF_AlcGoods
  fetch next from c_RF_AlcGoods into @stkinnum, @stkinnote
  while @@fetch_status = 0
  begin
    /*
    --更新操作人。

    update STKIN set
      RSR = @empgid
      where CLS = '配货'
      and NUM = @stkinnum
    */
    --更新备注。需要小心备注的长度超出范围。

    set @stkinnote = isnull(@stkinnote, '')
    if charindex('RF已收货', @stkinnote) = 0
    begin
      set @stkinnote = @stkinnote + 'RF已收货。'
      update STKIN set
        NOTE = @stkinnote
        where CLS = '配货'
        and NUM = @stkinnum
    end
    fetch next from c_RF_AlcGoods into @stkinnum, @stkinnote
  end
  close c_RF_AlcGoods
  deallocate c_RF_AlcGoods

  --清空当前RF登录用户的收货数据。

  delete from RF_RECGOODS
    where EMPCODE = @piEmpCode
    and PDANUM = @piPDANum

  return(0)
end
GO
