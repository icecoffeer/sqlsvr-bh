SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[POSPROCICCARDHST](
  @buypool varchar(30),
  @posno varchar(10)
)  as
begin
	declare @ACTION	varchar(10),	
		 @FILDATE DATETIME ,
		 @STORE INT ,
		 @CARDNUM CHAR(20),
		 @OLDCARDNUM CHAR(20),
		 @OLDBAL DECIMAL(24,2),
		 @OCCUR DECIMAL(24,2) ,
		 @OLDSCORE DECIMAL(24,2) ,
		 @Score DECIMAL(24,2) ,
		 @OLDBYDATE DATETIME ,
		 @NEWBYDATE DATETIME ,
		 @OPER varCHAR(30) ,
		 @NOTE VARCHAR(100) ,
		 @CARRIER INT,
		 @CARDCOST DECIMAL(24,2),
		 @CardType VARCHAR(20),
		 @CHARGE DECIMAL(24,2)

	select @store = usergid from system

    execute(
    'declare c_prociccardhst cursor for ' +
    '  select action,fildate,cardnum,carrier,oldcardnum,oldbal, ' +
    ' occur,oldscore,score,oldbydate,newbydate,oper,note,cardcost ' +
    '  from ' + @buypool + '..iccardhst_' + @posno )
    open c_prociccardhst
    fetch next from c_prociccardhst into @action,@fildate,@cardnum,@carrier,@oldcardnum,@oldbal,
	@occur,@oldscore,@score,@oldbydate,@newbydate,@oper,@note,@cardcost
    while @@fetch_Status = 0
    begin
	if not exists ( select 1 from iccardhst where fildate = @fildate and
		cardnum = @cardnum and carrier = @carrier and action = @action and store = @store)
	begin
		insert into iccardhst (action,fildate,cardnum,carrier,oldcardnum,oldbal, 
			 occur,oldscore,score,oldbydate,newbydate,oper,note,cardcost ,store,src)
		values (@action,@fildate,@cardnum,@carrier,@oldcardnum,@oldbal, 
			 @occur,@oldscore,@score,@oldbydate,@newbydate,@oper,@note,@cardcost ,@store,@store)
	end

	    fetch next from c_prociccardhst into @action,@fildate,@cardnum,@carrier,@oldcardnum,@oldbal,
		@occur,@oldscore,@score,@oldbydate,@newbydate,@oper,@note,@cardcost
    end
    close c_prociccardhst
    deallocate c_prociccardhst
    exec('delete from ' + @buypool + '..iccardhst_' + @posno)

 end
 

GO
