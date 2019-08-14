SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SCOPRZDLT](
	@p_num char(10),
	@n_oper int
) as
begin
  declare @stat smallint, 	@przscore money,	@oldscore money, 	
	  @carrier int, 	@card int, 		@usergid int,		
	  @settleno int,	@adate datetime,	@neg_num char(10),
	  @max_num char(10),	@conflict smallint

  select @stat = STAT, @carrier = CARRIER, @card = CARD, @przscore = PRZSCORE
    from SCOPRIZE where NUM = @p_num
  if @stat <> 1 begin
    raiserror('被冲单的不是已审核的单据', 16, 1)
    return(1)
  end

  /* find the @neg_num */
  select @conflict = 1, @max_num = max(num) from SCOPRIZE
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from SCOPRIZE where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end
  select @usergid = USERGID, @adate = convert(datetime, convert(char(10), getdate(), 102)) from SYSTEM
  select @oldscore = SCORE from SCOREINV
    where STORE = @usergid and CARRIER = @carrier
  if @oldscore is null select @oldscore = 0

  update SCOPRIZE set STAT = 2 where NUM = @p_num
  insert into SCOPRIZE (NUM, FILDATE, FILLER, CHKDATE, CHECKER, CARRIER, CARD, OLDSCORE, PRZSCORE, PRIZE, STAT, MODNUM, NOTE)
    select @neg_num, getdate(), @n_oper, getdate(), @n_oper, CARRIER, CARD, @oldscore, -PRZSCORE, PRIZE, 4, @p_num, NOTE
    from SCOPRIZE where NUM = @p_num
  if not exists(select 1 from scoreinv where store = @usergid and carrier = @carrier)
    insert into scoreinv values( @usergid, @carrier, 0)        /*2005.04.05*/   
  update SCOREINV set SCORE = SCORE + @przscore 
    where STORE = @usergid and CARRIER = @carrier

--记录报表
  if @card is null 
	select @card = max(gid) from CARD where CSTGID = @carrier
  select @settleno = max(no) from monthsettle
  if exists(select 1 from SCODRPT where ADATE = @adate and BCARRIER = @carrier
	and BCARD = @card and ASTORE = @usergid and ASETTLENO = @settleno)
    update SCODRPT set DS2 = DS2 - @przscore
  	where ADATE = @adate and BCARRIER = @carrier and BCARD = @card 
	and ASTORE = @usergid and ASETTLENO = @settleno
  else
    insert into SCODRPT(ASTORE, ASETTLENO, ADATE, BCARRIER, BCARD, DT1, DT2, DS1, DS2)
    values(@usergid, @settleno, @adate, @carrier, @card, 0, 0, 0, -@przscore)

  return(0)
end
GO
