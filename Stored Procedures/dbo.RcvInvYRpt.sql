SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvInvYRpt] as
begin
  declare
    @id int,       @astore int,     @asettleno int,
    @bgdgid int,   @bwrh int,       @cq money,          @ct money,
    @fq money,     @ft money,       @finprc money,      @frtlprc money,
    @fdxprc money, @fpayrate money, @finvprc money,     @flstinprc money,
    @finvcost money, @YSD int
  declare c_invyrpt cursor for
    select ID, ASTORE, ASETTLENO, BGDGID, BWRH, CQ, CT, FQ, FT,
    FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST
    from NINVYRPT where type=1
  open c_invyrpt
  fetch next from c_invyrpt into
    @id, @astore, @asettleno, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
    @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
  while @@fetch_status = 0
  begin
    select @bgdgid = (select LGID from GDXLATE where NGID = @bgdgid)
    if @bgdgid is null
    begin
      update NINVYRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NINVYRPT.ID = @id
      fetch next from c_invyrpt into
         @id, @astore, @asettleno, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
         @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
      continue
    end

    -- add by zl 12.11
    select @YSD = isNull(YSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @YSD
    --

    begin transaction
    /* 复制到或更新INVMRPT */
    if exists (select * from INVYRPT
    where ASETTLENO = @asettleno
    and BGDGID = @bgdgid and bwrh=@bwrh and ASTORE = @astore )
    begin
      delete from INVYRPT
      where ASETTLENO = @asettleno
      and BGDGID = @bgdgid and bwrh=@bwrh and ASTORE = @astore
    end
    insert into INVYRPT
    (ASTORE, ASETTLENO, BGDGID, BWRH, CQ, CT, FQ, FT,
    FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST)
    values
    (@astore, @asettleno, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
    @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost)
    /* 删除NINVMRPT */
    delete from NINVYRPT where ID = @id
    commit transaction

    fetch next from c_invyrpt into
      @id, @astore, @asettleno, @bgdgid, @bwrh, @cq, @ct, @fq, @ft,
      @finprc, @frtlprc, @fdxprc, @fpayrate, @finvprc, @flstinprc, @finvcost
  end
  close c_invyrpt
  deallocate c_invyrpt
end
GO
