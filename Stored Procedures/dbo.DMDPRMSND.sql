SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DMDPRMSND](
  @num char(10)
) as
begin
  declare
    @user_gid int,
    @curr_date datetime,
    @n_billid int,
    @src int,
    @stat smallint,
    @ratifystore int

    select @user_gid = UserGid from System
    select @src = Src, @stat = Stat, @curr_date = getdate(),@ratifystore = ratifystore
        from DmdPrm
        where Num = @num
    if @stat = 0
    begin
        raiserror('不是可发送的单据。', 16, 1)
        return(1)
    end
    /*if @src <> @src
    begin
        raiserror('不是本单位产生的单据。', 16, 1)
        return(2)
    end

    if @ratifystore = @user_gid
    begin
        raiserror('不是可发送的单据。', 16, 1)
        return(3)
    end */

	IF (@src = @user_gid) AND (@stat <> 1)
	BEGIN
        raiserror('报批单位只能发送提交状态的促销申请单。', 16, 1)
        return(1)
	END
	IF (@RATIFYSTORE = @user_gid) AND (@stat not in (2,3))
	BEGIN
        raiserror('批准单位只能发送批准和作废状态的促销申请单。', 16, 1)
        return(1)
	END
	--2004.12.23
	IF (@src <> @user_gid) AND (@RATIFYSTORE <> @user_gid)
	BEGIN
        raiserror('不是本单位生成或批准的单据，不能发送。', 16, 1)
        return(1)
	END
	
  IF (@src = @user_gid) AND (@RATIFYSTORE = @user_gid)          
  BEGIN          
    raiserror('本单位生成并且由本单位批准的单据，不需要发送。', 16, 1)          
    return(1)          
  END      
          


    execute GetNetBillId @n_billid output
    if @stat = 1
      insert into NDmdPrm( Src,Id,NStat, SndTime,Type,FrcChk,
                         Rcv,Eon,RatifyStore,Num, FilDate, Filler,SubmitDate,Submitter,RecCnt,Note,Launch,Topic,STAT,SRCNUM, RATIFIER,RATIFYDATE, CancelDate, Canceler)
            select @src,@n_billid, 0, @curr_date, 0,0,
                 RatifyStore,Eon,RatifyStore,Num, FilDate, Filler,SubmitDate,Submitter,RecCnt,Note,Launch,Topic,STAT,SRCNUM, RATIFIER,RATIFYDATE, CancelDate, Canceler
	  	from DmdPrm
	  	where Num = @num
	  else
      insert into NDmdPrm( Src,Id,NStat, SndTime,Type,FrcChk,
                         Rcv,Eon,RatifyStore,Num, FilDate, Filler,SubmitDate,Submitter,RecCnt,Note,Launch,Topic,STAT,SRCNUM, RATIFIER,RATIFYDATE, CancelDate, Canceler)
            select @src,@n_billid, 0, @curr_date, 0,0,
                 @src,Eon,RatifyStore,Num, FilDate, Filler,SubmitDate,Submitter,RecCnt,Note,Launch,Topic,STAT,SRCNUM, RATIFIER,RATIFYDATE, CancelDate, Canceler
	  	from DmdPrm
	  	where Num = @num
    if @@error <> 0
        return(@@error)
    update DmdPrm set SndTime = @curr_date where Num = @num
    if @@error <> 0
        return(@@error)
    insert into NDmdPrmLacDtl(Src,Id,StoreGid)
            select @src,@n_billid,StoreGid
              from DmdPrmLacDtl
              where Num = @num
    if @@error <> 0
        return(@@error)
    insert into NDmdPrmDtl(Src, Id, Line, GdGid, PrmType,CanGft, Qpc, QpcStr)
      select  @src, @n_billid, Line, GdGid, PrmType,CanGft, Qpc, QpcStr
        from DmdPrmDtl
        where Num = @num
    if @@error <> 0
        return(@@error)
    insert into NDmdPrmDtlDtl(Src,Id,Line,Item,Start,Finish,Cycle,CStart,CFinish,CSpec,QtyLo,QtyHi,
                              Price,Discount,InPrc,MbrPrc,GftGid,GftQty,GftPer,GftType,PrmTag,PRMLWTPRC, CONFIRM )
         select @src, @n_billid,Line,Item,Start,Finish,Cycle,CStart,CFinish,CSpec,QtyLo,QtyHi,
                              Price,Discount,InPrc,MbrPrc,GftGid,GftQty,GftPer,GftType,PrmTag,PRMLWTPRC, CONFIRM
             from DmdPrmDtlDtl
             where Num = @num
    if @@error <> 0
        return(@@error)
    return(0)
end
GO
