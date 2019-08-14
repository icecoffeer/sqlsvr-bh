SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SCOPRZCHK](
	@p_num char(10)
) as
begin
  declare @stat smallint, 	@przscore money,	@oldscore money, 	
	  @carrier int, 	@card int, 		@usergid int,		
	  @settleno int,	@adate datetime,
	  @allownegscore int,	@AllowUseOtherStoreScore int,
	  @cstore int,		@cscore money,	@ccarrier int,
	  @cardstate int, 	@cardcode varchar(20), 	@msg varchar(256)

  /*2002.11.21*/
  exec OPTREADINT 0, 'AllowNegScore', 0, @allownegscore output
  exec OPTREADINT 377, 'AllowUseOtherStoreScore', 0, @AllowUseOtherStoreScore output

  if not exists(select 1 from card(nolock) where gid in (select card from scoprize(nolock) where num = @p_num))
  begin
    select @card = card from scoprize(nolock) where num = @p_num
    set @msg = '该兑奖单中的消费卡不存在。（GID = ' + convert(varchar, @card) + '）'
    raiserror(@msg, 16, 1)
    return(1)
  end
  
  select @stat = scoprize.stat, @carrier = scoprize.carrier, 
  	 @card = scoprize.card, @przscore = scoprize.przscore, 
  	 @cardstate = card.state, @cardcode = card.code
    from scoprize(nolock), card(nolock) 
  where scoprize.card = card.gid
    and num = @p_num
  if @stat <> 0 begin
    raiserror('审核的不是未审核的单据', 16, 1)
    return(1)
  end
  if @cardstate = 2
  begin
    set @msg = '兑奖单[' + @p_num + ']中的消费卡[' + @cardcode + ']已作废，不允许审核。'
    raiserror(@msg, 16, 1)
    return(1)
  end

  select @usergid = USERGID, @adate = convert(datetime, convert(char(10), getdate(), 102)) from SYSTEM
  if @AllowUseOtherStoreScore = 0
    select @oldscore = isnull(SCORE, 0) from SCOREINV where STORE = @usergid and CARRIER = @carrier
  else
    select @oldscore = sum(isnull(SCORE, 0)) from SCOREINV where CARRIER = @carrier
  if @oldscore is null select @oldscore = 0 /*2005.01.14 yaoli 修改积分兑奖单审核错误*/
    
  if @allownegscore = 0
    if @oldscore < @przscore begin
      raiserror('奖励的积分超过可奖励积分', 16, 1)
    return(1)
  end
  
  --if @AllowUseOtherStoreScore = 0
  if not exists(select 1 from scoreinv where store = @usergid and carrier = @carrier)
    insert into scoreinv values( @usergid, @carrier, 0)      /*2005.04.05*/
  update scoreinv set score = score - @przscore 
    where store = @usergid and carrier = @carrier

  /*else 
  begin
    if object_id('c_sco') is not null deallocate c_sco
    declare c_sco cursor for
        select store, score from scoreinv where carrier = @carrier
        order by store
    open c_sco
    fetch next from c_sco into @cstore, @cscore
    while @@fetch_status = 0
    begin
      if @cscore>=@przscore
      begin 
        update scoreinv set score = score - @przscore 
          where store = @cstore and carrier = @carrier
      end
      else
      begin
      	set @przscore = @przscore - @cscore
        update scoreinv set score = score - @cscore --0
          where store = @cstore and carrier = @carrier
      end      
      fetch next from c_sco into @cstore, @cscore
    end
  end
  close c_sco
  deallocate c_sco
  if (@przscore<>0) and @allownegscore
  begin
    select top 1 @cstore = store from scoreinv where carrier = @carrier
    update scoreinv set score = score - @przscore 
      where store = @cstore and carrier = @carrier
  end*/
  update SCOPRIZE set STAT = 1, CHKDATE = getdate(), OLDSCORE = @oldscore
  where NUM = @p_num
  
--记录报表
  if @card is null 
	select @card = max(gid) from CARD where CSTGID = @carrier
  if @card is null select @card = 1
  select @settleno = max(no) from monthsettle
  if exists(select 1 from SCODRPT where ADATE = @adate and BCARRIER = @carrier
	and BCARD = @card and ASTORE = @usergid and ASETTLENO = @settleno)
    update SCODRPT set DS2 = DS2 + @przscore
  	where ADATE = @adate and BCARRIER = @carrier and BCARD = @card 
	and ASTORE = @usergid and ASETTLENO = @settleno
  else
    insert into SCODRPT(ASTORE, ASETTLENO, ADATE, BCARRIER, BCARD, DT1, DT2, DS1, DS2)
    values(@usergid, @settleno, @adate, @carrier, @card, 0, 0, 0, @przscore)

  return(0)
end
GO
