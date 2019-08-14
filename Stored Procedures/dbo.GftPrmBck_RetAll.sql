SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GftPrmBck_RetAll]
(
  @poErrMsg	varchar(255)	output
)
as
begin
    declare @ret int
    set @ret = 0
    update tmpgftsndsale set
      qty = 0, amt = 0
      where spid = @@spid
    return @ret
end
GO
