SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_to110]
(
  @piNum	char(14),
  @piOper char(30),
  @poErrMsg varchar(255) output
)
as
begin
  declare @stat int
  declare @rcode varchar(18), @ret int, @aMsg varchar(255)
  select @stat = stat from gftprm where num = @piNum;
  if @stat <> 100
  begin
    set @poErrMsg = @piNum + '不是已审核单据，不能审核后作废'
    return 1
  end
  
  /*update gftprmrule set endtime = getdate(), stat = 0
  where code in (select rulecode from gftprmdtl where num = @piNum)*/

  if object_id('c_gftprmdtl') is not null deallocate c_gftprmdtl
  declare c_gftprmdtl cursor for
  select rulecode from gftprmdtl where num = @piNum
  open c_gftprmdtl
  fetch next from c_gftprmdtl into @rcode
  while @@fetch_status = 0
  begin
    exec @ret = gftprmrule_cancel @rcode, @piOper, @aMsg output
    if @ret<>0
    begin
      if @ret = 1 
        set @poErrMsg = @poErrMsg + @aMsg + char(10)
      if @ret = -1
      begin
        close c_gftprmdtl
        deallocate c_gftprmdtl
        set @poErrMsg = '作废规则['+@rcode+']发生错误'+ @aMsg
        return @ret
      end
    end 
    fetch next from c_gftprmdtl into @rcode
  end
  close c_gftprmdtl
  deallocate c_gftprmdtl

  update gftprm set stat = 110, lstupdtime = getdate() where num = @piNum;
  exec gftprm_addlog @piNum, 110,@piOper
  return 0
end
GO
