SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_to1400]
(
  @piNum	char(14),
  @piOper char(30),
  @poErrMsg varchar(255) output
)
as
begin
  declare @stat int
  declare @rcode varchar(18), @ret int, @aMsg varchar(255)
  select @stat = stat from gftprm where num = @piNum
  if @stat <> 800
  begin
    set @poErrMsg = @piNum + '不是已生效单据，不能终止'
    return 1
  end
  /*update gftprmrule set endtime = getdate()
  where code in (select rulecode from gftprmdtl where num = @piNum)*/
  
  if object_id('c_gftprmdtl') is not null deallocate c_gftprmdtl
  declare c_gftprmdtl cursor for
  select rulecode from gftprmdtl where num = @piNum
  open c_gftprmdtl
  fetch next from c_gftprmdtl into @rcode
  while @@fetch_status = 0
  begin
    exec @ret = gftprmrule_stop @rcode, @piOper, @aMsg output
    if @ret<>0
    begin
      if @ret = 1 
        set @poErrMsg = @poErrMsg + @aMsg + char(10)
      if @ret = -1
      begin
        close c_gftprmdtl
        deallocate c_gftprmdtl
        set @poErrMsg = '发生错误:'+@aMsg
        return @ret
      end
    end 
    fetch next from c_gftprmdtl into @rcode
  end
  close c_gftprmdtl
  deallocate c_gftprmdtl

  update gftprm set stat = 1400, lstupdtime = getdate() where num = @piNum
  exec gftprm_addlog @piNum, 1400,@piOper
end
GO
