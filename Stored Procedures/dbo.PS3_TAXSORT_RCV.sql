SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_TAXSORT_RCV](
  @piSrc int,
  @piRcv int,
  @poMsg varchar(255) output
)
as
begin
  declare
    @nCorrCount int,
    @vGID int,
    @vCode varchar(20),
    @vName varchar(100),
    @vProvince varchar(32),
    @vFlag int,
    @vRcv int

  select @nCorrCount = 0
  select @vRcv = UserGid from FASystem(nolock)
  
  if @piRcv <> @vRcv
  begin
    Set @poMsg = '当前接受的税务信息的门店和网络表中指定的门店信息不一致' 
  end

  declare curNTaxSort cursor for
    select GID, Code, Name, Province
      from NTaxSort(nolock)
    where Src = @piSrc and Type = 1 and RCV = @piRcv 
  open curNTaxSort
  fetch next from curNTaxSort into @vGID, @vCode, @vName, @vProvince        
  while @@fetch_status = 0
  begin
    set @nCorrCount = @nCorrCount + 1
    --新增类别
    if not Exists (Select 1 From TaxSort Where GID = @vGID)
    begin
      insert into TaxSort(GID ,Code, Name, Province)
        values(@vGID, @vCode, @vName, @vProvince)
    end else
    begin
      update TaxSort set Name = @vName, Code = @vCode, Province = @vProvince 
        where GID = @vGID
    end
    fetch next from curNTaxSort into @vGID, @vCode, @vName, @vProvince
  end
  close curNTaxSort
  deallocate curNTaxSort

  delete from NTaxSort where Src = @piSrc and Type = 1 and RCV = @piRcv 
      
  set @poMsg = '接收成功: ' + Cast(@nCorrCount As varchar(10)) + '条'
  return(0)
end
GO
