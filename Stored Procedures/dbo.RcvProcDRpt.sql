SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RcvProcDRpt] as
begin
  declare
    @ID	  INT,   @ASTORE  INT,  @ASETTLENO INT,   @ADATE DATETIME ,  @BGDGID INT, @BWRH INT,   
    @DQ1  MONEY,   @DT1  MONEY ,  @DI1  MONEY, @DR1  MONEY, @DD1 MONEY,   @MSD   int


  declare c_ProcDRpt cursor for
     select id,astore,asettleno,adate,BGDGID,bwrh,dq1,dt1,di1,dr1,dd1
     from NProcDRpt where type =1

  open c_ProcDRpt
  fetch next from c_ProcDRpt into
    @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NProcDRpt set NSTAT = 1, NNOTE = '商品不存在'
         where NProcDRpt.ID = @ID
      fetch next from c_ProcDRpt into
         @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1
      continue
    end


    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD

    begin transaction

    if exists (select * from ProcDRpt
    where ADATE = @ADATE and BGDGID = @BGDGID
    and bwrh=@bwrh and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE )
    begin
      delete from ProcDRpt
         where ADATE = @ADATE and BGDGID = @BGDGID
           and bwrh=@bwrh and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE
    end
    insert into ProcDRpt
    (ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,DQ1,DT1,DI1,DR1,DD1)
    VALUES
    (@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1)

    delete from NProcDRpt where ID = @ID
    commit transaction

    fetch next from c_ProcDRpt into
      @ID,@ASTORE,@ASETTLENO,@ADATE,@BGDGID,@BWRH,@DQ1,@DT1,@DI1,@DR1,@DD1
  end
  close c_ProcDRpt
  deallocate c_ProcDRpt
end

GO
