SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_CLEAR_STACK] 
as
begin
  delete from TMP_PFA_REGISTER_STACK where SPID = @@spid
  insert into TMP_PFA_REGISTER_STACK (SPID, ITEMNO, FKEY)
    values (@@spid, 0, '\')
  return 0
end
GO
