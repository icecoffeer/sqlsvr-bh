SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrmDir_ADD_LOG]
(
  @PRMSEQ int,
  @Act varchar(100),
  @Content VARCHAR(255),
  @Oper varchar(30)
) as
begin
  insert into PrmDirLOG(PRMSEQ, OPER, Action, CONTENT, Time)
  values(@PRMSEQ, @Oper, @Act, @CONTENT, Getdate());
end
GO
