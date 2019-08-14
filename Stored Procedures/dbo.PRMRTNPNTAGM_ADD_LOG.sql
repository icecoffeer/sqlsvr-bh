SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRMRTNPNTAGM_ADD_LOG]
(
  @NUM VARCHAR(14),
  @STAT INT,
  @ACTION VARCHAR(401),
  @OPER VARCHAR(30)
) AS
BEGIN
  INSERT INTO PRMRTNPNTAGMLOG(NUM, STAT, MODIFIER, ACTION, TIME)
    VALUES(@NUM, @STAT, @OPER, @ACTION, GETDATE());
END
GO