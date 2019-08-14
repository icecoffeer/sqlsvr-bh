SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTAGMCHK](
  @p_num char(10),
  @p_checker int
) with encryption
as
begin
  declare     
    @p_vendor int,
    @p_gdgid int,
    @p_start datetime,
    @p_finish datetime,
    @p_inqty money,
    @p_gftgid int,
    @p_gftqty money,
    @p_line int,
    @p_lstid varchar(16),
    @p_oldlstid varchar(16),
    @p_storegid int,
    @p_usergid int,
    @p_date varchar(19),
    @p_i varchar(16),
    @p_j varchar(8),
    @p_eon int,
    @p_autosend int,
    @p_frcchk smallint,
    @return_status int,
    @opt_ChkTimeLimit int,
    @CanUpd int,
    @ErrMsg varchar(60),
    @p_GFTWRH int

    exec optreadint 448,'ChkTimeLimit',0,@opt_ChkTimeLimit    
    if not exists(select 1 from gftagm(nolock) where num = @p_num and stat = 0)
    begin
      raiserror('审核的单据不存在或不是未审核单据', 16, 1)
      return(1)
    end
 
    if exists(select 1 from gftagmdtl d(nolock), goods g(nolock)
      where d.gdgid = g.gid and (isnull(g.isbind, 0) <> 0) and d.num = @p_num)  /*2002.11.28*/
    begin
      raiserror('存在主商品是捆绑商品的协议行', 16, 1)
      return(2)
    end
    
    if exists(select 1 from gftagmdtl d(nolock), goods g(nolock)
      where d.gdgid = g.gid and ((g.isltd & 2 = 2) or (g.isltd & 8 = 8))
      and d.num = @p_num)             /*2002.11.28*/
    begin
      raiserror('存在主商品是限制定货或清场商品的协议行', 16, 1)
      return(3)
    end
    
    if exists(select 1 from gftagmdtl d(nolock), goods g(nolock)
      where d.gftgid = g.gid and ((g.isltd & 2 = 2) or (g.isltd & 8 = 8))
      and d.num = @p_num)             /*2002.11.28*/
    begin
      raiserror('存在赠品是限制定货或清场商品的协议行', 16, 1)
      return(4)
    end
    
    select @p_usergid = usergid from system(nolock)
    select @p_eon = EON from GFTAGM(nolock) where NUM = @p_num
 
    /*生成序列号: dddd - yyyymmdd - 0000*/
    select @p_lstid = code from store where gid = @p_usergid
    if @p_lstid is null
      set @p_lstid = '9999'
    else
      set @p_lstid = '9999' + @p_lstid
    set @p_lstid = right(@p_lstid, 4)
    select @p_date = convert(char(10), getdate(), 102)
    set @p_date = replace(@p_date, '.', '')
    set @p_lstid = @p_lstid + substring(@p_date, 1, 8)
    
    if object_id('c_GIFT') is not null deallocate c_GIFT
    declare c_GIFT cursor for
      select m.VENDOR, d.START, d.FINISH, d.GDGID, d.INQTY, d.GFTGID, d.GFTQTY, d.LINE, d.LSTID, d.GFTWRH
        from GFTAGM m, GFTAGMDTL d
        where m.NUM = d.NUM and m.NUM = @p_num and d.STAT = 0 and d.FINISH > getdate()
    for update
    open c_GIFT
    fetch next from c_GIFT into @p_vendor, @p_start, @p_finish, @p_gdgid, @p_inqty, @p_gftgid, @p_gftqty, @p_line, @p_oldlstid, @p_GFTWRH
    while @@fetch_status = 0
    begin
      /*if exists(select 1 from GIFT where VENDOR = @p_vendor and GDGID = @p_gdgid
          and GFTGID = @p_gftgid
          and ((START between @p_start and @p_finish)
          or (FINISH between @p_start and @p_finish)
          or (START < @p_start and FINISH > @p_finish)))
      begin
        raiserror('存在冲突的赠品协议', 16, 1)
        close c_GIFT
        deallocate c_GIFT
        return(1)
      end*/
      
      set @CanUpd = 0
      if convert(datetime,@p_start) < getdate()
      begin
        if @Opt_ChkTimeLimit = 1 
        begin
          set @CanUpd = 1
          set @p_start = getdate()          
        end  
        else
        begin       
          set @Errmsg = '第' + convert(varchar,@p_line) + '行开始时间小于当前时间' 
          raiserror(@ErrMsg, 16, 1)
          close c_Gift
          deallocate c_Gift
          return(1)
        end    
      end
      if convert(datetime, @p_start) > convert(datetime, @p_finish)
      begin
        raiserror('结束时间不能小于开始时间', 16, 1)
        close c_Gift     
        deallocate c_Giftd
        return(1)        
      end
      --数据正确,根据选项更新开始时间
      if @Opt_ChkTimeLimit = 1 and @CanUpd = 1
        update gftagmdtl set start = @p_start where num = @p_num and gdgid = @p_gdgid and line = @p_line
       
      if @p_oldlstid is null
      begin                           
        select @p_i = max(lstid) from gftagmdtl where lstid like @p_lstid + '%'
        if @p_i is null
          set @p_i = @p_lstid + '0000'
        else begin
          set @p_j = substring(@p_i, 13, 4)
          set @p_i = substring(@p_i + '0000', 1, 12)
          execute NEXTBN @p_j, @p_j output
          set @p_j = '0000' + @p_j
          set @p_j = right(@p_j, 4)
          set @p_i = substring(@p_i, 1, 12) + substring(@p_j, 1, 4)
        end
 
        update gftagmdtl set lstid = @p_i where current of c_GIFT
      end else
        set @p_i = @p_oldlstid
 
      if @p_eon = 1
      begin
        insert into GIFT(lstid, storegid, vendor, start, finish, gdgid, inqty,
          gftgid, gftqty, srcnum, srcline, GFTWRH)
        values(@p_i, @p_usergid, @p_vendor, @p_start, @p_finish, @p_gdgid, @p_inqty,
          @p_gftgid, @p_gftqty, @p_num, @p_line, @p_GFTWRH)
      end
      
      declare c_LAC cursor for
        select STOREGID from GFTAGMLACDTL where NUM = @p_num
      open c_LAC
      fetch next from c_LAC into @p_storegid
      while @@fetch_status = 0
      begin
        insert into GIFT(lstid, storegid, vendor, start, finish, gdgid, inqty,
          gftgid, gftqty, srcnum, srcline, GFTWRH)
          values(@p_i, @p_storegid, @p_vendor, @p_start, @p_finish, @p_gdgid, @p_inqty,
          @p_gftgid, @p_gftqty, @p_num, @p_line, @p_GFTWRH)
                        
        fetch next from c_LAC into @p_storegid
      end 
      close c_LAC
      deallocate c_LAC
 
      fetch next from c_GIFT into @p_vendor, @p_start, @p_finish, @p_gdgid, @p_inqty, @p_gftgid, @p_gftqty, @p_line, @p_oldlstid, @p_GFTWRH
    end  
    close c_GIFT
    deallocate c_GIFT
                
    update GFTAGM set STAT = 1, CHECKER = @p_checker where NUM = @p_num
    
    /*来源单位为本单位的自动发送*/
    if (select src from gftagm(nolock) where num = @p_num) = @p_usergid
    begin
      exec OptReadInt 448, 'AutoSend', 0, @p_autosend output
      if @p_autosend <> 0             
      begin
        exec OptReadInt 448, 'ForceCheck', 1, @p_frcchk output
        exec @return_status = GftAgmSnd @p_num, @p_frcchk
        if @return_status <> 0 return @return_status
      end
    end  
    return(0)
end
GO
