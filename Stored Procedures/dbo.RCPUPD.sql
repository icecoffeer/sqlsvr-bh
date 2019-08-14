SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCPUPD](
  @new_num char(10)
) with encryption as
begin
  declare
    @return_status int,     @cur_date datetime,    @cur_settleno int,

    @new_settleno int,      @new_fildate datetime, @new_wrh int,
    @new_client int,        @new_checker int,      @new_amt money,
    @new_stat int,

    @old_num char(10),      @old_settleno int,     @old_fildate datetime,
    @old_wrh int,           @old_client int,       @old_amt money,
    @old_stat int,

    @max_num char(10),      @neg_num char(10),

    @line smallint,         @gdgid int,            @qty money,
    @total money,           @inprc money,          @rtlprc money,
    @fromcls char(10),      @fromnum char(10),     @fromline int,

    @npqty money,           @nptotal money

  select
    @return_status = 0
  select
    @cur_date = convert(datetime,convert(char,FILDATE,102)),
    @cur_settleno = SETTLENO,
    @new_settleno = SETTLENO,
    @new_fildate = FILDATE,
    @new_checker = CHECKER,
    @new_wrh = WRH,
    @new_client = CLIENT,
    @new_stat = STAT,
    @old_num = MODNUM
    from RCP where NUM = @new_num
  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据', 16, 1)
    return(1)
  end
  update RCP set STAT = 1 where NUM = @new_num

  select
    @old_settleno = SETTLENO,
    @old_fildate = FILDATE,
    @old_wrh = WRH,
    @old_client = CLIENT,
    @old_amt = AMT,
    @old_stat = STAT
    from RCP where NUM = @old_num
  if @old_stat <> 1 begin
    raiserror('被修改的不是已审核的单据', 16, 1)
    return(1)
  end
  select @max_num = max(NUM) from RCP
  execute NEXTBN @max_num, @neg_num output
  update RCP set STAT = 2 where NUM = @old_num

  /* 做一张负单 */
  insert into RCP(NUM, SETTLENO, FILDATE, FILLER, CHECKER,
    WRH, CLIENT, AMT, STAT, MODNUM, NOTE)
    values (
    @neg_num, @cur_settleno, getdate(), @new_checker, @new_checker,
    @old_wrh, @old_client, @old_amt, 3, @old_num, null)
  insert into RCPDTL(NUM, LINE, SETTLENO, GDGID, NPQTY, NPTOTAL,
    QTY, TOTAL, INPRC, RTLPRC, FROMCLS, FROMNUM, FROMLINE)
    select @neg_num, LINE, @cur_settleno, GDGID, NPQTY, NPTOTAL,
    -QTY, -TOTAL, GOODSH.INPRC, GOODSH.RTLPRC, FROMCLS, FROMNUM, FROMLINE
    from RCPDTL,GOODSH where NUM = @old_num and GDGID = GOODSH.GID
  /* 处理旧单 */
  declare c_pay cursor for
    select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, FROMCLS, FROMNUM, FROMLINE
    from RCPDTL where NUM = @old_num
  open c_pay
  fetch next from c_pay into
    @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  while @@fetch_status = 0 begin
    /* 写报表 */
    select @inprc = INPRC, @rtlprc = RTLPRC
    from GOODSH where GID = @gdgid
    execute @return_status = RCPDTLDLTCRT
      @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_client, @gdgid, @old_wrh, @qty, @total, @inprc, @rtlprc
    if @return_status <> 0 break
    select @qty = -@qty, @total = -@total
    execute RcpFillBack @fromcls, @fromnum, @fromline, @qty, @total
    fetch next from c_pay into
      @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  end
  close c_pay
  deallocate c_pay
  if @return_status <> 0 return(@return_status)

  /* 处理新单 */
  declare c_pay cursor for
    select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, FROMCLS, FROMNUM, FROMLINE
    from RCPDTL where NUM = @new_num
  open c_pay
  fetch next from c_pay into
    @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  while @@fetch_status = 0 begin
    /* 写报表 */
    execute @return_status = RCPDTLCHKCRT
      @cur_date, @cur_settleno, @new_fildate, @new_settleno,
      @new_client, @gdgid, @new_wrh, @qty, @total, @inprc, @rtlprc
    if @return_status <> 0 break
    execute RcpFillBack @fromcls, @fromnum, @fromline, @qty, @total
    fetch next from c_pay into
      @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  end
  close c_pay
  deallocate c_pay
  return(@return_status)
end
GO
