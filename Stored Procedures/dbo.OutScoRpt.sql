SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[OutScoRpt](
	@settleno int,
	@adate datetime,
	@carrier int,
	@card int,
	@realamt money,
	@score money
) as
begin
  declare @usergid int
  if @card <> 1 begin
	select @usergid = USERGID from SYSTEM
	if exists(select 1 from SCOREINV where STORE = @usergid and CARRIER = @carrier)
	  update SCOREINV set SCORE = SCORE + @score where STORE = @usergid and CARRIER = @carrier
	else
	  insert into SCOREINV(STORE, CARRIER, SCORE) values(@usergid, @carrier, @score)

  	if exists(select 1 from SCODRPT where ADATE = @adate and BCARRIER = @carrier
		and BCARD = @card and ASTORE = @usergid and ASETTLENO = @settleno)
    	   update SCODRPT set DT1 = DT1 + @realamt, DS1 = DS1 + @score
  		where ADATE = @adate and BCARRIER = @carrier and BCARD = @card 
		and ASTORE = @usergid and ASETTLENO = @settleno
  	else
    	   insert into SCODRPT(ASTORE, ASETTLENO, ADATE, BCARRIER, BCARD, DT1, DT2, DS1, DS2)
    		values(@usergid, @settleno, @adate, @carrier, @card, @realamt, 0, @score, 0)
  end
  return(0)
end

GO
