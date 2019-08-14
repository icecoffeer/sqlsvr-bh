SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[ClnStyle_Rcv]
(
  @piSrc int,
  @piId int,
  @piOper varchar(30),
  @poMsg varchar(100) output
)
As
Begin
  Declare
    @usergid int,
    @src int,
    @code varchar(10),
    @ret smallint,
    @frcupd smallint
  
  select @usergid = usergid from system
  select @src = src,@frcupd = frcupd,@code = code from nclnstyle where src = @piSrc and id = @piId
  if @usergid = @src
  begin
    set @poMsg = '本单位产生的单据不能接收'
    return 1
  end
  if @frcupd = 0
  begin
    set @ret =0 
    select @ret=1 from clnstyle where code = @code
    if @ret = 1 
    begin
      update nclnstyle set nstat=1,nnote='本地包含相同代码的客户类型资料' where src = @piSrc and id = @piId
      return 1
    end  
  end
  delete from clnstyle where code = @code
  insert into clnstyle (code,name,outprc,creator,createtime,modifier,lstupdtime)
   select code,name,outprc,creator,createtime,@pioper,getdate()
    from nclnstyle where src = @piSrc and id = @piId
  delete from nclnstyle where src = @piSrc and id = @piId  
  return 0  
End
GO
