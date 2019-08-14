SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[APPEND_HDOPTION](
    @piNO INT,
    @piCAPTION char(50),
    @piVALUE char(100),
    @piNOTE char(255)
) as
begin
    if not exists(select 1 from HDOPTION WHERE MODULENO = @piNO and OPTIONCAPTION = @piCAPTION)
    	insert into HDOPTION (MODULENO, OPTIONCAPTION, OPTIONVALUE, NOTE)
           values (@piNO, @piCAPTION, @piVALUE, @piNOTE);
end
GO
