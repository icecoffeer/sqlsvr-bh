SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[RcvInMRpt] as
begin
  declare
    @ID	  INT,    @ASTORE  INT,    @ASETTLENO INT,   @BGDGID INT,       @BWRH INT,
    @BVDRGID INT, @DQ1     MONEY,  @DQ2	 MONEY ,     @DQ3  MONEY,
    @DQ4  MONEY,  @DT1  MONEY ,    @DT2  MONEY,      @DT3  MONEY,	@DT4  MONEY,
    @DI1  MONEY,  @DI2  MONEY ,    @DI3  MONEY,      @DI4  MONEY, 	@DR1  MONEY,
    @DR2  MONEY,  @DR3  MONEY,     @DR4	 MONEY ,     @CQ1  MONEY,       @CQ2  MONEY,
    @CQ3  MONEY,  @CQ4  MONEY ,    @CT1  MONEY,      @CT2  MONEY,       @CT3  MONEY,
    @CT4  MONEY,  @CI1  MONEY,     @CI2  MONEY,      @CI3  MONEY,       @CI4  MONEY,
    @CR1  MONEY,  @CR2  MONEY,     @CR3  MONEY,      @CR4  MONEY,       @MSD  int


  declare c_inMrpt cursor for
     select id,astore,asettleno,BGDGID,bwrh,BVDRGID,dq1,dq2,dq3,dq4,
     dt1,dt2,dt3,dt4,di1,di2,di3,di4,dr1,dr2,dr3,dr4,cq1,cq2,cq3,cq4,
     ct1,ct2,ct3,ct4,ci1,ci2,ci3,ci4,cr1,cr2,cr3,cr4
     from ninmrpt where type =1

  open c_inMrpt
  fetch next from c_inMrpt into
    @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
    @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4,@CQ1,@CQ2,@CQ3,
    @CQ4,@CT1,@CT2,@CT3,@CT4,@CI1,@CI2,@CI3,@CI4,@CR1,@CR2,@CR3,@CR4

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NINMRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NINMRPT.ID = @ID
      fetch next from c_inMrpt into
         @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
         @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4,@CQ1,@CQ2,@CQ3,
         @CQ4,@CT1,@CT2,@CT3,@CT4,@CI1,@CI2,@CI3,@CI4,@CR1,@CR2,@CR3,@CR4
      continue
    end

    select @BVDRGID = (select lgid from vdrxlate where ngid = @BVDRGID)
    if @BVDRGID is null
    begin
       update ninmrpt set  nstat =1,nnote ='供应商不存在'
          where ninmrpt.id=@ID
       fetch next from c_inMrpt into
         @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
         @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4,@CQ1,@CQ2,@CQ3,
         @CQ4,@CT1,@CT2,@CT3,@CT4,@CI1,@CI2,@CI3,@CI4,@CR1,@CR2,@CR3,@CR4
       continue
    end

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --

    begin transaction
    /* 复制到或更新INDRPT */
    if exists (select * from INMRPT
    where ASETTLENO = @ASETTLENO  and BGDGID = @BGDGID
      and BVDRGID=@BVDRGID and BWRH=@bwrh AND ASTORE = @ASTORE
    )
    begin
      delete from INMRPT
      where ASETTLENO = @ASETTLENO  and BGDGID = @BGDGID
      and BVDRGID=@BVDRGID and BWRH=@bwrh AND ASTORE = @ASTORE
    end
    insert into INMRPT
    (ASTORE, ASETTLENO, BGDGID, BWRH,BVDRGID,DQ1,DQ2,DQ3,DQ4,
     DT1,DT2,DT3,DT4,DI1,DI2,DI3,DI4,DR1,DR2,DR3,DR4,
     CQ1,CQ2,CQ3,CQ4,CT1,CT2,CT3,CT4,CI1,CI2,CI3,CI4,
     CR1,CR2,CR3,CR4 )
    VALUES
    (@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
     @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4,
     @CQ1,@CQ2,@CQ3,@CQ4,@CT1,@CT2,@CT3,@CT4,@CI1,@CI2,@CI3,@CI4,
     @CR1,@CR2,@CR3,@CR4 )
    /* 删除NINDRPT */
    delete from NINMRPT where ID = @ID
    commit transaction
    fetch next from c_inMrpt into
       @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
       @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4,@CQ1,@CQ2,@CQ3,
       @CQ4,@CT1,@CT2,@CT3,@CT4,@CI1,@CI2,@CI3,@CI4,@CR1,@CR2,@CR3,@CR4
  end
  close c_inmrpt
  deallocate c_inmrpt
end

GO
