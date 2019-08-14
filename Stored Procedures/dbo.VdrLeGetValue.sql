SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VdrLeGetValue](
  @piVdrGid int,
  @piSort char(13), --部门代码
  @piBrand char(10),
  @poPayRate decimal(24,4) output,
  @poSortCode char(13) output,
  @poShopNo char(30) output
)as
begin
  declare
    @vParentCode char(13),
    @vSort char(13),
    @vDepth int,
    @vPayRate decimal(24,4),
    @vSortCode char(13),
    @vShopNo char(30)

  select @poPayRate = 0, @poSortCode = '', @poShopNo = ''

  --创建临时表，用来保存传入的部门代码以及所有它的上级代码。

  if object_id('tempdb..#VdrLeSortList') is not null
    drop table #VdrLeSortList
  create table #VdrLeSortList(CODE char(13), DEPTH int)

  select @vSort = CODE, @vParentCode = PARENTCODE, @vDepth = DEPTH
    from DEPT(nolock)
    where CODE = @piSort
  while @@rowcount = 1
  begin
    insert into #VdrLeSortList(CODE, DEPTH)
      values(@vSort, @vDepth)

    select @vSort = CODE, @vParentCode = PARENTCODE, @vDepth = DEPTH
      from DEPT(nolock)
      where CODE = @vParentCode
  end

  --声明并打开游标。退出前需要关闭并释放游标。

  declare c_VdrLeSortList scroll cursor for
    select CODE from #VdrLeSortList(nolock)
    order by DEPTH desc
  open c_VdrLeSortList

  --VDRLESSORTBRANDINV

  if @poPayRate = 0 or @poSortCode = '' or @poShopNo = ''
  begin
    fetch first from c_VdrLeSortList into @vSort
    while @@fetch_status = 0 and (@poPayRate = 0 or @poSortCode = '' or @poShopNo = '')
    begin
      select @vPayRate = PAYRATE, @vSortCode = SORTCODE, @vShopNo = SHOPNO
        from VDRLESSORTBRANDINV(nolock)
        where VDRGID = @piVdrGid
        and SORT = @vSort --部门代码，不是接口传入的参数
        and BRAND = @piBrand
      if @@rowcount = 1
      begin
        if @poPayRate = 0 and @vPayRate <> 0
          set @poPayRate = @vPayRate
        if @poSortCode = '' and isnull(rtrim(@vSortCode), '') <> ''
          set @poSortCode = rtrim(@vSortCode)
        if @poShopNo = '' and isnull(rtrim(@vShopNo), '') <> ''
          set @poShopNo = rtrim(@vShopNo)
      end
      fetch next from c_VdrLeSortList into @vSort
    end
  end

  --VDRLESSORTDINV

  if @poPayRate = 0 or @poShopNo = ''
  begin
    fetch first from c_VdrLeSortList into @vSort
    while @@fetch_status = 0 and (@poPayRate = 0 or @poShopNo = '')
    begin
      select @vPayRate = PAYRATE, @vShopNo = SHOPNO
        from VDRLESSORTDINV(nolock)
        where VDRGID = @piVdrGid
        and SORT = @vSort --部门代码，不是接口传入的参数
      if @@rowcount = 1
      begin
        if @poPayRate = 0 and @vPayRate <> 0
          set @poPayRate = @vPayRate
        if @poShopNo = '' and isnull(rtrim(@vShopNo), '') <> ''
          set @poShopNo = rtrim(@vShopNo)
      end
      fetch next from c_VdrLeSortList into @vSort
    end
  end

  --VDRLESSEEINV

  if @poPayRate = 0 or @poShopNo = ''
  begin
    select @vPayRate = PAYRATE, @vShopNo = SHOPNO
      from VDRLESSEEINV(nolock)
      where VDRGID = @piVdrGid
    if @@rowcount = 1
    begin
      if @poPayRate = 0 and @vPayRate <> 0
        set @poPayRate = @vPayRate
      if @poShopNo = '' and isnull(rtrim(@vShopNo), '') <> ''
        set @poShopNo = rtrim(@vShopNo)
    end
  end

LABEL_EXIT:
  close c_VdrLeSortList
  deallocate c_VdrLeSortList
  return 0
end
GO
