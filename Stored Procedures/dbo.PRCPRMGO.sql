SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMGO](
  @p_num char(10)
) --with encryption 
as
begin
  declare
    @return_status int,
    @eon smallint,
    @storegid int,
    @usergid int,
    @cur_settleno int --2002.09.02 2002081344986

  select @cur_settleno = max(NO) from MONTHSETTLE --2002.09.02 2002081344986

  select @usergid = USERGID from SYSTEM

  select @eon = EON from PRCPRM where NUM = @p_num
  if @eon = 1
  begin
    execute @return_status = PRCPRMDTLCHK @p_num, @usergid
    if @return_status <> 0 return(@return_status)
  end

  declare c_lac cursor for
    select STOREGID from PRCPRMLACDTL
    where NUM = @p_num and STOREGID <> @usergid
      for read only
  open c_lac
  fetch next from c_lac into @storegid
  while @@fetch_status = 0
  begin
    execute @return_status = PRCPRMDTLCHK @p_num, @storegid
    if @return_status <> 0 break

    fetch next from c_lac into @storegid
  end
  close c_lac
  deallocate c_lac

  if @return_status = 0
  begin
    --更新促销单优先级数据
	  Exec @return_status = PS3_UpdPromPir 'PRCPRM', '', @p_num, 'Price', '单品'
    if @return_status <> 0
      RETURN @return_status

    update PRCPRM set STAT = 5, FILDATE = getdate(), SETTLENO = @cur_settleno where NUM = @p_num
    execute Startup_Step_PrcPrm_OnValidate @p_num
  end
end
GO
