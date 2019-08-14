SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_STORE_ON_MODIFY] (
  @piGid int,
  @piOper varchar(40),
  @poErrMsg varchar(255) output
) with encryption as
begin
  declare
    @on_modify_sp varchar(500),
    @ret int    
  exec PFA_REGISTER_READ_STR 'PS3\STORE\ON_MODIFY\ON_MODIFY_SP', @on_modify_sp output
  if @on_modify_sp <> ''
  begin
    exec @ret =  PS3_STORE_GENSQL @on_modify_sp, @piGid, @piOper, @poErrMsg output
    return @ret
  end
  else    
    return 0
end
GO
