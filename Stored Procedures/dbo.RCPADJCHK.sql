SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCPADJCHK](
  @num char(10)
) with encryption as
begin
  declare
    @stat int,
    @cur_settleno int,
    @cur_date datetime,
    @wrh int,
    @client int,
    @gdgid int,
    @oqty money,
    @ototal money,
    @nqty money,
    @ntotal money,
    @inprc money,
    @rtlprc money

  select
    @stat = STAT,
    @cur_settleno = SETTLENO,
    @cur_date = convert(datetime, convert(char,getdate(),102)),
    @wrh = WRH,
    @client = CLIENT
    from RCPADJ where NUM = @num
  if @stat <> 0 begin
    raiserror('审核的不是未审核的单据', 16, 1)
    return(1)
  end
  select @cur_settleno = max(NO) from MONTHSETTLE
  update RCPADJ set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno
  where NUM = @num
  declare c_rcpadj cursor for
    select GDGID, OQTY, OTOTAL, NQTY, NTOTAL, INPRC, RTLPRC
    from RCPADJDTL where NUM = @num for update
  open c_rcpadj
  fetch next from c_rcpadj into
    @gdgid, @oqty, @ototal, @nqty, @ntotal, @inprc, @rtlprc
  while @@fetch_status = 0 begin
    /* 修改单据中的INPRC, RTLPRC为当前值 */
    select @inprc = INPRC, @rtlprc = RTLPRC
    from GOODSH where GID = @gdgid
    update RCPADJDTL set INPRC = @inprc, RTLPRC = @rtlprc
    where current of c_rcpadj
    /* 写报表 */
    insert into ZK (ADATE, ASETTLENO, BWRH, BCSTGID, BGDGID,
      YSKT_Q, YSKT_A, YSKT_I, YSKT_R) values (
      @cur_date, @cur_settleno, @wrh, @client, @gdgid,
      @nqty, @ntotal,
      (@nqty)* @inprc, (@nqty) * @rtlprc )
    fetch next from c_rcpadj into
      @gdgid, @oqty, @ototal, @nqty, @ntotal, @inprc, @rtlprc
  end
  close c_rcpadj
  deallocate c_rcpadj
end
GO
