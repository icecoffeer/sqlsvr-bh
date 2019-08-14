SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ADDMODULEREF] (
  @piNo INT,
  @piModuleNo INT,
  @piCaption varchar(120),
  @piVisible INT
  ) 
  as
  begin
    declare @vItem integer
    if not exists (select 1 from FAMODULEREFDEF(nolock) where NO = @piNo)
      insert into  FAMODULEREFDEF (NO, REFCAPTION, VISIBLE, IMAGEINDEX) values (@piNo, '相关功能', 1 ,0)
    if not exists(select 1 from FAMODULEREFDEFDTL(nolock) where NO = @piNo and MODULENO = @piModuleNo)
    begin
      select @vItem = isnull(max(ITEMNO), 0) from FAMODULEREFDEFDTL(nolock) where NO = @piNo
      if @vItem is null
        set @vItem = 0
      set @vItem = @vItem + 1
      insert into FAMODULEREFDEFDTL (NO, ITEMNO, MODULENO, MODULECAPTION, VISIBLE)
        values (@piNo, @vItem, @piModuleNo, @piCaption, @piVisible)
    end
    return 0
  end
GO
