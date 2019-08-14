SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvInvChgDRpt] as
begin
  declare
    @ID   INT,   @ASTORE  INT,  @ASETTLENO INT,   @ADATE DATETIME ,     @BGDGID INT,
    @BWRH INT,   @DQ1   MONEY,  @DQ2   MONEY,   @DQ4  MONEY     ,     @DQ5  MONEY,
    @DQ6  MONEY, @DQ7  MONEY, @DT6     MONEY,   @DT7  MONEY,  --2002-08-16
    @DI1  MONEY, @DI2  MONEY ,  @DI3     MONEY,   @DI4   MONEY    ,   @DI5  MONEY,     @DI6  MONEY,     @DI7  MONEY,  --2002-08-16
    @DR1  MONEY, @DR2  MONEY ,  @DR3     MONEY,   @DR4   MONEY    ,   @DR5  MONEY,     @DR6  MONEY,     @DR7  MONEY,  --2002-08-16
    @MSD   int,  @DI8 MONEY


  declare c_inVCHGdrpt cursor for
     select id,astore,asettleno,adate,BGDGID,bwrh,
            DQ1,DQ2,DQ4,DQ5,DQ6,DQ7,DT6,DT7,DI1,DI2,DI3,DI4,DI5,DI6,DI7,
            DR1,DR2,DR3,DR4,DR5,DR6,DR7,DI8 --modified by wang xin 2003.02.17
     from ninVCHGdrpt where type =1

  open c_inVCHGdrpt
  fetch next from c_inVCHGdrpt into
    @id,@astore,@asettleno,@adate,@BGDGID,@bwrh,
    @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
    @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,@DI8 --modified by wang xin 2003.02.17

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NINVCHGDRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NINVCHGDRPT.ID = @ID
      fetch next from c_inVCHGdrpt into
         @id,@astore,@asettleno,@adate,@BGDGID,@bwrh,
         @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
         @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7, @DI8 --modified by wang xin 2003.02.17
      continue
    end

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --

    begin transaction
    /* 复制到或更新INVCHGDRPT */
    if exists (select * from INVCHGDRPT
    where ADATE = @ADATE and BGDGID = @BGDGID
      AND bwrh=@bwrh and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE )
    begin
      delete from INVCHGDRPT
         where ADATE = @ADATE and BGDGID = @BGDGID
           and bwrh=@bwrh
           and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE
    end
    insert into INVCHGDRPT
    (ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,
            DQ1,DQ2,DQ4,DQ5,DQ6,DQ7,DT6,DT7,DI1,DI2,DI3,DI4,DI5,DI6,DI7,
            DR1,DR2,DR3,DR4,DR5,DR6,DR7,DI8,LSTUPDTIME)
    VALUES
    (@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,
     @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
     @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,@DI8,getdate())  --modified by wang xin 2003.02.17
    /* 删除NINVCHGDRPT */
    delete from NINVCHGDRPT where ID = @ID
    commit transaction

    fetch next from c_inVCHGdrpt into
       @id,@astore,@asettleno,@adate,@BGDGID,@bwrh,
       @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
       @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7, @DI8 --modified by wang xin 2003.02.17
  end
  close c_inVCHGdrpt
  deallocate c_inVCHGdrpt
end
GO
