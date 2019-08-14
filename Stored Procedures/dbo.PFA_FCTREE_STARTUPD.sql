SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_FCTREE_STARTUPD] (
  @piProduct varchar(20),
  @piFuncGrp varchar(120),
  @piNodeNo varchar(64)
  )
  as
  begin
    if @piNodeNo is null 
    begin
      update FAFUNCTREELEAF set TAG = -1 where PRODUCT = @piProduct and MODULETYPE = 1
        and NODENO in (select NODENO from FAFUNCTREE where PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and NODETYPE in (-1, 0))
      update FAFUNCTREE set TAG = -1 where PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and NODETYPE in (-1, 0)
    end
    else
    begin
      update FAFUNCTREE set TAG = -1 where PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and NODETYPE in (-1, 0) and NODENO = @piNodeNo
      update FAFUNCTREELEAF set TAG = -1 where PRODUCT = @piProduct and MODULETYPE = 1 and NODENO = @piNodeNo
    end
    return(0)
  end
GO
