SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF2_getVersion]
(
	@poVersion	varchar(10) output	/*输出：接口版本号*/
)
as
begin
	Select @poVersion = '2'
end
GO
