SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GftPrmBck_ClearTmp]
as
begin
	delete from tmpgftsndgoods where spid = @@spid
	delete from tmpgftsndsale where spid = @@spid
	delete from tmpgftsndresult where spid = @@spid
	delete from tmp_grpgftsended where spid = @@spid
	delete from tmpGftSnded where spid = @@spid
	return 0
end
GO
