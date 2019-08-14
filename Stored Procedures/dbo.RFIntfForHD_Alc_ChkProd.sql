SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alc_ChkProd]
(
  @piPDANum varchar(40),           --PDA编号
  @piEmpCode varchar(10),          --员工代码
  @piGdInput varchar(40),          --商品条形码
  @poGdGid  int output,            --商品id
  @poGdName varchar(50) output,    --商品名称
  @poGdSpec varchar(40) output,    --商品规格
  @poAlcQty decimal(24,4) output,  --商品总配货数
  @poRecQty decimal(24,4) output,  --商品总收货数
  @poErrMsg varchar(255) output    --返回错误信息，当返回值不等于0时有效
)
as
begin
  select @poGdGid = GID from GDINPUT(NOLOCK) where CODE = @piGdInput
  if @poGdGid is null
  begin
    set @poErrMsg = '条码为 ' + @piGdInput + ' 的商品不存在'
    return(1)
  end
  else if not exists (select 1 from RF_ALCGOODS(nolock) where GDGID = @poGdGid)
  begin
    set @poErrMsg = '当前扫描的商品不在所接收的配货单中'
    return(1)
  end

  --商品信息

  select @poGdName = NAME, @poGdSpec = SPEC
    from GOODS(nolock)
    where GID = @poGdGid

  --配货数

  select @poAlcQty = isnull(sum(ALCQTY), 0)
    from RF_ALCGOODS(nolock)
    where GDGID = @poGdGid

  --已收货数，以下查询语句不必使用聚合函数，因为在插入记录时已经做了归并。

  select @poRecQty = RECQTY
    from RF_RECGOODS(nolock)
    where GDGID = @poGdGid
    and EMPCODE = @piEmpCode
    and PDANUM = @piPDANum

  return(0)
end
GO
