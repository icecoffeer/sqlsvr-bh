SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CanDeleteMXF] (
  @p_num varchar(14),
  @err_msg varchar(100) = '' output
) --with encryption
as
begin
	if (select batchflag from system) <> 0
	begin
		return 1
	end
	return 0
end
GO
