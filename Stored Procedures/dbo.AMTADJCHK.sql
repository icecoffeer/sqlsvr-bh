SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AMTADJCHK](
	@p_cls char(10),
	@p_num char(10))
as 
begin
   declare @wrh int,     @client int,    @stat int,     @curdate datetime,    @settleno int,
           @gdgid int,   @vendor int,    @adjamt money, @Checker int
   select @wrh = wrh, 
          @client = client, 
	  @stat = stat,
	  @curDate = convert(datetime, convert(char, getdate(), 102))
     from AmtAdj
    where cls = @p_cls
      and num = @p_num

   if @stat <> 0 begin
	raiserror('审核的不是未审核的单据', 16, 1)
	return(1)
   end

   select @settleno = max(no) from monthsettle(nolock)
   update amtAdj set stat = 1, fildate = Getdate(), settleno = @settleno, @checker = checker
           where num = @p_num
	     and cls = @p_cls
   declare c cursor for
    select gdgid, wrh, vendor, adjamt
      from  AmtAdjDtl
     where num = @p_num	
       and cls = @p_cls
   open c
   fetch next from c into @gdgid, @wrh, @vendor, @adjamt
   while @@fetch_status = 0 begin
      if @p_cls = '批发销售' 
      begin
    	  insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
		WC_Q, WC_A, WC_T, WC_I, WC_R)
		values (@curdate, @settleno, @wrh, @gdgid, @client, @Checker, @vendor,
		0, @adjamt, 0, 0, 0)
      end
      fetch next from c into @gdgid, @wrh, @vendor, @adjamt
   end
   close c
   deallocate c
end
GO
