SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcStoreVdrDRpt]
    @store int,
    @settleno int,
    @date datetime
as
begin
  declare @astore int,         @bvdrgid int,          @bgdgid int,
          @bwrh int,           @mwrh int,
          @dq2 money,	       @dq3 money,           
          @dt2 money,	       @dt3 money,
          @di2 money

  if (select userproperty from system) < 16
  begin
     raiserror('本单位不是总部或配送中心，不能计算门店账款', 16, 1)
  end

  if (select usergid from system) <> @store
  begin
     raiserror('不能计算其它门店账款', 16, 1)
  end
  
  declare c_vdrdrpt cursor for
    select ASTORE, BVDRGID, MWRH, BWRH, BGDGID
    from VDRDRPTLOG(NOLOCK) where asettleno =  @settleno and adate=@date and astore <> @store and sale <> 1
    order by astore
  open c_vdrdrpt
  fetch next from c_vdrdrpt into  @astore, @bvdrgid, @mwrh, @bwrh, @bgdgid
  while @@fetch_status = 0
  begin
          select @dq2 = isnull(sum(dq2),0), @dq3 = isnull(sum(dq3),0), @dt2 = isnull(sum(dt2),0), @dt3 = isnull(sum(dt3),0), @di2 = isnull(sum(di2),0)
            from vdrdrpt(nolock) 
            where astore = @astore /*and asettleno = @settleno 可能会出现门店报表期号和总部不一致的现象*/ 
                  and adate = @date and bwrh = @mwrh and bgdgid = @bgdgid and bvdrgid = @bvdrgid

	  if not exists (
	    select * from RVDRDRPT(nolock)
	    where astore = @store and asettleno = @settleno and adate = @date
	    and bwrh = @bwrh and bgdgid = @bgdgid and bvdrgid = @bvdrgid
	  )
	    insert into RVDRDRPT (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID,
                                  DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
                                  DT1, DT2, DT3, DT4, DT5, DT6, DT7,
                                  DI2)
	    values (@store, @settleno, @date, @bvdrgid, @bwrh, @bgdgid,
                    0, isnull(@dq2, 0), isnull(@dq3, 0), 0, 0, 0,
                    0, convert( dec(20,2), isnull(@dt2, 0) ), convert( dec(20,2), isnull(@dt3, 0) ), 0, 0, 0, 0, 
                    convert( dec(20,2), isnull(@di2, 0) ))
	  else
  	    update RVDRDRPT set
	      dq2 = dq2 + isnull(@dq2, 0),
	      dq3 = dq3 + isnull(@dq3, 0),
	      dt2 = convert( dec(20,2), dt2 + isnull(@dt2, 0) ),
	      dt3 = convert( dec(20,2), dt3 + isnull(@dt3, 0) ),
	      di2 = convert( dec(20,2), di2 + isnull(@di2, 0) )
	      where astore = @store and asettleno = @settleno and adate = @date
	      and bwrh = @bwrh and bgdgid = @bgdgid and bvdrgid = @bvdrgid
    
    fetch next from c_vdrdrpt into  @astore, @bvdrgid, @mwrh, @bwrh, @bgdgid
  end
  close c_vdrdrpt
  deallocate c_vdrdrpt

end
GO
