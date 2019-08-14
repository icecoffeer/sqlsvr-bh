SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[PS3_UPowerNotifyWriteLog]
(
  @pi_Id Varchar(60),
  @pi_Remark Varchar(255)
)
as
begin
  insert into PSUPOWERNOTIFICATIONLOG(ID, FILDATE, REMARK)
  Values (@pi_Id, Getdate(), @pi_Remark)

  Return 0
end
GO
