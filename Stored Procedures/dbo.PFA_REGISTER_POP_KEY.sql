SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_POP_KEY] 
as
begin
  declare @nCnt int
  select @nCnt = count(*) from TMP_PFA_REGISTER_STACK
    where SPID = @@spid
  if @nCnt > 1
    delete from TMP_PFA_REGISTER_STACK 
      where SPID = @@spid and ITEMNO = @nCnt - 1
  else
    exec PFA_REGISTER_CLEAR_STACK;
  return 0
end
GO
