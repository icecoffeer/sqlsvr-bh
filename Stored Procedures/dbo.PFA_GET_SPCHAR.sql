SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_GET_SPCHAR](
  @char varchar(4) output
) as  
begin
  set @char = '#||#'
end
GO
