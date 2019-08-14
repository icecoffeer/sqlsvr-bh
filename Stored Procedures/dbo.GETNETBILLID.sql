SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GETNETBILLID](
  @id int output
) with encryption as
begin
      select @id = NETBILLID from SYSTEM
  update SYSTEM set NETBILLID = NETBILLID + 1
end
GO
