SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvVdrYRpt] as
begin
  declare
    @id int,       @astore int,     @asettleno int,
    @bvdrgid int,  @bgdgid int,     @bwrh int,          @dq1 money,
    @dq2 money,    @dq3 money,      @dq4 money,         @dq5 money,
    @dq6 money,    @dt1 money,      @dt2 money,         @dt3 money,
    @dt4 money,    @dt5 money,      @dt6 money,         @dt7 money,
    @cq1 money,    @cq2 money,      @cq3 money,         @cq4 money,
    @cq5 money,    @cq6 money,      @ct1 money,         @ct2 money,
    @ct3 money,    @ct4 money,      @ct5 money,         @ct6 money,
    @ct7 money,    @ct8 money,
    @me int,       @sale smallint,  @billto int,        @wrh int,
    @oldcq3 money, @oldcq2 money ,  @oldct3 money,      @oldct2 money,
    @olddq3 money, @olddq2 money,   @olddt3 money,      @olddt2 money,
    @oldaStore int, @YSD int,       @olddi2 money,      @oldci2 money,
    @di2 money,     @ci2 money

  /* 取本店店号 */
  select @me = USERGID from SYSTEM
  /* 处理网络报表 */
  declare c_vdryrpt cursor for
    select ID, ASTORE, ASETTLENO, BVDRGID, BGDGID, BWRH,
    DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
    DT1, DT2, DT3, DT4, DT5, DT6, DT7,CQ1,CQ2,CQ3,CQ4,CQ5,CQ6,
    CT1,CT2,CT3,CT4,CT5,CT6,CT7,CT8, ci2, di2
    from NVDRYRPT where type=1
  open c_vdryrpt
  fetch next from c_vdryrpt into
    @id, @astore, @asettleno, @bvdrgid, @bgdgid, @bwrh,
    @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
    @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7,
    @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
    @CT1,@CT2,@CT3,@CT4,@CT5,@CT6,@CT7,@CT8, @ci2, @di2

  while @@fetch_status = 0
  begin
    /* 检查本地是否有商品 */
    select @bgdgid = (select LGID from GDXLATE where NGID = @bgdgid)
    if @bgdgid is null
    begin
      update NVDRYRPT set NSTAT = 1, NNOTE = '商品不存在'
           where NVDRYRPT.ID = @id
      fetch next from c_vdryrpt into
          @id, @astore, @asettleno, @bvdrgid, @bgdgid, @bwrh,
          @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
          @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7,
          @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
          @CT1,@CT2,@CT3,@CT4,@CT5,@CT6,@CT7,@CT8, @ci2, @di2
      continue
    end
    /* 检查本地是否有供应商 */
    select @bvdrgid = (select LGID from VDRXLATE where NGID = @bvdrgid)
    if @bvdrgid is null
    begin
      update NVDRYRPT set NSTAT = 1, NNOTE = '供应商不存在'
         where NVDRYRPT.ID = @id
      fetch next from c_vdryrpt into
          @id, @astore, @asettleno, @bvdrgid, @bgdgid, @bwrh,
          @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
          @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7,
          @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
          @CT1,@CT2,@CT3,@CT4,@CT5,@CT6,@CT7,@CT8, @ci2, @di2
      continue
    end
    /* 取商品信息 */
    select @sale = SALE, @billto = BILLTO, @wrh = WRH
    from GOODS where GID = @bgdgid

    --add  by zl 12.11
    select @YSD = isNull(YSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @YSD
    --

    begin transaction
    /* 复制到或更新VDRYRPT */
    select @oldaStore=astore,@oldct2=ct2,@oldct3=ct3,@oldcq2=cq2,@oldcq3=cq3,
           @olddt2=dt2,@olddt3=dt3,@olddq2=dq2,@olddq3=dq3,
           @oldci2 = ci2, @olddi2 = di2
      from vdryrpt
     where ASTORE = @astore and ASETTLENO = @asettleno
       and BVDRGID = @bvdrgid and bwrh=@bwrh and BGDGID = @bgdgid

    if @oldaStore is not null
    begin
      delete from VDRYRPT
      where ASTORE = @astore and ASETTLENO = @asettleno
        and BVDRGID = @bvdrgid and bwrh=@bwrh and BGDGID = @bgdgid
    end
    insert into VDRYRPT
    (ASTORE, ASETTLENO,  BVDRGID, BGDGID, BWRH,
    DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
    DT1, DT2, DT3, DT4, DT5, DT6, DT7,CQ1,CQ2,CQ3,CQ4,CQ5,CQ6,
    CT1,CT2,CT3,CT4,CT5,CT6,CT7,CT8, ci2, di2)
    values
    (@astore, @asettleno, @bvdrgid, @bgdgid, @bwrh,
    @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
    @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7,
    @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
    @CT1,@CT2,@CT3,@CT4,@CT5,@CT6,@CT7,@CT8, @ci2, @di2)

    /* 删除NVDRDRPT */
    delete from NVDRYRPT where ID = @id
    commit transaction

    /* 下一条记录 */
    fetch next from c_vdryrpt into
          @id, @astore, @asettleno, @bvdrgid, @bgdgid, @bwrh,
          @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
          @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7,
          @CQ1, @CQ2, @CQ3, @CQ4, @CQ5, @CQ6,
          @CT1,@CT2,@CT3,@CT4,@CT5,@CT6,@CT7,@CT8, @ci2, @di2
  end
  close c_vdryrpt
  deallocate c_vdryrpt
end
GO
