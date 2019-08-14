SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvInvChgYRpt] as
begin
  declare
    @ID	  INT,   @ASTORE  INT,  @ASETTLENO INT,   @BGDGID INT,
    @BWRH INT,   @DQ1   MONEY,  @DQ2	 MONEY,   @DQ4  MONEY,	@DQ5  MONEY,            
    @DQ6  MONEY, @DQ7  MONEY ,  @DT6     MONEY,   @DT7  MONEY,			--2002-08-16
    @DI1  MONEY, @DI2  MONEY ,  @DI3     MONEY,   @DI4  MONEY, 	@DI5  MONEY,   @DI6  MONEY, 	@DI7  MONEY,--2002-08-16
    @DR1  MONEY, @DR2  MONEY ,  @DR3     MONEY,   @DR4  MONEY, 	@DR5  MONEY,   @DR6  MONEY, 	@DR7  MONEY,--2002-08-16
    @MSD   int , @CQ1   MONEY,  @CQ2	 MONEY,   @CQ4  MONEY,  @CQ5  MONEY, 
    @CQ6  MONEY, @CQ7  MONEY ,  @CT6     MONEY,   @CT7  MONEY,			--2002-08-16
    @CI1  MONEY, @CI2  MONEY ,  @CI3     MONEY,   @CI4  MONEY, 	@CI5  MONEY,   @CI6  MONEY, 	@CI7  MONEY,--2002-08-16 
    @CR1  MONEY, @CR2  MONEY ,  @CR3     MONEY,   @CR4  MONEY, 	@CR5  MONEY,   @CR6  MONEY, 	@CR7  MONEY,--2002-08-16
    @DI8  MONEY--modified by wang xin 2003.02.17

  declare c_inVCHGYrpt cursor for
     select id,astore,asettleno,BGDGID,bwrh,
            DQ1,DQ2,DQ4,DQ5,DQ6,DQ7,DT6,DT7,DI1,DI2,DI3,DI4,DI5,DI6,DI6,
            DR1,DR2,DR3,DR4,DR5,DR6,DR7,
            CQ1,CQ2,CQ4,CQ5,CQ6,CQ7,CT6,CT7,CI1,CI2,CI3,CI4,CI5,CI6,CI7,
            CR1,CR2,CR3,CR4,CR5,CR6,CR7, DI8 --modified by wang xin 2003.02.17
     from ninVCHGYrpt where type =1

  open c_inVCHGYrpt
  fetch next from c_inVCHGYrpt into
    @id,@astore,@asettleno,@BGDGID,@bwrh,
    @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
    @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,
    @CQ1,@CQ2,@CQ4,@CQ5,@CQ6,@CQ7,@CT6,@CT7,@CI1,@CI2,@CI3,@CI4,@CI5,@CI6,@CI7,
    @CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7,@DI8 --modified by wang xin 2003.02.17

  while @@fetch_status = 0
  begin
    select @BGDGID = (select LGID from GDXLATE where NGID = @BGDGID)
    if @BGDGID is null
    begin
      update NINVCHGYRPT set NSTAT = 1, NNOTE = '商品不存在'
         where NINVCHGYRPT.ID = @ID
      fetch next from c_inVCHGYrpt into
          @id,@astore,@asettleno,@BGDGID,@bwrh,
          @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
          @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,
          @CQ1,@CQ2,@CQ4,@CQ5,@CQ6,@CQ7,@CT6,@CT7,@CI1,@CI2,@CI3,@CI4,@CI5,@CI6,@CI7,
          @CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7, @DI8 --modified by wang xin 2003.02.17
      continue
    end

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --

    begin transaction
    /* 复制到或更新INVCHGYRPT */
    if exists (select * from INVCHGYRPT
    where BGDGID = @BGDGID
      AND bwrh=@bwrh and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE )
    begin
      delete from INVCHGYRPT
         where BGDGID = @BGDGID
           and bwrh=@bwrh
           and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE
    end
    insert into INVCHGYRPT
    (ASTORE, ASETTLENO, BGDGID, BWRH,
            DQ1,DQ2,DQ4,DQ5,DQ6,DQ7,DT6,DT7,DI1,DI2,DI3,DI4,DI5,DI6,DI7,
            DR1,DR2,DR3,DR4,DR5,DR6,DR7,
            CQ1,CQ2,CQ4,CQ5,CQ6,CQ7,CT6,CT7,CI1,CI2,CI3,CI4,CI5,CI6,CI7,
            CR1,CR2,CR3,CR4,CR5,CR6,CR7, DI8)--modified by wang xin 2003.02.17
    VALUES
    (@ASTORE,@ASETTLENO,@BGDGID,@BWRH,
     @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
     @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,
     @CQ1,@CQ2,@CQ4,@CQ5,@CQ6,@CQ7,@CT6,@CT7,@CI1,@CI2,@CI3,@CI4,@CI5,@CI6,@CI7,
     @CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7, @DI8)--modified by wang xin 2003.02.17
    /* 删除NINVCHGYRPT */
    delete from NINVCHGYRPT where ID = @ID
    commit transaction

    fetch next from c_inVCHGYrpt into
          @id,@astore,@asettleno,@BGDGID,@bwrh,
          @DQ1,@DQ2,@DQ4,@DQ5,@DQ6,@DQ7,@DT6,@DT7,@DI1,@DI2,@DI3,@DI4,@DI5,@DI6,@DI7,
          @DR1,@DR2,@DR3,@DR4,@DR5,@DR6,@DR7,
          @CQ1,@CQ2,@CQ4,@CQ5,@CQ6,@CQ7,@CT6,@CT7,@CI1,@CI2,@CI3,@CI4,@CI5,@CI6,@CI7,
          @CR1,@CR2,@CR3,@CR4,@CR5,@CR6,@CR7,@DI8 --modified by wang xin 2003.02.17
  end
  close c_inVCHGYrpt
  deallocate c_inVCHGYrpt
end
GO
