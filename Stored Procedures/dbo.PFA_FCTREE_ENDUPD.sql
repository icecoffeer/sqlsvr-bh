SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_FCTREE_ENDUPD] (
  @piProduct varchar(20),
  @piFuncGrp varchar(120),
  @piNodeNo varchar(64)
  )
  as
  begin
    if @piNodeNo is null 
    begin
      update FAFUNCTREE set TAG = 0 where PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and TAG in (1, 2) and NODETYPE in (-1, 0)
      update FAFUNCTREELEAF set TAG = 0 where PRODUCT = @piProduct and TAG in (1, 2)
      delete from FAFUNCTREELEAF where TAG = -1 and PRODUCT = @piProduct and MODULETYPE = 1 
      delete from FAFUNCTREELEAF where PRODUCT = @piProduct and  NODENO in 
        (select NODENO from FAFUNCTREE where TAG = -1 and PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and NODETYPE in (-1, 0))
      delete from FAFUNCTREE where TAG = -1 and PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and NODETYPE in (-1, 0)
    end
    else
    begin
      update FAFUNCTREE set TAG = 0 where PRODUCT = @piProduct and FUNCGRP = @piFuncGrp and TAG in (1, 2) and NODETYPE in (-1, 0) and NODENO = @piNodeNo
      update FAFUNCTREELEAF set TAG = 0 where PRODUCT = @piProduct and TAG in (1, 2) and NODENO = @piNodeNo
      delete from FAFUNCTREELEAF where TAG = -1 and PRODUCT = @piProduct and MODULETYPE = 1 and NODENO = @piNodeNo
      delete from FAFUNCTREE where TAG = -1 and PRODUCT = @piProduct and NODETYPE in (-1, 0) and NODENO = @piNodeNo
    end
    return(0)
  end
GO
