SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCPDLT](
  @old_num char(10),
  @new_oper int
) with encryption as
begin
  declare
    @return_status int,      @cur_date datetime,      @cur_settleno int,
    @old_settleno int,       @old_fildate datetime,   @old_wrh int,
    @old_client int,         @old_amt money,          @old_stat int,

    @max_num char(10),       @neg_num char(10),

    @line smallint,          @gdgid int,              @qty money,
    @total money,            @inprc money,            @rtlprc money,
    @fromcls char(10),       @fromnum char(10),       @fromline int

  select
    @return_status = 0,
    @cur_date = convert(datetime, convert(char, getdate(), 102))
  select
    @cur_settleno = max(NO) from MONTHSETTLE
  select
    @old_settleno = SETTLENO,
    @old_fildate = FILDATE,
    @old_wrh = WRH,
    @old_client = CLIENT,
    @old_amt = AMT,
    @old_stat = STAT
    from RCP where NUM = @old_num
  if @old_stat <> 1 begin
    raiserror('被删除的不是已审核的单据', 16, 1)
    return(1)
  end
  select @max_num = max(NUM) from RCP
  execute NEXTBN @max_num, @neg_num output
  update RCP set STAT = 2, MODNUM = @neg_num where NUM = @old_num
  /* 做一张负单 */
  insert into RCP(NUM, SETTLENO, FILDATE, FILLER, CHECKER,
    WRH, CLIENT, AMT, STAT, MODNUM, NOTE)
    values (
    @neg_num, @cur_settleno, getdate(), @new_oper,@new_oper,@old_wrh,
    @old_client, /*2002-01-07*/-@old_amt, 4, @old_num, null)
  insert into RCPDTL(NUM, LINE, SETTLENO, GDGID, NPQTY, NPTOTAL,
    QTY, TOTAL, INPRC, RTLPRC, FROMCLS, FROMNUM, FROMLINE)
    select @neg_num, LINE, @cur_settleno, GDGID, NPQTY, NPTOTAL,
    -QTY, -TOTAL, GOODSH.INPRC, GOODSH.RTLPRC, FROMCLS, FROMNUM, FROMLINE
    from RCPDTL,GOODSH where NUM = @old_num and GDGID = GOODSH.GID
  /* 处理明细 */
  declare c_rcp cursor for
    select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, FROMCLS, FROMNUM, FROMLINE
    from RCPDTL where NUM = @old_num
  open c_rcp
  fetch next from c_rcp into
    @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  while @@fetch_status = 0 begin
    /* 写报表 */
    select @inprc = INPRC, @rtlprc = RTLPRC
    from GOODSH where GID = @gdgid
    execute @return_status = RCPDTLDLTCRT
      @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_client, @gdgid, @old_wrh, @qty, @total, @inprc, @rtlprc
    if @return_status <> 0 break

    /* 2000-3-24 回写导入单据 */
    select @qty = -@qty, @total = -@total
    execute RcpFillBack @fromcls, @fromnum, @fromline, @qty, @total

    fetch next from c_rcp into
      @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  end
  close c_rcp
  deallocate c_rcp
  return(@return_status)
end
GO
