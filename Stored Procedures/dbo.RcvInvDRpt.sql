SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvInvDRpt] as
begin
  declare
    @id int,       @astore int,     @asettleno int,     @adate datetime,
    @bgdgid int,   @bwrh int,       @cq money,          @ct money,
    @fq money,     @ft money,       @finprc money,      @frtlprc money,
    @fdxprc money, @fpayrate money, @finvprc money,     @flstinprc money,
    @finvcost money, @MSD int

  declare c_invdrpt cursor for
    select ID, ASTORE, ASETTLENO, ADATE, BGDGID, BWRH, CQ, CT, FQ, FT,
    FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST
    from NINVDRPT(nolock) where type=1
  open c_invdrpt
  fetch next from c_invdrpt into
    @id, @astore, @asettleno, @adate, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
    @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
  while @@fetch_status = 0
  begin
--    select @goon = 1
    select @bgdgid = (select LGID from GDXLATE where NGID = @bgdgid)
    if @bgdgid is null
    begin
      update NINVDRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NINVDRPT.ID = @id
      fetch next from c_invdrpt into
         @id, @astore, @asettleno, @adate, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
         @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
      continue
    end
    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --
    begin transaction
    /* 复制到或更新INVDRPT */
    if exists (select * from INVDRPT
    where ADATE = @adate and BGDGID = @bgdgid  AND
          BWRH=@bwrh AND  ASETTLENO = @asettleno  AND ASTORE = @astore
    )
    begin
      delete from INVDRPT
      where ADATE = @adate and BGDGID = @bgdgid AND
          BWRH=@bwrh AND  ASETTLENO = @asettleno  AND ASTORE = @astore
    end
    insert into INVDRPT
    (ASTORE, ASETTLENO, ADATE, BGDGID, BWRH, CQ, CT, FQ, FT,
    FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST, LSTUPDTIME)
    values
    (@astore, @asettleno, @adate, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
    @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost, getdate())
    if @@error <> 0
    begin
      rollback transaction
      fetch next from c_invdrpt into
        @id, @astore, @asettleno, @adate, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
        @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
      continue
    end
    /* 删除NINVDRPT */
    delete from NINVDRPT where ID = @id
    commit transaction

    fetch next from c_invdrpt into
      @id, @astore, @asettleno, @adate, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
      @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
  end
  close c_invdrpt
  deallocate c_invdrpt
end
GO
