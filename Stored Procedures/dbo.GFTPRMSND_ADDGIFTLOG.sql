SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_ADDGIFTLOG]
(
  @piNum	char(14),
  @piGftGid	int,
  @piQty	money,
  @piOperGid	int
)
as
begin
  declare @id int
  select @id = isnull(max(id), 0) from GFTSNDLOG(nolock)
  insert into GFTSNDLOG(ID, NUM, GFTGID, QTY, ADATE, OPER)
  select @id + 1, @piNum, @piGftGid, @piQty, getdate(), rtrim(NAME) + '[' + rtrim(CODE) + ']'
  from EMPLOYEE(nolock) where GID = @piOperGid;

  return 0
end
GO
