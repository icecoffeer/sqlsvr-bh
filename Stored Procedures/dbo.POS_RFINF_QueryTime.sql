SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_QueryTime]
(
	@poTime		datetime output	/*输出：服务器时间*/
)
as
begin
	Select @poTime = getdate()
end
GO
