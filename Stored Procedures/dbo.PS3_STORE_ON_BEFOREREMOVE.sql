SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_STORE_ON_BEFOREREMOVE] (
  @piGid int,
  @piOper varchar(40),
  @poErrMsg varchar(255) output
) with encryption as
begin
  declare 
    @on_beforeremove_sp varchar(500),
    @ret int
  exec PFA_REGISTER_READ_STR 'PS3\STORE\ON_BEFOREREMOVE\ON_BEFOREREMOVE_SP', @on_beforeremove_sp output
  if @on_beforeremove_sp <> ''
  begin
    exec @ret = PS3_STORE_GENSQL @on_beforeremove_sp, @piGid, @piOper, @poErrMsg output
    return @ret
  end
  else   
    return 0
end
GO
