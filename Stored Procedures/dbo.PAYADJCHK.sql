SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYADJCHK](
  @num char(10)
) as
begin
  declare
    @stat int,
    @cur_settleno int,
    @cur_date datetime,
    @wrh int,
    @billto int,
    @gdgid int,
    @oqty money,
    @ototal money,
    @ostotal money,
    @nqty money,
    @ntotal money,
    @nstotal money,
    @inprc money,
    @rtlprc money,
    @return_status int

  select @return_status = 0
  select
    @stat = STAT,
    @cur_settleno = SETTLENO,
    @cur_date = convert(datetime, convert(char,getdate(),102)),
    @wrh = WRH,
    @billto = BILLTO
    from PAYADJ where NUM = @num
  if @stat <> 0 begin
    raiserror('审核的不是未审核的单据', 16, 1)
    return(1)
  end
  select @cur_settleno = max(NO) from MONTHSETTLE
  update PAYADJ set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno
  where NUM = @num
  declare c_payadj cursor for
    select GDGID, OQTY, OTOTAL, OSTOTAL,
    NQTY, NTOTAL, NSTOTAL, INPRC, RTLPRC
    from PAYADJDTL where NUM = @num for update
  open c_payadj
  fetch next from c_payadj into
    @gdgid, @oqty, @ototal, @ostotal,
    @nqty, @ntotal, @nstotal, @inprc, @rtlprc
  while @@fetch_status = 0 begin
    /* 修改单据中的INPRC,RTLPRC为当前值 */
    select @inprc = INPRC, @rtlprc = RTLPRC
      from GOODSH where GID = @gdgid
    update PAYADJDTL
      set INPRC = @inprc, RTLPRC = @rtlprc
      where current of c_payadj
    /* 写报表 */
    insert into ZK (ADATE, ASETTLENO, BWRH, BVDRGID, BGDGID,
      YFKT_Q, YFKT_A, YFXT_A, YFKT_I, YFKT_R) values (
      @cur_date, @cur_settleno, @wrh, @billto, @gdgid,
      @nqty, @ntotal, @nstotal,
      (@nqty)* @inprc, (@nqty) * @rtlprc )
    if @@error <>0 
    begin
       select @return_status = 2
       break
    end

    fetch next from c_payadj into
      @gdgid, @oqty, @ototal, @ostotal,
      @nqty, @ntotal, @nstotal, @inprc, @rtlprc
  end
  close c_payadj
  deallocate c_payadj

  if @return_status <> 0 
  begin
          raiserror('写入报表失败', 16, 1)
          return(@return_status)
  end
end
GO
