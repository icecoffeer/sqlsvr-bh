SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_remove]
(
  @piNum	char(14),
  @piOper char(30),
  @poErrMsg varchar(255) output
)
as
begin
  declare @stat int
  declare @rcode char(18)
  declare @ret int
  declare @amsg varchar(255)
  select @stat = stat from gftprm where num = @piNum;
  if @stat <> 0
  begin
    set @poErrMsg = @piNum + '不是未审核单据，不能删除'
    return 1
  end
  
  /*先删除规则*/
  if object_id('c_gftprmdtl') is not null deallocate c_gftprmdtl
  declare c_gftprmdtl cursor for
  select rulecode from gftprmdtl where num = @piNum
  open c_gftprmdtl
  fetch next from c_gftprmdtl into @rcode
  while @@fetch_status = 0
  begin
    exec @ret = gftprmrule_remove @rcode, @piOper, @amsg output
    if @ret<>0
    begin
      if @ret = 1 
        set @poErrMsg = @poErrMsg + @aMsg + char(10)
      if @ret = -1
      begin
        close c_gftprmdtl
        deallocate c_gftprmdtl
        set @poErrMsg = '删除规则['+@rcode+']发生错误:'+ @amsg
        return @ret
      end
    end 
    fetch next from c_gftprmdtl into @rcode
  end
  close c_gftprmdtl
  deallocate c_gftprmdtl

  /*删除单据*/
  delete from gftprmdtl where num = @piNum
  delete from gftprmlacdtl where num = @piNum
  delete from gftprm where num = @piNum

  return 0
end
GO
