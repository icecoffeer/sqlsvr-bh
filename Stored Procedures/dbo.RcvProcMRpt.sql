SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RcvProcMRpt] as
begin
  declare
    @ID	  INT,    @ASTORE  INT,    @ASETTLENO INT,   @BGDGID INT,       @BWRH INT,
    @DQ1  MONEY,  @DT1  MONEY,     @DI1  MONEY,      @DR1  MONEY,       @DD1  MONEY,
    @CQ1  MONEY,  @CT1  MONEY,     @CI1  MONEY,      @CR1  MONEY,       @CD1  MONEY,       
    @MSD  int


  declare c_ProcMRpt cursor for
     select id,astore,asettleno,BGDGID,bwrh,dq1,dt1,di1,dr1,dd1,cq1,ct1,ci1,cr1,cd1
     from NProcMRpt where type =1

  open c_ProcMRpt
  fetch next from c_ProcMRpt into
    @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NProcMRpt set NSTAT = 1, NNOTE = '商品不存在'
         where NProcMRpt.ID = @ID
      fetch next from c_ProcMRpt into
         @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1
      continue
    end


    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD

    begin transaction

    if exists (select * from ProcMRpt
    where ASETTLENO = @ASETTLENO  and BGDGID = @BGDGID
      and BWRH=@bwrh AND ASTORE = @ASTORE
    )
    begin
      delete from ProcMRpt
      where ASETTLENO = @ASETTLENO  and BGDGID = @BGDGID
      and BWRH=@bwrh AND ASTORE = @ASTORE
    end
    insert into ProcMRpt
    (ASTORE, ASETTLENO, BGDGID, BWRH,DQ1,DT1,DI1,DR1,DD1,CQ1,CT1,CI1,CR1,CD1 )
    VALUES
    (@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1 )

    delete from NProcMRpt where ID = @ID
    commit transaction

    fetch next from c_ProcMRpt into
      @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1,@CQ1,@CT1,@CI1,@CR1,@CD1
  end
  close c_ProcMRpt
  deallocate c_ProcMRpt
end

GO
