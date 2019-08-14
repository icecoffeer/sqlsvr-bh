SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETOCR]
(
  @num  varchar(14),
  @cls varchar(10),
  @toStat int,
  @Oper  varchar(30),
  @msg varchar(256) OUTPUT
) as
begin
  declare
    @return_status int,
    @eon smallint,
    @storegid int,
    @usergid int,
    @cur_settleno int

    select @cur_settleno = max(NO) from MONTHSETTLE;

    select @eon = EON from PRMOFFSET where NUM = @num;
    /*
    if @eon = 1
      begin
           select @usergid = USERGID from SYSTEM;
           execute @return_status = PRMOFFSETDTLOCR @num, @usergid;
           if @return_status <> 0 return(@return_status);
      end
    */

    declare c_lac cursor for
        select STOREGID from PRMOFFSETLACDTL
           where NUM = @num
    for read only;
   open c_lac;
   fetch next from c_lac into @storegid;
   while @@fetch_status = 0
   begin
       execute @return_status = PRMOFFSETDTLOCR @num, @storegid;
       if @return_status <> 0 break;
       fetch next from c_lac into @storegid;
   end;
   close c_lac;
   deallocate c_lac;
   if @return_status = 0
   begin
      declare @curStat int
      select @curStat = STAT from PrmOffset (nolock) where NUM = @Num
      update PRMOFFSET set STAT = 800, SETTLENO = @cur_settleno where NUM = @num;
      exec PrmOffsetADDLOG @Num, @curStat, 800, @Oper
   end
end
GO
