SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvInDRpt] as
begin
  declare
    @ID   INT,   @ASTORE  INT,  @ASETTLENO INT,   @ADATE DATETIME ,     @BGDGID INT,
    @BWRH INT,   @BVDRGID INT,  @DQ1     MONEY,   @DQ2   MONEY    ,     @DQ3  MONEY,
    @DQ4  MONEY, @DT1  MONEY ,  @DT2     MONEY,   @DT3   MONEY    , @DT4  MONEY,
    @DI1  MONEY, @DI2  MONEY ,  @DI3     MONEY,   @DI4   MONEY    ,   @DR1  MONEY,
    @DR2  MONEY, @DR3  MONEY,   @DR4   MONEY,   @MSD   int


  declare c_indrpt cursor for
     select id,astore,asettleno,adate,BGDGID,bwrh,BVDRGID,dq1,dq2,dq3,dq4,
     dt1,dt2,dt3,dt4,di1,di2,di3,di4,dr1,dr2,dr3,dr4
     from nindrpt where type =1

  open c_indrpt
  fetch next from c_indrpt into
    @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
    @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NINDRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NINDRPT.ID = @ID
      fetch next from c_indrpt into
         @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
         @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4
      continue
    end

    select @BVDRGID = (select lgid from vdrxlate where ngid = @BVDRGID)
    if @BVDRGID is null
    begin
       update nindrpt set  nstat =1,nnote ='供应商不存在'
       where nindrpt.id=@ID
       fetch next from c_indrpt into
           @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
           @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4
       continue
    end

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --

    begin transaction
    /* 复制到或更新INDRPT */
    if exists (select * from INDRPT
    where ADATE = @ADATE and BGDGID = @BGDGID
    and BVDRGID=@BVDRGID and bwrh=@bwrh
    and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE )
    begin
      delete from INDRPT
         where ADATE = @ADATE and BGDGID = @BGDGID
           and BVDRGID=@BVDRGID and bwrh=@bwrh
           and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE
    end
    insert into INDRPT
    (ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,BVDRGID,DQ1,DQ2,DQ3,DQ4,
     DT1,DT2,DT3,DT4,DI1,DI2,DI3,DI4,DR1,DR2,DR3,DR4,LSTUPDTIME)
    VALUES
    (@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
     @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4,getdate())
    /* 删除NINDRPT */
    delete from NINDRPT where ID = @ID
    commit transaction

    fetch next from c_indrpt into
       @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@BVDRGID,@DQ1,@DQ2,@DQ3,@DQ4,
       @DT1,@DT2,@DT3,@DT4,@DI1,@DI2,@DI3,@DI4,@DR1,@DR2,@DR3,@DR4
  end
  close c_indrpt
  deallocate c_indrpt
end
GO
