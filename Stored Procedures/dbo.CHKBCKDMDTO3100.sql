SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKBCKDMDTO3100]
(
  @piNUM CHAR(14),
  @piOPER CHAR(30),
  @piCLS CHAR(10),
  @piTOSTAT INT,
  @poMSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	if (select usergid from system) = (select SRC from bckdmd where num = @piNUM)
	begin
	  UPDATE BCKDMD SET
		 STAT = 3100,
		 LSTUPDTIME = GETDATE()
	  WHERE NUM = @piNUM
	  EXEC BCKDMDADDLOG @piNUM, 3100, '', @piOPER
	  RETURN 0
	end
	else
	begin
	  set @poMSG = '来源单位不是本单位的，不能进行待退货操作！'
	  RETURN 1
	end
END
GO
