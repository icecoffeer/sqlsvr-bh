SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_FCTREE_APPENDTREE] (
  @piProduct varchar(20),
  @piNodeNo varchar(64),
  @piNodeType int,
  @piParentNo varchar(64),
  @piNodeName varchar(50),
  @piOrderNum int,
  @piIsShow int,
  @piFuncGrp varchar(120),
  @poErrMsg varchar(255) output
  )
  as
  begin
    declare @Rtn int
    select @Rtn = count(1) from FAFUNCTREE(nolock) where PRODUCT = @piProduct and NODENO = @piNodeNo
    if @Rtn = 0
      insert into FAFUNCTREE (PRODUCT, NODENO, NODETYPE, FATHERNODENO, NODENAME, ORDERNUM, ISSHOW, TAG, FUNCGRP) 
        values (@piProduct, @piNodeNo, @piNodeType, @piParentNo, @piNodeName, @piOrderNum, @piIsShow, 1, @piFuncGrp)
    else
      update FAFUNCTREE set NODETYPE = @piNodeType, FATHERNODENO = @piParentNo, NODENAME = @piNodeName, ORDERNUM = @piOrderNum,
        ISSHOW = @piIsShow, TAG = 2, FUNCGRP = @piFuncGrp where PRODUCT = @piProduct and NODENO = @piNodeNo
    return(0)  
  end
GO
