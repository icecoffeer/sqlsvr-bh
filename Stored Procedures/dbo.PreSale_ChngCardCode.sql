SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PreSale_ChngCardCode](
  @Num char(14),
  @OrigCardCode varchar(20),
  @NewCardCode varchar(20),
  @CardChngReason varchar(255),
  @CardChnger varchar(30),
  @Msg varchar(255) output
)
as
begin
	declare
	  @return_status smallint

	update PREBUY1 set
	  CARDCODE = @NewCardCode,
	  ORIGCARDCODE = @OrigCardCode,
	  CARDCHNGREASON = @CardChngReason,
	  CARDCHNGER = @CardChnger,
	  CARDCHNGTIME = getdate()
	  where NUM = @Num
  if @@rowcount = 1
  begin
		set @return_status = 0
	end
  else
	begin
		set @return_status = 1
		set @Msg = '影响行数不正确：' + convert(varchar, @@rowcount)
  end
  
  return(@return_status)
end
GO
