SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DELONENMBR]
  @Store int
as
begin
  delete from NMEMBER where NType = 0 and Rcv = @Store
end
GO
