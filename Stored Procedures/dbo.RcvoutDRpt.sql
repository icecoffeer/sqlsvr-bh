SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvoutDRpt] as
begin
  declare
    @ID   INT,   @ASTORE  INT,  @ASETTLENO INT,   @ADATE DATETIME ,     @BGDGID INT,
    @BWRH INT,   @BCSTGID INT,  @DQ1     MONEY,   @DQ2   MONEY    ,     @DQ3  MONEY,
    @DQ4  MONEY, @DQ5 MONEY,  @DQ6  MONEY,    @DQ7   MONEY    ,     @DT1  MONEY ,
    @DT2  MONEY, @DT3 MONEY,  @DT4  MONEY,    @DT5   MONEY    ,     @DT6  MONEY ,
    @DT7  MONEY, @DT91  MONEY,  @DT92 MONEY,    @DI1   MONEY    ,     @DI2  MONEY ,
    @DI3  MONEY, @DI4 MONEY,  @DI5  MONEY,    @DI6   MONEY    ,     @DI7  MONEY ,
    @DR1  MONEY, @DR2 MONEY,  @DR3  MONEY,    @DR4   MONEY    ,     @DR5  MONEY ,
    @DR6  MONEY, @DR7 MONEY,  @MSD    int


  declare c_outdrpt cursor for
     select id,astore,asettleno,adate,bgdgid,bwrh,bcstgid,dq1,dq2,dq3,dq4,dq5,dq6,
     dq7,dt1,dt2,dt3,dt4,dt5,dt6,dt7,dt91,dt92,di1,di2,di3,di4,di5,di6,di7,dr1,dr2,
     dr3,dr4,dr5,dr6,dr7
     from noutdrpt where type=1

  open c_outdrpt
  fetch next from c_outdrpt into
    @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
    @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
    @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NOUTDRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NOUTDRPT.ID = @ID
      fetch next from c_outdrpt into
         @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
         @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
         @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7
      continue
    end

    select @BCSTGID = (select LGID from CLNXLATE where NGID=@BCSTGID)
    if @BCSTGID is null
    begin
       update noutdrpt set nstat=1,nnote = '客户不存在'
          where noutdrpt.id=@id
      fetch next from c_outdrpt into
          @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
          @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
          @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7
       continue
    end

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --

    begin transaction
    /* 复制到或更新outDRPT */
    if exists (select * from OUTDRPT
    where ADATE = @ADATE
      and BGDGID = @BGDGID
      and BCSTGID=@BCSTGID
      and bwrh=@bwrh
      and ASETTLENO = @ASETTLENO
      and ASTORE = @ASTORE )
    begin
      delete from OUTDRPT
       where ADATE = @ADATE
         and BGDGID = @BGDGID
         and BCSTGID=@BCSTGID
         and bwrh=@bwrh
         and ASETTLENO = @ASETTLENO
         and ASTORE = @ASTORE
    end
    insert into OUTDRPT
    (ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,BCSTGID,DQ1,DQ2,DQ3,DQ4,DQ5,DQ6,DQ7,
     DT1,DT2,DT3,DT4,DT5,DT6,DT7,DT91,DT92,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DR1,DR2,
     DR3,DR4,DR5,DR6,DR7,LSTUPDTIME)
    VALUES
    (@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
     @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,
     @DI4,@DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,getdate())
    /* 删除NOUTDRPT */
    delete from NOUTDRPT where ID = @ID
    commit transaction

    fetch next from c_outdrpt into
      @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
      @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
      @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7
  end
  close c_outdrpt
  deallocate c_outdrpt
end
GO
