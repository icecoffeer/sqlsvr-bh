SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CALCPRMBANLAN](
	@CLS CHAR(10),
	@ASETTLENO INT,
	@ADATE DATETIME,
	@BGDGID INT,
	@BWRH	INT,
	@BCSTGID INT,
	@DQ	MONEY,
	@PPRC	MONEY,
	@IPRC	MONEY
)AS BEGIN
	declare @astore int
	select @astore = usergid from system

	if not exists(select * from PRMBANLAN
		WHERE ADATE = @ADATE AND BGDGID = @BGDGID AND BCSTGID = @BCSTGID AND BWRH = @BWRH
			AND ASETTLENO = @ASETTLENO AND ASTORE = @ASTORE)
	INSERT INTO PRMBANLAN(ASTORE, ASETTLENO, ADATE, BGDGID, BWRH, BCSTGID)
		VALUES(@ASTORE, @ASETTLENO, @ADATE, @BGDGID, @BWRH, @BCSTGID)

	if @CLS = '零售'
		update PRMBANLAN SET
			DQ1 = DQ1 + @DQ,
			DI1 = DI1 + @DQ * @IPRC,
			DP1 = DP1 + @DQ * @PPRC
		WHERE ADATE = @ADATE AND BGDGID = @BGDGID AND BCSTGID = @BCSTGID
		AND BWRH = @BWRH AND ASETTLENO = @ASETTLENO AND ASTORE = @ASTORE
	ELSE IF @CLS = '批发'
		update PRMBANLAN SET
			DQ2 = DQ2 + @DQ,
			DI2 = DI2 + @DQ * @IPRC,
			DP2 = DP2 + @DQ * @PPRC
		WHERE ADATE = @ADATE AND BGDGID = @BGDGID AND BCSTGID = @BCSTGID
		AND BWRH = @BWRH AND ASETTLENO = @ASETTLENO AND ASTORE = @ASTORE
	ELSE IF @CLS = '零售退'
		update PRMBANLAN SET
			DQ3 = DQ3 + @DQ,
			DI3 = DI3 + @DQ * @IPRC,
			DP3 = DP3 + @DQ * @PPRC
		WHERE ADATE = @ADATE AND BGDGID = @BGDGID AND BCSTGID = @BCSTGID
		AND BWRH = @BWRH AND ASETTLENO = @ASETTLENO AND ASTORE = @ASTORE
	ELSE IF @CLS = '批发退'
		update PRMBANLAN SET
			DQ4 = DQ4 + @DQ,
			DI4 = DI4 + @DQ * @IPRC,
			DP4 = DP4 + @DQ * @PPRC
		WHERE ADATE = @ADATE AND BGDGID = @BGDGID AND BCSTGID = @BCSTGID
		AND BWRH = @BWRH AND ASETTLENO = @ASETTLENO AND ASTORE = @ASTORE

END
GO
