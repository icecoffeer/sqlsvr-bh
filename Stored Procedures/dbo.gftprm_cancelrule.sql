SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_cancelrule]
(
  @piNum	char(14),
  @piCode char(30),
  @piOper char(30),
  @poErrMsg varchar(255) output
)
as
begin
  declare @cnt int, @ret int, @billstat int
  if not exists(select 1 from gftprmdtl where num = @piNum and rulecode = @piCOde)
  begin
  	set @poErrMsg = '该规则不属于这张赠品促销单据'
  	return(1)
  end
  select @billstat = stat from gftprm where num = @piNum
  exec @ret = gftprmrule_cancel @piCode, @piOper, @poErrMsg output
  if @ret = 0 
     update gftprm set lstupdtime = getdate()where num = @pinum
  if not exists(select 1 from gftprmdtl dtl, gftprmrule ru 
                where dtl.num = @pinum and dtl.rulecode = ru.code and ru.stat=1 )
  begin
     if @billstat = 100
     update gftprm set stat = 110 where num = @pinum
     if @billstat = 800
     update gftprm set stat = 810 where num = @pinum
     if @billstat = 1400
     update gftprm set stat = 810 where num = @pinum
  end
  return @ret
end
GO
