SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3NOTSCOREGDSCOPE_OCR]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
 declare
    @vDept varchar(20),
    @vVendor int,
    @vSort varchar(20),
    @vBrand varchar(20),
    @vGDGid int,
    @vBeginDateN DateTime,
    @vEndDateN DateTime,
    @vBeginDateO DateTime,
    @vEndDateO DateTime

  declare curDataSet cursor for
    select isnull(Dept,'') Dept, isnull(Vendor,-1) Vendor, isnull(Sort,'') Sort, isnull(Brand,'') Brand, isnull(GDGid,-1) GDGid, BeginDate, EndDate
    from PS3NOTSCOREGDSCOPEDTL(nolock)
    where Num = @Num and Cls = @Cls
  open curDataSet
  fetch next from curDataSet into @vDept, @vVendor, @vSort, @vBrand, @vGDGid, @vBeginDateN, @vEndDateN
  while @@fetch_status = 0
  begin
    --当同种类型的最新开始时间和结束时间跟原先记录有交集，删除原先的记录
    delete from PS3NOTSCOREGDSCOPEINV where isnull(Dept,'') = @vDept and  isnull(Vendor,-1) = @vVendor and isnull(Sort,'') = @vSort and isnull(Brand,'') = @vBrand and isnull(GDGid,-1) = @vGDGid and BeginDate <= @vEndDateN and EndDate >= @vBeginDateN 
    fetch next from curDataSet into @vDept, @vVendor, @vSort, @vBrand, @vGDGid, @vBeginDateN, @vEndDateN
  end
  close curDataSet
  deallocate curDataSet
  --将设置表中的值插入到当前值表
  insert into PS3NOTSCOREGDSCOPEINV(UUID, DEPT, VENDOR, SORT, BRAND, GDGID, BEGINDATE, ENDDATE, SRCNUM, SRCCLS)
  select newid(), DEPT, VENDOR, SORT, BRAND, GDGID, BEGINDATE, ENDDATE, @Num, @Cls from PS3NOTSCOREGDSCOPEDTL
  where Num = @Num and Cls = @Cls
  return(0)
end
GO
