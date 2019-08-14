SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[TaxSortAdj_Snd]
(
    @Num  varchar(14),
    @FRCCHK SMALLINT,
    @Msg varchar(256) output
)
As
Begin
  declare
    @user_gid int,
    @src int,
    @storegid int,
    @billid int,
    @settleno int,
    @fildate datetime,
    @filler char(30),
    @checker char(30),
    @chkdate datetime,
    @province char(32),
    @stat int,
    @note varchar(100),
    @reccnt int,
    @launch datetime,
    @sndtime datetime,
    @lstupdtime datetime,
    @store int

    select @user_gid = UserGid from System
    select @src = Src, @stat = Stat, @settleno = settleno, @fildate = fildate,
    @filler = filler, @checker = checker, @chkdate = chkdate, @note = note, @reccnt = reccnt,
    @launch = launch, @sndtime = getdate(), @lstupdtime = lstupdtime, @province = province
      from TaxSortAdj where Num = @Num
    
    select @store = usergid from system(nolock)    
    if not exists(select 1 from TaxSortAdjlacdtl
      where num = @num and storegid <> @store)
    begin
    set @msg = '生效单位只有本店，不能发送'
      return 1
    end

    if @stat <> 100 and @stat <> 800
    begin
      set @Msg = '不是已审核或已生效的单据'
      return 1
    end
    if @src <> @user_gid and @src <> 1
    begin
      set @Msg = '不是本单位产生的单据不能发送'
      return 1
    end
    
    if object_id('c_TaxSortAdjsnd') is not null deallocate c_TaxSortAdjsnd
    declare c_TaxSortAdjsnd cursor for
    select storegid from TaxSortAdjlacdtl where num = @num
    open c_TaxSortAdjsnd
    fetch next from c_TaxSortAdjsnd into @storegid

    if @@fetch_status = 0
      exec TaxSortAdj_ADD_LOG @num, @stat, '发送'

    while @@fetch_status = 0
    begin
      execute GetNetBillId @billid output
      insert into NTaxSortAdj(src, id, num, settleno, fildate, filler, checker, chkdate, province,
        reccnt, stat, note, nstat, nnote, rcv, launch, sndtime, rcvtime, type, lstupdtime, frcchk)
      values
      (@user_gid, @billid, @num, @settleno, @fildate, @filler, @checker, @chkdate, @province,
       @reccnt, @stat, @note, 0, null, @storegid, @launch, @sndtime, null, 0, @lstupdtime, @frcchk)

      insert into NTaxSortAdjDTL(SRC, ID, LINE, GDGID, OLDTAXSORT, NEWTAXSORT, NOTE)
        select @user_gid, @billid, line, gdgid, OLDTAXSORT, NEWTAXSORT, NOTE
        from TaxSortAdjDtl where num = @num
        
      exec LOGNETOBJSEQ 1193, @store, @billid, @storegid, 0
            
      fetch next from c_TaxSortAdjsnd into @storegid
    end
    close c_TaxSortAdjsnd
    deallocate c_TaxSortAdjsnd

    update TaxSortAdj set SndTime = getdate() where num=@num
  return 0
End
GO
