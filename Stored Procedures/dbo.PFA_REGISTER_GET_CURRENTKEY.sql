SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_GET_CURRENTKEY] (
  @poResult varchar(500) output
) as
begin
  declare @cnt int
  
  select @cnt = count(*) from TMP_PFA_REGISTER_STACK
    where SPID = @@spid
  if @cnt = 0
  begin
    insert into TMP_PFA_REGISTER_STACK (SPID, ITEMNO, FKEY)
      values (@@spid, 0, '\')
    set @cnt = 1
  end
  select @poResult = FKEY from TMP_PFA_REGISTER_STACK
    where SPID = @@spid and ITEMNO = @cnt - 1
  return 0
end
GO
