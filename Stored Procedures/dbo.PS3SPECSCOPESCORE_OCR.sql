SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECSCOPESCORE_OCR]
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
    @vBeginDateN DateTime,
    @vEndDateN DateTime,
    @vBeginDateO DateTime,
    @vEndDateO DateTime

  declare curDataSet cursor for
    select isnull(Dept,'') Dept, isnull(Vendor,-1) Vendor, isnull(Sort,'') Sort, isnull(Brand,'') Brand, BeginDate, EndDate
    from PS3SPECSCOPESCOREDTL(nolock)
    where Num = @Num and Cls = @Cls
  open curDataSet
  fetch next from curDataSet into @vDept, @vVendor, @vSort, @vBrand, @vBeginDateN, @vEndDateN
  while @@fetch_status = 0
  begin
    --当同种类型的最新开始时间和结束时间跟原先记录有交集，删除原先的记录
    delete from PS3SPECSCOPESCOREINV
    where isnull(Dept,'') = @vDept and isnull(Vendor,-1) = @vVendor and isnull(Sort,'') = @vSort and isnull(Brand,'') = @vBrand
      and BeginDate <= @vEndDateN and EndDate >= @vBeginDateN

    fetch next from curDataSet into @vDept, @vVendor, @vSort, @vBrand, @vBeginDateN, @vEndDateN
  end
  close curDataSet
  deallocate curDataSet
  --将设置表中的值插入到当前值表
  insert into PS3SPECSCOPESCOREINV(UUID, DEPT, VENDOR, SORT, BRAND, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE, MAXDISCOUNT,
    BEGINDATE, ENDDATE, SRCNUM, SRCCLS, DISCOUNT, DISMAXDIS, DISPREC)
  select newid(), DEPT, VENDOR, SORT, BRAND, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE, MAXDISCOUNT,
    BEGINDATE, ENDDATE, @Num, @Cls, DISCOUNT, DISMAXDIS, DISPREC
  from PS3SPECSCOPESCOREDTL
    where Num = @Num and Cls = @Cls
  insert into PS3SPECSCOPESCOREINVOUT(UUID, SUBJCODE, SUBJCLS, SRCNUM, SRCCLS)
  select newid(), SUBJCODE, SUBJCLS, @Num, @Cls from PS3SPECSCOPESCOREPROMSUBJOUTDTL
    where Num = @Num and Cls = @Cls
  --卡类型折扣率表
  If @Cls = '折扣'
  begin
    Insert Into PS3SPECSCOPESCOREINVSPECDIS(UUID, CARDTYPECODE, CARDTYPENAME, DISCOUNT, SRCNUM, SRCCLS)
    Select newid(), CARDTYPECODE, CARDTYPENAME, DISCOUNT, @Num, @Cls
    From PS3SPECSCOPESCORESPECDIS
      Where Num = @Num and Cls = @Cls
  end

  return(0)
end
GO
