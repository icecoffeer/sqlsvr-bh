SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Startup_Step_BckExpFeeGen]  
as  
begin  
  declare  
    @StartDay datetime, @FinishDay datetime, @CurDay datetime,  
    @gid int, @BCKCYCLETYPE int, @BCKBGNDAYS int,  
    @BCKEXPDAYS int, @BCKBGNMON int, @strYear varchar(4),  
    @strMonth varchar(2), @opt_BckWrh int, @total money,  
    @store int, @BCKEXPRATE DECIMAL(24,4), @ID int,  
    @strDay varchar(2)  
  
  
  declare c_vendor cursor for  
    select gid, BCKCYCLETYPE, BCKBGNDAYS, BCKEXPDAYS, BCKBGNMON, BCKEXPRATE from vendor(nolock) where isnull(BCKCYCLETYPE, 0) <> 0  
  open c_vendor  
    fetch next from c_vendor into @gid, @BCKCYCLETYPE, @BCKBGNDAYS, @BCKEXPDAYS, @BCKBGNMON, @BCKEXPRATE  
  
  while @@fetch_status = 0  
  begin  
    if @BCKCYCLETYPE = 1 --每月退货  
    begin  
      if day(getdate()) >= @BCKBGNDAYS  
      begin  
        set @strYear = ltrim(str(year(getdate())))  
        set @strMonth = ltrim(str(month(getdate())))  
        set @strDay = ltrim(str(@BCKBGNDAYS))  
      end else begin  
        set @strYear = ltrim(str(year(getdate())))  
        set @strMonth = ltrim(str(month(getdate()) - 1))  
        if @strMonth = '0'  
        begin  
          set @strMonth = '12'  
          set @strYear = ltrim(str(year(getdate()) - 1))  
        end  
        set @strDay = ltrim(str(@BCKBGNDAYS))  
      end  
  
      set @StartDay = convert(datetime, @strYear + '-' + @strMonth + '-' + @strDay)  
      set @FinishDay = dateadd(day, @BCKEXPDAYS, @StartDay)  
      set @CurDay = convert(datetime, floor(convert(float, getdate())))  
    end  
    else if @BCKCYCLETYPE = 2 --每季度退货  
    begin  
      if (month(getdate()) - 1) % 3 > @BCKBGNMON or ((month(getdate()) - 1) % 3 = @BCKBGNMON and day(getdate()) >= @BCKBGNDAYS)  
      begin  
        set @strYear = ltrim(str(year(getdate())))  
        set @strMonth = ltrim(str((month(getdate()) - 1) / 3 * 3 + 1 + @BCKBGNMON))  
        set @strDay = ltrim(str(@BCKBGNDAYS))  
      end else begin  
        set @strYear = ltrim(str(year(getdate())))  
        set @strMonth = ltrim(str(((month(getdate()) - 1) / 3 - 1) * 3 + 1 + @BCKBGNMON))  
        if @strMonth <= 0  
        begin  
          set @strMonth = ltrim(str(10 + @BCKBGNMON))  
          set @strYear = ltrim(str(year(getdate()) - 1))  
        end  
        set @strDay = ltrim(str(@BCKBGNDAYS))  
      end  
  
      set @StartDay = convert(datetime, @strYear + '-' + @strMonth + '-' + @strDay)  
      set @FinishDay = dateadd(day, @BCKEXPDAYS, @StartDay)  
      set @CurDay = convert(datetime, floor(convert(float, getdate())))  
    end  
  
    if @CurDay <> @FinishDay  
    begin  
      fetch next from c_vendor into @gid, @BCKCYCLETYPE, @BCKBGNDAYS, @BCKEXPDAYS, @BCKBGNMON, @BCKEXPRATE  
      continue  
    end  
  
    if exists (select 1 from STKINBCK(nolock) where CLS  = '自营' and (stat = 1 or stat = 6)  
               and VENDOR = @gid and OCRDATE between @StartDay and @FinishDay)  
    begin  
      fetch next from c_vendor into @gid, @BCKCYCLETYPE, @BCKBGNDAYS, @BCKEXPDAYS, @BCKBGNMON, @BCKEXPRATE  
      continue  
    end  
  
    if not exists (select 1 from ord o(nolock), BCKEXPPRINTLOG b(nolock), stkin s(nolock)  
                   where o.VENDOR = @gid and s.ORDNUM = o.num and (s.stat = 1 or s.stat = 6)  
                   and o.stat = 1 and o.num = b.ORDNUM and s.cls  = '自营'  
                   and s.FILDATE between @StartDay and @FinishDay)  
    begin  
      fetch next from c_vendor into @gid, @BCKCYCLETYPE, @BCKBGNDAYS, @BCKEXPDAYS, @BCKBGNMON, @BCKEXPRATE  
      continue  
    end  
  
    exec OptReadInt 0, 'EXPCTRL_BCKWRHGID', 1, @opt_BckWrh output  
    select @store = usergid from system(nolock)  
    select @total = sum(total) from inv i(nolock), goods g(nolock) where i.store = @store  
      and i.wrh = @opt_BckWrh and g.BILLTO = @gid and g.gid = i.gdgid  
    if @total is null set @total = 0  
    if not exists (select 1 from BCKEXPFEE where VDRGID = @gid) set @ID = 1  
    else select @ID = max(CYCLEID) + 1 from BCKEXPFEE where VDRGID = @gid  
    insert into BCKEXPFEE(VDRGID, FILDATE, EXPAMT, EXPRATE, PROCAMT, CYCLEID) values  
      (@gid, getdate(), @total, @BCKEXPRATE, 0, @ID)  
  
    fetch next from c_vendor into @gid, @BCKCYCLETYPE, @BCKBGNDAYS, @BCKEXPDAYS, @BCKBGNMON, @BCKEXPRATE  
  end  
  close c_vendor  
  deallocate c_vendor
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'Startup_Step_BckExpFeeGen', 0, ''   --合并日结  
end  

GO
