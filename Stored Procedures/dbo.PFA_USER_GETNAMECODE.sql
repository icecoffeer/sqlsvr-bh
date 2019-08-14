SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_USER_GETNAMECODE](
  @piGID int,                     --用户GID
  @poRet varchar(30) output
) as
begin
  if exists (select 1 from EMPLOYEE(nolock) where GID = @piGID)
    select @poRet = rtrim(NAME) + '[' + rtrim(CODE) + ']'
      from EMPLOYEE(nolock) where GID = @piGID
  else
    set @poRet = ''
  return 0
end
GO
