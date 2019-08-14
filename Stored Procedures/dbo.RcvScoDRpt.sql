SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvScoDRpt] as
begin
  declare
    @ID	  INT,   @ASTORE  INT,  @ASETTLENO INT,   @ADATE DATETIME ,     @BCARRIER INT,
    @BCARD INT,  @DT1  MONEY,	@DT2     MONEY,   @DS1	 MONEY    ,     @DS2  MONEY,
    @MSD   int,  @AllowUseOtherStoreScore int,    @allownegscore int,   @sumscore money,
    @err varchar(255)
  exec OPTREADINT 377, 'AllowUseOtherStoreScore', 0, @AllowUseOtherStoreScore output    
  exec OPTREADINT 0, 'AllowNegScore', 0, @allownegscore output
  if object_id('c_scodrpt') is not null deallocate c_scodrpt
  declare c_scodrpt cursor for
     select ID,ASTORE,ASETTLENO,ADATE,BCARRIER,BCARD,DT1,DT2,DS1,DS2
     from NSCODRPT where type =1

  open c_scodrpt
  fetch next from c_scodrpt into
  @ID,@ASTORE,@ASETTLENO,@ADATE,@BCARRIER,@BCARD,@DT1,@DT2,@DS1,@DS2

  while @@fetch_status = 0
  begin
    select @BCARRIER = (select GID from CLIENT(NOLOCK) where GID = @BCARRIER)
    if @BCARRIER is null
    begin
      update NSCODRPT set NSTAT = 1, NNOTE = '持卡人不存在'
         where NSCODRPT.ID = @ID
      fetch next from c_scodrpt into
          @ID,@ASTORE,@ASETTLENO,@ADATE,@BCARRIER,@BCARD,@DT1,@DT2,@DS1,@DS2
      continue
    end

    select @BCARD = (select gid from CARD(NOLOCK) where gid = @BCARD)
    if @BCARD is null
    begin
       update nscodrpt set  nstat =1,nnote ='卡不存在'
       where nscodrpt.id=@ID
       fetch next from c_scodrpt into
           @ID,@ASTORE,@ASETTLENO,@ADATE,@BCARRIER,@BCARD,@DT1,@DT2,@DS1,@DS2
       continue
    end

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno = @aSettleno + @MSD
    --

    begin transaction
    /* 复制到或更新SCODRPT */
    if exists (select * from SCODRPT
    where ADATE = @ADATE and BCARRIER = @BCARRIER
    and BCARD=@BCARD 
    and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE )
    begin
      if @AllowUseOtherStoreScore=1
      begin
      	update scoreinv set score=score - (ds1 - ds2)
      	from scodrpt where ADATE = @ADATE and BCARRIER = @BCARRIER
         and BCARD=@BCARD and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE
         and scoreinv.store = @astore and scoreinv.carrier = @bcarrier
      end
      delete from SCODRPT
         where ADATE = @ADATE and BCARRIER = @BCARRIER
         and BCARD=@BCARD 
         and ASETTLENO = @ASETTLENO and ASTORE = @ASTORE
    end
    insert into SCODRPT
    (ASTORE,ASETTLENO,ADATE,BCARRIER,BCARD,DT1,DT2,DS1,DS2)
    VALUES
    (@ASTORE,@ASETTLENO,@ADATE,@BCARRIER,@BCARD,@DT1,@DT2,@DS1,@DS2)
    if @AllowUseOtherStoreScore=1 
    begin
    	if exists(select 1 from scoreinv where store=@astore and carrier = @BCARRIER)
        begin
          	update scoreinv set score = score + (@ds1 - @ds2)
            where store = @astore and carrier = @bcarrier
        end else
        begin
            insert into scoreinv 
            values( @ASTORE,@BCARRIER,(@ds1-@ds2) )
        end
        if @allownegscore = 0
        begin
            select @sumscore = sum(score) from scoreinv where carrier = @bcarrier
            if @sumscore<0 
            begin
                rollback transaction
                close c_scodrpt
                deallocate c_scodrpt
                set @err = '不能接受，发现用户各店消费积分总额小于0，可能已经兑奖，用户内码：' + convert(varchar,@bcarrier)
                raiserror(@err, 16, 1)
                return(1)
            end
        end
    end
    
    /* 删除NSCODRPT */
    delete from NSCODRPT where ID = @ID
    --if @@trancount>0
    commit transaction

    fetch next from c_scodrpt into
       @ID,@ASTORE,@ASETTLENO,@ADATE,@BCARRIER,@BCARD,@DT1,@DT2,@DS1,@DS2
  end
  close c_scodrpt
  deallocate c_scodrpt
end
GO
