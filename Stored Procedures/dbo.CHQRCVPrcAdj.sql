SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHQRCVPrcAdj](
	@piGroupID INT,
	@OPERGID INT,
	@MSG VARCHAR(255) OUTPUT
) as
begin
  declare @NTYPE SMALLINT,  @NNOTE varchar(100),
          @EXTIME DATETIME, @RHQUUID CHAR(32),  @NSTAT SMALLINT
  declare @vRet int,        @vUpCtrl int,       @GID INT,
          @optvalue int,		@settleno int,			@usergid int,
          @NewNum varchar(10), @num varchar(14), @cls varchar(10),		
          @FrcChk int,      @ret int,	 					@storegid int
  set @vRet = 0
  exec OPTREADINT 0, 'USECHQ', 0, @optvalue output
  select @settleno = Max(no) from monthsettle
  select @usergid = usergid from system(nolock)
  select @cls = RTrim(cls), @FrcChk = stat from cqnprcadj(nolock)
  	where GroupID = @piGroupID and NTYPE = 1
  --获得单号
  Select @num = Max(Num) From PrcAdj Where Cls = @cls
  exec nextbn @num, @newnum output
  if @optvalue = 1
  begin
    insert into PRCADJ(Cls, Num, SettleNo, FilDate, Filler, Checker, RecCnt, AdjAmt,
            Stat, Note, Launch, EON, Src, SrcNum, SndTime)
      select Cls, @NewNum, @SettleNo, Fildate, 1, 1, RecCnt, 0,
            0, '大总部:['+num + '] ' + Note, Launch, 1, @usergid, null, null
      from CQNPRCADJ m(nolock)
      where GroupID = @piGroupID and NTYPE = 1
      
    insert Into PrcAdjDtl(Cls, Num, Line, SettleNo, GdGid, OldPrc, NewPrc, Qty)
      select @Cls, @NewNum, Line, @SettleNo, GdGid, OldPrc, NewPrc, 0
      from CQNPRCADJDTL where GroupID = @piGroupID and NTYPE = 1
      
    Insert Into PrcAdjLacDtl(Cls, Num, StoreGid)
      select @CLS, @newnum, GID
      from store(nolock) where gid <> @usergid
    if @FrcChk = 1
    begin
    	exec PrcAdjChk @Cls, @newnum
    	/*
    	declare c_store for
    	  select storegid from PrcAdjLacDtl(nolock) 
    	    where cls = @cls and num = @num and storegid <> @usergid
    	open c_store
    	fetch next from c_store into @storegid
    	while @@fetch_status = 0 
    	begin
    		exec @ret = PRCADJSND @Cls, @newnum, @storegid,@FrcChk
    		fetch next from c_store into @storegid
    	end;
    	close c_store
    	deallocate c_store
    	if @ret <> 0
    	  return 0
    	*/
    end
  end
  delete from CQNPrcAdj where GROUPID = @piGroupID and NTYPE = 1
  delete from CQNPrcAdjDtl where GROUPID = @piGroupID and NTYPE = 1
  return 0
end;
GO
