SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_BRAND_SEND]
(
  @piCode varchar(10),          --UUID
  @piRcvGid integer,            --接收门店
  @piOperGid integer,           --操作员
  @poErrMsg varchar(255) output --错误信息
) as
begin
  declare
    @vSrc int,
    @vID int,
    @vCount int,
    @vSortCode varchar(15),
    @UserGid int

  ---控制非总部不能发送品牌
  select @vSrc = UserGid  from FASystem(nolock) where UserGid = ZBGid
  if @@ROWCOUNT = 0
  begin
    set @poErrMsg = '非总部不能发送品牌资料'
    return(1)
  end

  ----检查对应的品牌是否有相应的类别在接收的门店生效
  select @vCount = count(1)
  from PSBrandSortStore(nolock)
  where BrandCode = @piCode and StoreGid = @piRcvGid
  if @vCount = 0
  begin
    return(0)
  end

  select @vID = max(ID) from NBRAND(nolock) where Code = @piCode and Rcv = @piRcvGid
  delete from NBrand where Code = @piCode and Rcv = @piRcvGid and Type = 0 and ID = @vID
  delete from NPSBrandSort where BrandCode = @piCode and ID = @vID
  delete from NPSBrandSortStore where BrandCode = @piCode and ID = @vID and StoreGid = @piRcvGid


  ---取得ID号
  exec @vID = SeqNextValue 'NBRAND'

  --取得system.usergid
  select @UserGid = USERGID from FASYSTEM(nolock)

  declare curNBrandSortStore cursor for
    select SortCode
    from PSBrandSortStore(nolock)
    where BrandCode = @piCode and StoreGid = @piRcvGid

  open curNBrandSortStore
  fetch next from curNBrandSortStore into @vSortCode
  while @@fetch_status = 0
  begin
    ---品牌类别
    insert into NPSBrandSort(SRC, ID, BrandCode, SortCode, AgentName,
      ManufactureName, ClientDesc, ClientSex, IntroduceEmp,
      IntroduceDate, Creator, CreateTime, LstUpdOper, LstUpdTime)
    select @vSrc, @vID, BrandCode, SortCode, AgentName,
      ManufactureName, ClientDesc, ClientSex, IntroduceEmp,
      IntroduceDate, Creator, CreateTime, LstUpdOper, LstUpdTime
    from PSBrandSort(nolock)
    where BrandCode = @piCode and SortCode = @vSortCode

    ---品牌类别门店
    insert into NPSBrandSortStore(Src, ID, BrandCode, SortCode, StoreGid,
      Status, StartDate, SuspendDate)
    select @vSrc, @vID, BrandCode, SortCode, StoreGid,
      Status, StartDate, SuspendDate
    from PSBrandSortStore(nolock)
    where BrandCode = @piCode and SortCode = @vSortCode and StoreGid = @piRcvGid

    fetch next from curNBrandSortStore into @vSortCode
  end
  close curNBrandSortStore
  deallocate curNBrandSortStore

  ---品牌
  insert into NBrand(Src, ID, Code, Name, Rcv, Type, Area, TemplateGid, Creator,
    CreateTime, LstUpdOper, LstUpdTime, Note, IntroduceTime, IntroduceOper, BusinessStat, EliminateTime, BrandClass)
  select @vSrc, @vID, Code, Name, @piRcvGid, 0, Area, TemplateGid, Creator,
    CreateTime, LstUpdOper, LstUpdTime, Note, IntroduceTime, IntroduceOper, BusinessStat, EliminateTime, BrandClass
  from Brand(nolock)
  where Code = @piCode

  return(0)
end
GO
