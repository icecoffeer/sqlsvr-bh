SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POS_RFINF_add_BillLog]
(
	@piRFNum	varchar(10),
	@piOper		integer,
	@piNote		varchar(200)
)
as
begin
	declare @vStat int,@vLine int
	Select @vStat = Stat from RFBILL(nolock) where RFNUM = @piRFNum
	Select @vLine = IsNull(Max(ItemNo), 0) + 1
	  from RFBillLog(nolock) where RFNUM = @piRFNum
	insert into RFBillLog(RFNUM,ITEMNO,TIME,OPER,STAT,NOTE)
		values(@piRFNum,@vLine,getdate(),@piOper,@vStat,@piNote)
end
GO
