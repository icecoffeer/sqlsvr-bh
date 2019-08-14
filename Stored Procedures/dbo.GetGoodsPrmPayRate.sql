SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsPrmPayRate]
  @store int,
  @gdgid int,
  @curtime datetime,
  @QpcStr varchar(20),
  @cDisCount money = 0,--交易折扣
  @PrmPayRate money output,
  @ErrMsg varchar(255) output
as begin
  declare @storegid int,       @sale smallint,
          @prm int,            @PayRate money,
          @Astart datetime,    @Afinish datetime

  set @ErrMsg = ''
  select @storegid = usergid from system

  if @store = @storegid
    begin
      select @prm = Promote, @PayRate = PayRate, @sale = sale from V_QPCGOODS where gid = @gdgid and QPCQPCSTR = @QpcStr
      if @sale <> 3
        begin
         set @ErrMsg = '该商品不是联销商品'
         return(1)
        end
    end
  else
    begin
      select @prm = Promote, @PayRate = PayRate, @sale = sale from V_QPCGDSTORE where storegid = @store and gdgid = @gdgid and QPCQPCSTR = @QpcStr
      if @sale <> 3
        begin
         set @ErrMsg = '该商品在对应门店不是联销商品'
         return(1)
        end
    end

  --sunya 20070520 联销率促销不再判断promote
  /*if @prm is null or @prm < 0
  begin
     set @ErrMsg = '该联销商品没有进行联销率促销'
     return(2)
  end */
 --select @PrmPayRate = @PayRate

if exists(select 1 from PayRateprice
    where gdgid = @gdgid and storegid = @store and QpcStr = @QpcStr
          and ((@curtime>=astart and @curtime <= afinish) or PayRate = -1))
  select @prmPayRate= IsNull(case PayRate when -1 then @PayRate else PayRate end,@PayRate) --考虑取消商品促销方案情况
    from PayRateprice
    where gdgid = @gdgid and storegid = @store and QpcStr = @QpcStr
          and ((@curtime>=astart and @curtime <= afinish) or PayRate = -1)
else
if exists(
  --部门条件满足
  select p.polypayrate
    from polypayrateprice p(nolock), goods g(nolock)
    where p.store = @store
    and p.astart <= @curtime
    and p.afinish >= @curtime
    and substring(g.f1, 1, len(p.dept)) = p.dept
    and g.gid = @gdgid)
begin
  declare
    @polypayrate1 decimal(24,4), @polypayrate2 decimal(24,4),
    @polypayrate3 decimal(24,4), @ocrtime1 datetime,
    @ocrtime2 datetime, @ocrtime3 datetime
  --根据审核日期来排先后，审核日期大的优先
  select @ocrtime1 = 0, @ocrtime2 = 0, @ocrtime3 = 0
  select top 1 @polypayrate1 = p.polypayrate, @ocrtime1 = p.ocrtime
    from polypayrateprice p(nolock), goods g(nolock)
    where p.store = @store
    and p.astart <= @curtime
    and p.afinish >= @curtime
    and substring(g.f1, 1, len(p.dept)) = p.dept
    and p.vendor = g.billto
    and p.brand = g.brand
    and g.gid = @gdgid
    order by ocrtime desc, len(p.dept) desc

  select top 1 @polypayrate2 = p.polypayrate, @ocrtime2 = p.ocrtime
    from polypayrateprice p(nolock), goods g(nolock)
    where p.store = @store
    and p.astart <= @curtime
    and p.afinish >= @curtime
    and substring(g.f1, 1, len(p.dept)) = p.dept
    and p.vendor = g.billto
    and p.brand is null
    and g.gid = @gdgid
    order by ocrtime desc, len(p.dept) desc

  select top 1 @polypayrate3 = p.polypayrate, @ocrtime3 = p.ocrtime
    from polypayrateprice p(nolock), goods g(nolock)
    where p.store = @store
    and p.astart <= @curtime
    and p.afinish >= @curtime
    and substring(g.f1, 1, len(p.dept)) = p.dept
    and isnull(p.vendor, 0) = 0
    and p.brand is null
    and g.gid = @gdgid
    order by ocrtime desc, len(p.dept) desc
  --如果审核时间相等，优先取部门、供应商和品牌所规定的范围较小的那个，即优先级@polypayrate1>@polypayrate2>@polypayrate3
  if @ocrtime1 >= @ocrtime2
  begin
    if @ocrtime1 >= @ocrtime3
      select @prmpayrate = @polypayrate1
    else
      select @prmpayrate = @polypayrate3
  end
  else
  begin
    if @ocrtime2 >= @ocrtime3
      select @prmpayrate = @polypayrate2
    else
      select @prmpayrate = @polypayrate3
  end
 --存在商品只符合部门条件但是却不满足具体条件,即加上供应商和品牌条件就找不到促销联销率
 if @prmpayrate is null
  select @prmpayrate = isnull(@PayRate,0)
  end else
  --added by zhangzhen 20100919--取折扣联销率-----------------------
  if exists(
    --部门条件满足
    select p.DISPAYRATE
      from DISRATEAGMINV p(nolock), goods g(nolock)
      where p.store = @store
      and p.astart <= @curtime
      and p.afinish >= @curtime
      and p.startdis <= @cDisCount
      and p.finishdis > @cDisCount
      and substring(g.f1, 1, len(p.dept)) = p.dept
      and g.gid = @gdgid)
  begin
    declare
      @dispayrate decimal(24,4)

    select top 1 @dispayrate = p.DISPAYRATE
      from DISRATEAGMINV p(nolock), goods g(nolock)
      where p.store = @store
      and p.astart <= @curtime
      and p.afinish >= @curtime
      and p.startdis <= @cDisCount
      and p.finishdis > @cDisCount
      and substring(g.f1, 1, len(p.dept)) = p.dept
      and p.vendor = g.billto
      and ((p.brand = g.brand) or p.brand is null)
      and g.gid = @gdgid
      order by p.astart desc, len(p.dept) desc

    select @prmpayrate = @dispayrate
    --存在商品只符合部门条件但是却不满足具体条件,即加上供应商和品牌条件就找不到折扣联销率
    if @prmpayrate is null
      select @prmpayrate = isnull(@PayRate,0)
  end
  --added end 100919--------------------------
  else
    select @prmPayRate=isnull(@PayRate,0)

  if @prmPayRate is not null
    return(0)
  else
  return(3)
end
GO
