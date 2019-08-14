SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[prc_test1001]
as
begin
update tmp_test set id =cast(rand()*100000 as int)
end
GO
