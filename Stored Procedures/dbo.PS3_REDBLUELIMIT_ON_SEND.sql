SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_ON_SEND]
(
  @piNum varchar(14),
  @piFrcchk smallint,
  @piOper varchar(30),
  @poErrMsg varchar(255) output
)as
begin
  declare
    @user_gid int,
    @src int,
    @storegid int,
    @billid int,
    @fildate datetime,
    @filler char(30),
    @checker char(30),
    @chkdate datetime,
    @stat int,
    @note varchar(100),
    @settleno int,
    @sndtime datetime,
    @vVendor int
    

    select @user_gid = UserGid from System
    select @src = SRC, @stat = STAT,@fildate = FILDATE, @settleno = SETTLENO, 
      @filler = FILLER,@checker = CHECKER,@chkdate = CHKDATE, @note = NOTE, @vVendor = VENDOR,
      @sndtime=getdate() from PS3REDBLUECARD(nolock) where NUM = @piNum

    if @stat <> 100 
    begin
      set @poErrMsg = '不是已审核单据不能发送'
      return 1
    end
    if @src <> @user_gid and @src <> 1
    begin
      set @poErrMsg = '不是本单位产生的单据不能发送'
      return 1
    end

    delete from NPS3REDBLUECARDDtl where NUM = @piNum
    delete from NPS3REDBLUECARD where NUM = @piNum

    if object_id('c_RedBlue') is not null deallocate c_RedBlue
    declare c_RedBlue cursor for
      select storegid from PS3REDBLUECARDSTOREDTL where NUM = @piNum
    open c_RedBlue
    fetch next from c_RedBlue into @storegid

    while @@fetch_status = 0
    begin
      execute GetNetBillId @billid output
      insert into NPS3REDBLUECARD(NUM, SETTLENO, STAT, SRC, NOTE, ID, RCV, FRCCHK, 
        NTYPE, NSTAT, SNDTIME, FILDATE, FILLER, CHECKER, CHKDATE, VENDOR)
      values
      (@piNum, @settleno, @stat, @user_gid, @note, @billid, @storegid, @piFrcchk, 0, 0, @sndtime, @fildate, @filler, @checker, @chkdate, @vVendor)

      insert into NPS3REDBLUECARDDTL(NUM, LINE, GDGID, LOWLIMIT, TOPLIMIT, LIMITPERCENT, LIMITTOTAL, NOTE, SRC, RCV, ID)
        select NUM, LINE, GDGID, LOWLIMIT, TOPLIMIT, LIMITPERCENT, LIMITTOTAL, NOTE, @user_gid, @storegid, @billid
        from PS3REDBLUECARDDTL where NUM = @piNum
      fetch next from c_RedBlue into @storegid
    end
    close c_RedBlue
    deallocate c_RedBlue
    -- 记录日志
    insert into NPS3REDBLUECARDLOG(NUM, MODIFIER, TIME, ACT)
      VALUES (@piNum, @piOper, GETDATE(), '发送')

    update PS3REDBLUECARD set SndTime = getdate() where NUM = @piNum

  return 0

end
GO
