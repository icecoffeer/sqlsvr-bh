SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Stkoutchk_SearchAlcGft](
  @Client int
)
AS
BEGIN
  declare
    @SRCNUM varchar(14),
    @GDGID int,
    @GFTGID int,
    @ALCQTY money,
    @qty money,
    @Tmp_rnt money,
    @rnt money,
    @GFTVAlUE money,
    @AlcUnit money,
    @GFTQTY money,
    @GFTLMTQTY money,
    @line int,
    @settleno int,
    @wrh int,
    @option_AlcQtyInt int,
    @LISTNO int,
    @GFTWRH int

  --清空临时表
  delete from TMPSTKOUTGFTDTL where spid = @@spid
  delete from TMPSTKOUTDTL where spid = @@spid
  delete from TMPALCGFT where spid = @@spid

  --读取HDOption
  exec OptReadInt 90, 'CanAlcQtyLmt', 0, @option_AlcQtyInt output
  
  --计算赠送额
  declare c_ALCGFT cursor for
    select SRCNUM
    from ALCGFT(nolock)
    where start <= getdate() and finish >= getdate() and SRCNUM in (select a.SRCNUM from ALCGFTDTL a(nolock), ALCGFTAGMLACDTL b(nolock) 
      where a.FLAG = 0 and a.GDGID in (select gdgid from TMPALCGFTGOODS where spid = @@spid) 
        and b.NUM = a.SRCNUM and b.STOREGID = @Client)
      group by SRCNUM

  open c_ALCGFT
  fetch next from c_ALCGFT into
    @SRCNUM
  while @@fetch_status = 0
  begin
    declare c_ALCGFTDtl cursor for
    select GDGID, ALCQTY
    from ALCGFTDTL(nolock)
    where SRCNUM = @SRCNUM and Flag = 0

    open c_ALCGFTDtl
    fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    set @rnt = 1000000
    while @@fetch_status = 0
    begin
      select @qty = IsNull(sum(qty), 0) from TMPALCGFTGOODS where spid = @@spid and gdgid = @GDGID
      --select @AlcUnit = alcqty from goods(nolock) where gid = @GDGID
      exec GetGdValue @Client, @gdgid, 'ALCQTY', @AlcUnit OUTPUT
      if @option_AlcQtyInt = 1 set @qty = floor(@qty / @AlcUnit) * @AlcUnit  --按配货单位取整
      set @Tmp_rnt = floor(@qty / @ALCQTY)
      if @Tmp_rnt < @rnt set @rnt = @Tmp_rnt
      fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    end
    close c_ALCGFTDtl
    deallocate c_ALCGFTDtl

    select @GFTVAlUE = sum((case when @rnt * GFTQTY > GFTLMTQTY then GFTLMTQTY else @rnt * GFTQTY end) * g.RTLPRC)
    from ALCGFTDTL a(nolock), goods g(nolock)
    where a.SRCNUM = @SRCNUM and a.Flag = 1 and a.GFTGID = g.gid

    if @GFTVAlUE = 0
      select @GFTVAlUE = - 1 / sum(case when @rnt * GFTQTY > GFTLMTQTY then GFTLMTQTY else @rnt * GFTQTY end)
      from ALCGFTDTL a(nolock), goods g(nolock)
      where a.SRCNUM = @SRCNUM and a.Flag = 1 and a.GFTGID = g.gid

    insert into TMPALCGFT(spid, SRCNUM, GFTVAlUE, GFTRNT)
    values (@@spid, @SRCNUM, @GFTVAlUE, @rnt)

    fetch next from c_ALCGFT into
      @SRCNUM
  end
  close c_ALCGFT
  deallocate c_ALCGFT

  --按赠送额大小匹配赠品
  set @LISTNO = 1
  declare c_ALCGFT cursor for
    select a.SRCNUM
    from ALCGFT a(nolock), TMPALCGFT t(nolock)
    where a.SRCNUM = t.SRCNUM and a.start <= getdate() and a.finish >= getdate() and t.spid = @@spid
      order by t.GFTVAlUE desc

  open c_ALCGFT
  fetch next from c_ALCGFT into
    @SRCNUM
  while @@fetch_status = 0
  begin
    --得到最大匹配数@rnt
    declare c_ALCGFTDtl cursor for
    select GDGID, ALCQTY
    from ALCGFTDTL(nolock)
    where SRCNUM = @SRCNUM and Flag = 0

    open c_ALCGFTDtl
    fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    set @rnt = 1000000
    while @@fetch_status = 0
    begin
      select @qty = IsNull(sum(qty), 0) from TMPALCGFTGOODS where spid = @@spid and gdgid = @GDGID
      --select @AlcUnit = alcqty from goods(nolock) where gid = @GDGID
      exec GetGdValue @Client, @gdgid, 'ALCQTY', @AlcUnit OUTPUT
      if @option_AlcQtyInt = 1 set @qty = floor(@qty / @AlcUnit) * @AlcUnit  --按配货单位取整
      set @Tmp_rnt = floor(@qty / @ALCQTY)
      if @Tmp_rnt < @rnt set @rnt = @Tmp_rnt
      fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    end
    close c_ALCGFTDtl
    deallocate c_ALCGFTDtl

    --扣除TMPALCGFTGOODS表数量
    declare c_ALCGFTDtl cursor for
    select GDGID, ALCQTY
    from ALCGFTDTL(nolock)
    where SRCNUM = @SRCNUM and Flag = 0

    open c_ALCGFTDtl
    fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    while @@fetch_status = 0
    begin
      update TMPALCGFTGOODS set qty = qty - @rnt * @ALCQTY where spid = @@spid and gdgid = @GDGID
      if (select qty from TMPALCGFTGOODS where spid = @@spid and gdgid = @GDGID) <= 0
        delete from TMPALCGFTGOODS where spid = @@spid and gdgid = @GDGID
      fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    end
    close c_ALCGFTDtl
    deallocate c_ALCGFTDtl

    --记录出货单赠品明细表临时表
    declare c_ALCGFTDtl cursor for
    select GDGID, ALCQTY
    from ALCGFTDTL(nolock)
    where SRCNUM = @SRCNUM and Flag = 0

    open c_ALCGFTDtl
    fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    while @@fetch_status = 0
    begin
      if (@rnt > 0)
      begin
        insert into TMPSTKOUTGFTDTL(spid, LISTNO, AGANUM, MATCHTIME, GDGID, ALCQTY, FLAG) values
        (@@spid, @LISTNO, @SRCNUM, @rnt, @GDGID, @rnt * @ALCQTY, 0)
        set @LISTNO = @LISTNO + 1
      end
      fetch next from c_ALCGFTDtl into
      @GDGID, @ALCQTY
    end
    close c_ALCGFTDtl
    deallocate c_ALCGFTDtl

    declare c_ALCGFTDtl cursor for
    select GFTGID, GFTQTY, GFTWRH
    from ALCGFTDTL(nolock)
    where SRCNUM = @SRCNUM and Flag = 1

    open c_ALCGFTDtl
    fetch next from c_ALCGFTDtl into
      @GFTGID, @GFTQTY, @GFTWRH
    while @@fetch_status = 0
    begin
      if (@rnt > 0)
      begin
        insert into TMPSTKOUTGFTDTL(spid, LISTNO, AGANUM, MATCHTIME, GFTGID, GFTQTY, GFTWRH, FLAG) values
        (@@spid, @LISTNO, @SRCNUM, @rnt, @GFTGID, @rnt * @GFTQTY, @GFTWRH, 1)
        set @LISTNO = @LISTNO + 1
      end
      fetch next from c_ALCGFTDtl into
      @GFTGID, @GFTQTY, @GFTWRH
    end
    close c_ALCGFTDtl
    deallocate c_ALCGFTDtl


    --记录配出单明细临时表的赠品
    declare c_ALCGFTDtl cursor for
    select GFTGID, GFTQTY, GFTLMTQTY, GFTWRH
    from ALCGFTDTL(nolock)
    where SRCNUM = @SRCNUM and Flag = 1

    open c_ALCGFTDtl
    fetch next from c_ALCGFTDtl into
      @GFTGID, @GFTQTY, @GFTLMTQTY, @GFTWRH
    while @@fetch_status = 0
    begin
      if (@rnt > 0) and (@GFTLMTQTY is null)
        insert into TMPSTKOUTDTL (SPID, SRCNUM, GFTGID, GFTQTY, GFTWRH)
        values(@@spid, @SRCNUM, @GFTGID, @rnt * @GFTQTY, @GFTWRH)
      else if @rnt > 0
        insert into TMPSTKOUTDTL (SPID, SRCNUM, GFTGID, GFTQTY, GFTWRH)
        values(@@spid, @SRCNUM, @GFTGID, case when @rnt * @GFTQTY > @GFTLMTQTY then @GFTLMTQTY else @rnt * @GFTQTY end, @GFTWRH)

      fetch next from c_ALCGFTDtl into
      @GFTGID, @GFTQTY, @GFTLMTQTY, @GFTWRH
    end
    close c_ALCGFTDtl
    deallocate c_ALCGFTDtl

    fetch next from c_ALCGFT into
      @SRCNUM
  end
  close c_ALCGFT
  deallocate c_ALCGFT
END
GO
