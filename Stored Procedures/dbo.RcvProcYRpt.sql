SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RcvProcYRpt] as
begin
  declare
    @ID	  INT,    @ASTORE  INT,    @ASETTLENO INT,   @BGDGID INT,       @BWRH INT,
    @DQ1  MONEY,  @DT1  MONEY,     @DI1  MONEY,      @DR1  MONEY,       @DD1  MONEY,
    @CQ1  MONEY,  @CT1  MONEY,     @CI1  MONEY,      @CR1  MONEY,       @CD1  MONEY,
    @YSD  int


  declare c_ProcYRpt cursor for
     select id,astore,asettleno,BGDGID,bwrh,dq1,dt1,di1,dr1,dd1,cq1,ct1,ci1,cr1,cd1
     from NProcYRpt where type =1

  open c_ProcYRpt
  fetch next from c_ProcYRpt into
    @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NProcYRpt set NSTAT = 1, NNOTE = '商品不存在'
         where NProcYRpt.ID = @ID
      fetch next from c_ProcYRpt into
         @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1
      continue
    end

    select @YSD = isNull(YSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @YSD

    begin transaction

    if exists (select * from ProcYRpt
    where ASETTLENO = @ASETTLENO
    and BGDGID = @BGDGID and bwrh=@bwrh and  ASTORE = @ASTORE )
    begin
      delete from  ProcYRpt
      where ASETTLENO = @ASETTLENO  and BGDGID = @BGDGID
      and BWRH=@bwrh AND ASTORE = @ASTORE
    end
    insert into ProcYRpt
    (ASTORE, ASETTLENO, BGDGID, BWRH,DQ1,DT1,DI1,DR1,DD1,CQ1,CT1,CI1,CR1,CD1 )
    VALUES
    (@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1 )

    delete from NProcYRpt where ID = @ID
    commit transaction

    fetch next from c_ProcYRpt into
      @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1
  end
  close c_ProcYRpt
  deallocate c_ProcYRpt
end

GO
