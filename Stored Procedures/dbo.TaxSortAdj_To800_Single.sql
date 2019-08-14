SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[TaxSortAdj_To800_Single]
(
  @NUM CHAR(14),
  @STORE int,
  @USERGID int,
  @GDGID CHAR(14),
  @NewTaxSort int
)
as
begin
	if @STORE <> @USERGID
	begin  
		if not exists(select 1 from GDSTORE where GDGID = @GDGID and STOREGID = @STORE)
		begin
			INSERT INTO GDSTORE(STOREGID, GDGID, BILLTO, SALE, RTLPRC,
			INPRC, LOWINV, HIGHINV, PROMOTE, GFT, LWTRTLPRC,
			MBRPRC, DXPRC, PAYRATE, CNTINPRC, ISLTD)
			SELECT @STORE, @GDGID, BILLTO, SALE, RTLPRC,
			INPRC, LOWINV, HIGHINV, PROMOTE, GFT, LWTRTLPRC,
			MBRPRC, DXPRC, PAYRATE, CNTINPRC, ISLTD
			FROM GOODS WHERE GID = @GDGID
		end
		update GDSTORE set TaxSort = @NewTaxSort where GDGID = @GDGID and STOREGID = @STORE
    end
    else
    begin
		update GOODS set TaxSort = @NewTaxSort where GID = @GDGID
    end
end
GO
