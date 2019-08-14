SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_BRAND_RCV](
  @piSrc int,
  @piId int,
  @poMsg varchar(255) output
)
as
begin
  declare
    @vZBGid int,
    @nCorrCount int,
    @Code varchar(20),
    @Flag int,
    @vOption int

  select @nCorrCount = 0

  ---总部不能接收品牌
  select @vZBGid = ZBGid from FASystem(nolock) where ZBGid <> UserGid
  if @@ROWCOUNT = 0
  begin
    set @poMsg = '总部不能接收品牌资料'
    return(1)
  end
  Exec OPTREADINT 0, 'PS3_USEBRANDSORT', 0, @vOption output

  declare curNBrand cursor for
    select Code, Flag
      from NBrand(nolock)
    where Src = @piSrc and Rcv = @piId and Type = 1
  open curNBrand
  fetch next from curNBrand into @Code, @Flag
  while @@fetch_status = 0
  begin
    if @Flag = 1
    begin
      set @nCorrCount = @nCorrCount + 1
      if @vOption = 1
      begin
        ---接收删除品牌类别
        delete from PSBrandSort where BrandCode = @Code

        ---接收删除门店品牌类别
        delete from PSBrandSortStore where BrandCode = @Code
      end

      ---接收删除品牌
      delete from BrandDelete where Code = @Code
      delete from Brand where Code = @Code

      insert into BrandDelete(Code, Name, Area, TemplateGid, Creator, CreateTime, LstUpdOper, LstUpdTime, Note,
        IntroduceTime, IntroduceOper, BusinessStat, EliminateTime, BrandClass)
      select Code, Name, Area, TemplateGid, Creator, CreateTime, LstUpdOper, LstUpdTime, Note,
        IntroduceTime, IntroduceOper, BusinessStat, EliminateTime, BrandClass
      from NBrand(nolock)
      where Src = @piSrc and ID = @piId

      delete from NBrand where Src = @piSrc and ID = @piId
    end
    else
    begin
      set @nCorrCount = @nCorrCount + 1
      if @vOption = 1
      begin
        ---接收品牌类别
        delete from PSBrandSort where BrandCode = @Code

        insert into PSBrandSort(BrandCode, SortCode, AgentName, ManufactureName, ClientDesc,
          ClientSex, IntroduceEmp, IntroduceDate, Creator, CreateTime,
          LstUpdOper, LstUpdTime)
        select BrandCode, SortCode, AgentName,
          ManufactureName, ClientDesc, ClientSex, IntroduceEmp,
          IntroduceDate, Creator, CreateTime, LstUpdOper, LstUpdTime
        from NPSBrandSort(nolock)
        where Src = @piSrc and ID = @piId

        delete from NPSBrandSort where Src = @piSrc and ID = @piId

        ---接收门店品牌类别
        delete from PSBrandSortStore where BrandCode = @Code

        insert into PSBrandSortStore(BrandCode, SortCode, StoreGid, Status, StartDate, SuspendDate)
        select BrandCode, SortCode, StoreGid,
          Status, StartDate, SuspendDate
        from NPSBrandSortStore(nolock)
        where Src = @piSrc and ID = @piId

        delete from NPSBrandSortStore where Src = @piSrc and ID = @piId
      end

      ---接收品牌
      delete from Brand where Code = @Code

      insert into Brand(Code, Name, Area, TemplateGid, Creator, CreateTime, LstUpdOper, LstUpdTime, Note,
        IntroduceTime, IntroduceOper, BusinessStat, EliminateTime, BrandClass)
      select Code, Name, Area, TemplateGid, Creator, CreateTime, LstUpdOper, LstUpdTime, Note,
        IntroduceTime, IntroduceOper, BusinessStat, EliminateTime, BrandClass
      from NBrand(nolock)
      where Src = @piSrc and ID = @piId

      delete from NBrand where Src = @piSrc and ID = @piId
    end
    fetch next from curNBrand into @Code, @Flag
  end
  close curNBrand
  deallocate curNBrand

  -- add by xiexinbin 2011.02.11 接收品牌分类
  Exec PPS_BRANDCLASS_RCVALL @piSrc, @piId, @poMsg out

  set @poMsg = '接收成功: ' + Cast(@nCorrCount As varchar(10)) + '条'
  return(0)
end
GO
