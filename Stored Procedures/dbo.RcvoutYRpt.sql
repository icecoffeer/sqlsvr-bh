SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvoutYRpt] as
begin
  declare
    @ID	  INT,   @ASTORE  INT,  @ASETTLENO INT,   @BGDGID INT,
    @BWRH INT,   @BCSTGID INT,	@DQ1     MONEY,   @DQ2	 MONEY    ,     @DQ3  MONEY,
    @DQ4  MONEY, @DQ5	MONEY,	@DQ6	MONEY, 	  @DQ7	 MONEY    ,     @DT1  MONEY ,
    @DT2  MONEY, @DT3	MONEY,	@DT4	MONEY, 	  @DT5	 MONEY    ,     @DT6  MONEY ,
    @DT7  MONEY, @DT91	MONEY,	@DT92	MONEY,	  @DI1	 MONEY    ,     @DI2  MONEY ,
    @DI3  MONEY, @DI4	MONEY, 	@DI5	MONEY, 	  @DI6	 MONEY    ,     @DI7  MONEY ,
    @DR1  MONEY, @DR2	MONEY,	@DR3	MONEY, 	  @DR4	 MONEY    ,     @DR5  MONEY ,
    @DR6  MONEY, @DR7	MONEY,  @CQ1    MONEY,    @CQ2   MONEY    ,     @CQ3  MONEY ,
    @CQ4  MONEY, @CQ5   MONEY,  @CQ6    MONEY,    @CQ7   MONEY    ,     @CT1  MONEY ,
    @CT2  MONEY, @CT3   MONEY,  @CT4    MONEY,    @CT5   MONEY    ,     @CT6  MONEY ,
    @CT7  MONEY, @CT91  MONEY,  @CT92   MONEY,    @CI1   MONEY    ,     @CI2  MONEY ,
    @CI3  MONEY, @CI4   MONEY,  @CI5    MONEY,    @CI6   MONEY    ,     @CI7  MONEY ,
    @CR1  MONEY, @CR2   MONEY,  @CR3    MONEY,    @CR4   MONEY    ,     @CR5  MONEY ,
    @CR6  MONEY, @CR7   MONEY,  @YSD    int


  declare c_outyrpt cursor for
     select id,astore,asettleno,bgdgid,bwrh,bcstgid,dq1,dq2,dq3,dq4,dq5,dq6,
     dq7,dt1,dt2,dt3,dt4,dt5,dt6,dt7,dt91,dt92,di1,di2,di3,di4,di5,di6,di7,dr1,dr2,
     dr3,dr4,dr5,dr6,dr7/*,CQ1,CQ2,CQ3,CQ4, CQ5, CQ6, CQ7,CT1,CT2, CT3 ,CT4,CT5 ,CT6,
     CT7,CT91, CT92 ,CI1,CI2,CI3,CI4,CI5,CI6,CI7,CR1,CR2,CR3,CR4,CR5,CR6,CR7*/
     from noutyrpt where type=1

  open c_outyrpt
  fetch next from c_outyrpt into
    @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
    @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
    @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7/*,@CQ1,@CQ2,@CQ3,@CQ4, @CQ5, @CQ6,
    @CQ7,@CT1,@CT2, @CT3 ,@CT4,@CT5 ,@CT6,@CT7,@CT91, @CT92 ,@CI1,@CI2,
    @CI3,@CI4,@CI5,@CI6,@CI7,@CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7*/

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NOUTYRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NOUTYRPT.ID = @ID
      fetch next from c_outyrpt into
          @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
          @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
          @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7/*,@CQ1,@CQ2,@CQ3,@CQ4, @CQ5, @CQ6,
          @CQ7,@CT1,@CT2, @CT3 ,@CT4,@CT5 ,@CT6,@CT7,@CT91, @CT92 ,@CI1,@CI2,
          @CI3,@CI4,@CI5,@CI6,@CI7,@CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7*/
      continue
    end

    select @BCSTGID = (select LGID from CLNXLATE where NGID=@BCSTGID)
    if @BCSTGID is null
    begin
       update noutyrpt set nstat=1,nnote = '客户不存在'
          where noutyrpt.id=@id
       fetch next from c_outyrpt into
            @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
            @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
            @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7/*,@CQ1,@CQ2,@CQ3,@CQ4, @CQ5, @CQ6,
            @CQ7,@CT1,@CT2, @CT3 ,@CT4,@CT5 ,@CT6,@CT7,@CT91, @CT92 ,@CI1,@CI2,
            @CI3,@CI4,@CI5,@CI6,@CI7,@CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7*/
       continue
    end

    --add  by zl 12.11
    select @YSD = isNull(YSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @YSD
    --

    begin transaction
    /* 复制到或更新outDRPT */
    if exists (select * from OUTYRPT
    where  ASETTLENO = @ASETTLENO
    and BGDGID = @BGDGID and BCSTGID=@BCSTGID and bwrh=@bwrh and ASTORE = @ASTORE)
    begin
      delete from OUTYRPT
      where ASETTLENO = @ASETTLENO 
      and BGDGID = @BGDGID AND BCSTGID=@BCSTGID and bwrh=@bwrh and ASTORE = @ASTORE
    end
    insert into OUTYRPT
    (ASTORE, ASETTLENO, BGDGID, BWRH,BCSTGID,DQ1,DQ2,DQ3,DQ4,DQ5,DQ6,DQ7,
     DT1,DT2,DT3,DT4,DT5,DT6,DT7,DT91,DT92,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DR1,DR2,
     DR3,DR4,DR5,DR6,DR7/*,CQ1,CQ2,CQ3,CQ4, CQ5, CQ6, CQ7,CT1,CT2, CT3 ,CT4,CT5 ,CT6,
     CT7,CT91, CT92 ,CI1,CI2,CI3,CI4,CI5,CI6,CI7,CR1,CR2,CR3,CR4,CR5,CR6,CR7*/)
    VALUES 
    (@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
     @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,
     @DI4,@DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7/*,@CQ1,@CQ2,@CQ3,@CQ4, @CQ5, @CQ6, 
     @CQ7,@CT1,@CT2, @CT3 ,@CT4,@CT5 ,@CT6,@CT7,@CT91, @CT92 ,@CI1,@CI2,
     @CI3,@CI4,@CI5,@CI6,@CI7,@CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7*/) 
    /* 删除NOUTDRPT */
    delete from NOUTYRPT where ID = @ID
    commit transaction

    fetch next from c_outyrpt into
         @ID,@ASTORE,@ASETTLENO,@BGDGID,@BWRH,@BCSTGID,@DQ1,@DQ2,@DQ3,@DQ4,@DQ5,
         @DQ6,@DQ7,@DT1,@DT2,@DT3,@DT4,@DT5,@DT6,@DT7,@DT91,@DT92,@DI1,@DI2,@DI3,@DI4,
         @DI5,@DI6,@DI7,@DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7/*,@CQ1,@CQ2,@CQ3,@CQ4, @CQ5, @CQ6, 
         @CQ7,@CT1,@CT2, @CT3 ,@CT4,@CT5 ,@CT6,@CT7,@CT91, @CT92 ,@CI1,@CI2,
         @CI3,@CI4,@CI5,@CI6,@CI7,@CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7*/
  end
  close c_outyrpt
  deallocate c_outyrpt
end
GO
