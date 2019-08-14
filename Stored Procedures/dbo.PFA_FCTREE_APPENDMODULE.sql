SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_FCTREE_APPENDMODULE] (
  @piProduct varchar(20),
  @piNodeNo varchar(64),
  @piModuleNo int,
  @piModuleType int,
  @piModuleName varchar(50),
  @piOrderNum int,
  @piIsShow int,
  @poErrMsg varchar(255) output
  )
  as
  begin
    declare @Rtn int
    select @Rtn = count(1) from FAFUNCTREELEAF(nolock) where PRODUCT = @piProduct and NODENO = @piNodeNo and MODULENO = @piModuleNo
    if @Rtn = 0
      insert into FAFUNCTREELEAF (PRODUCT, NODENO, MODULENO, MODULETYPE, MODULENAME, ORDERNUM, ISSHOW, TAG) 
        values (@piProduct, @piNodeNo, @piModuleNo, @piModuleType, @piModuleName, @piOrderNum, @piIsShow, 1)
    else
      update FAFUNCTREELEAF set MODULETYPE = @piModuleType, MODULENAME = @piModuleName, ORDERNUM = @piOrderNum,
        ISSHOW = @piIsShow, TAG = 2 where PRODUCT = @piProduct and NODENO = @piNodeNo and MODULENO = @piModuleNo
    return(0)
  end
GO
