SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OPTREADSTR](
	@pi_moduleno int,
	@pi_caption varchar(50),
	@pi_defvalue varchar(100),
	@po_value varchar(100) output)
as
begin
	select @po_value = OPTIONVALUE
		from HDOPTION 
		where MODULENO = @pi_moduleno and OPTIONCAPTION = @pi_caption
	if @@rowcount = 0
		set @po_value = @pi_defvalue
end
GO
