SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[STARTHD31] as
begin
  delete from HD31
  insert into HD31 (run, rtl) values (0, 0)
end

GO
