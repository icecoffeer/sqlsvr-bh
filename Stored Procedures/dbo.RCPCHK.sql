SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCPCHK](
  @num char(10),
  @errmsg varchar(200) = '' output
) --with encryption 
as
begin
  declare
    @return_status int,  @cur_date datetime,  @cur_settleno int,
    @stat int,           @fildate datetime,   @wrh int,
    @client int,         @line smallint,      @gdgid int,
    @qty money,          @total money,        @inprc money,
    @rtlprc money,       @fromcls char(10),   @fromnum char(10),
    @fromline int

  select
    @cur_date = convert(datetime, convert(char,getdate(),102)),
    @cur_settleno = SETTLENO,
    @stat = STAT,
    @fildate = FILDATE,
    @wrh = WRH,
    @client = CLIENT
    from RCP where NUM = @num
  if @stat <> 0 begin
    select @return_status = 1017
    select @errmsg = '审核的不是未审核的单据'
    raiserror(@errmsg, 16, 1)
    return(@return_status)
  end
  select @cur_settleno = max(NO) from MONTHSETTLE
  update RCP set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno
  where NUM = @num
  select @return_status = 0
  declare c_rcp cursor for
    select LINE, GDGID, QTY, TOTAL, INPRC, RTLPRC, FROMCLS, FROMNUM, FROMLINE
    from RCPDTL where NUM = @num
    for update
  open c_rcp
  fetch next from c_rcp into
    @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  while @@fetch_status = 0 begin
    /* 修改INPRC,RTLPRC为当前值 */
    select @inprc = INPRC, @rtlprc = RTLPRC
    from GOODSH where GID = @gdgid
    update RCPDTL set INPRC = @inprc, RTLPRC = @rtlprc
    where current of c_rcp
    /* 写报表 */
    execute @return_status = RCPDTLCHK
      @cur_date, @cur_settleno, @client, @gdgid, @wrh, @qty,
      @total, @inprc, @rtlprc

    /* 2000-3-24 回写导入单据 */
    execute @return_status = RcpFillBack @fromcls, @fromnum, @fromline, @qty, @total, @errmsg output

    if @return_status <> 0 break
    fetch next from c_rcp into
      @line, @gdgid, @qty, @total, @inprc, @rtlprc, @fromcls, @fromnum, @fromline
  end
  close c_rcp
  deallocate c_rcp
  if @return_status <> 0 raiserror(@errmsg, 16, 1)
  return(@return_status)
end

GO
