SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RTLPROC] (
  @buypool varchar(30)
) --with encryption
as
begin
  declare
    @sleep char(8),
    @processed int,
    @return_status int,
    @posno varchar(10),
    @DBName varchar(10)

  select @sleep = '00:00:00'
  select @DBName = DB_NAME()    --2003-06-26
  while 1 = 1
  begin
    if (select RTL from SYSTEM) = 0 break
    if @sleep <> '00:00:00' waitfor delay @sleep
    select @processed = 1
    declare c_pos cursor for
      select rtrim(NO) from WORKSTATION where STYLE in (0,5,6) and RTLPROC = 1
      for update
    open c_pos
    fetch next from c_pos into @posno
    while @@fetch_status = 0
    begin
    --      exec @return_status = POSLEGAL @posno   -- 2001.10.29
    --      if @return_status = 1
    --exec @return_status = master..xp_PosLic @DBName, @posno  --2003-06-26
      set @return_status=0
      if (@return_status = 0) and (select rtlproc from workstation where no = @posno and style in (0,5,6) )=1  /*2003-09-09*/
      begin
        /*零售数据*/
        execute @return_status = POSPROC @buypool, @posno
        if @return_status = 0 select @processed = 0

        /*预售数据*/
        execute @return_status = PreSaleProc @buypool, @posno
        if @return_status = 0 select @processed = 0
      end
      if (select RTL from SYSTEM) = 0 break

      fetch next from c_pos into @posno
    end
    close c_pos
    deallocate c_pos
    if @processed = 0
      select @sleep = '00:00:10'
    else
      select @sleep = '00:00:00'
  end
end
GO
