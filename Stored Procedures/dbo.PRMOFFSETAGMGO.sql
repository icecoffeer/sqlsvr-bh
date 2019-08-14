SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETAGMGO]
(
  @num  varchar(14),
  @cls varchar(10),
  @toStat int,
  @Oper  varchar(30),
  @msg varchar(256) OUTPUT
) as
begin
  declare @cur_settleno int,@storegid int ,@return_status int,
    @intCoverAll int --是否整体覆盖
  select @cur_settleno = max(NO) from MONTHSETTLE

  select @intCoverAll = IsNull(COVERALL, 0) from PRMOFFSETAGM(nolock);
  declare c_lacstore cursor for select storegid from PRMOFFSETAGMLACSTORE where num = @num
  open c_lacstore
  fetch next from c_lacstore into @storegid
  while @@fetch_status = 0
  begin
    execute @return_status = PRMOFFSETAGMDTLOCR @num, @storegid, @intCoverAll
        if @return_status <> 0 break
    fetch next from c_lacstore into @storegid
  end
  close c_lacstore
  deallocate c_lacstore

  if @return_status = 0
   begin
      declare @curStat int
      select @curStat = STAT from PRMOFFSETAGM where NUM = @Num
      update PRMOFFSETAGM set STAT = 800, SETTLENO = @cur_settleno where NUM = @num
      exec PrmOffsetAgm_ADD_LOG @Num, @curStat, 800, @Oper
   end

  Return 0
end
GO
