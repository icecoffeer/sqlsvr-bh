SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OPTREADINT](
	@pi_moduleno int,
	@pi_caption varchar(50),
	@pi_defvalue int,
	@po_value int output)
as
begin
	select @po_value = convert(int, OPTIONVALUE)
		from HDOPTION 
		where MODULENO = @pi_moduleno and OPTIONCAPTION = @pi_caption
	if @@rowcount = 0
		set @po_value = @pi_defvalue
end
GO
