SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure  [dbo].[genbpck] 
 @p_breakonvendor int,
 @p_breakonsubcode int,
 @p_breakonhj int,
 @p_breakonsubwrh int ,
 @p_breakonpsr int,
 @p_breakstr char(30), --add by qyx
 @p_maxcount int ,
 @p_filler int,
 @p_firstnum varchar(10)
as
begin
    
 declare @wrh int,@gdgid int,@vdrgid int,@shj varchar(64),@spsr int ,@subwrh int,@lhz varchar(64),@tm char(13)
 declare @sortcode char(13), @subcode char(13), @last_hj varchar(64), @last_psr int 
 declare @last_wrh int, @last_gdgid int, @last_vdrgid int ,@last_subwrh int 
 declare @last_sortcode char(13), @last_subcode char(13),@last_lhz varchar(64),@last_tm char(13)
 declare @code_from char(13), @code_to char(13)
 declare @vendorcode varchar(10), @vendorname varchar(50)
 declare @psrcode  varchar(10), @psrname varchar(50)
 declare @subwrhcode char(20) , @subwrhname char(30) 
 declare @note varchar(255)
  
 declare @pgid int
 declare @num char(10)
 declare @settleno int
 declare @fildate datetime

 declare @counter int

 select @settleno = max(no) from monthsettle
 if (@settleno is null)
 begin
     raiserror( 'usp genbpck: get current settleno failed!', 16, -1 )
     return
 end
 select
     @counter = 0,
     @fildate = getdate(),
     @code_from = '',
     @code_to ='',
     @vendorcode ='',
     @vendorname = '',
     @note = ''


 if @p_firstnum is null 
 begin
     select @num = max(num) from bpck
     if (@num is null)
         select @num = '0000000001'
     else
         execute nextbn @num, @num output
 end else 
 begin
     select @num = @p_firstnum
     if exists(select * from bpck where num = @num)
     begin
         select @num = max(num) from bpck
         execute nextbn @num, @num output 
     end
 end

declare goodscursor cursor for
     select wrh, gdgid, vdrgid, sortcode, subcode, shj, spsr ,subwrh, slhz, stm
     from #bpckdata
open goodscursor
 
  if (@@error <> 0)
  begin 
      raiserror( ' usp genbpck: open goods cursor failed!' ,16, -1 )
      return
  end

  fetch next from goodscursor into @wrh,@gdgid,@vdrgid,@sortcode,@subcode,@shj,@spsr,@subwrh,@lhz,@tm 
  if (@@fetch_status <> 0)
  begin
      close goodscursor
      deallocate goodscursor
      return
  end
  select
     @last_wrh       = @wrh,
     @last_gdgid     = @gdgid,
     @last_vdrgid    = @vdrgid,
     @last_sortcode  = @sortcode,
     @last_subcode   = @subcode,
     @last_hj        = @shj ,
     @last_psr       = @spsr ,
     @last_subwrh    = @subwrh,
     @last_lhz       = @lhz ,
     @last_tm        = @tm

  select @code_from = code from goods where gid = @gdgid

  begin transaction

    insert into bpck( num,  settleno,  fildate,    filler, wrh, stat, reccnt, note )
           values(@num, @settleno, @fildate, @p_filler,@wrh,    0,      0, null )

    if (@@error <> 0)
    begin
      raiserror( 'usp genbpck: insert into bpck failed!',16,-1 ) 
      rollback transaction 
      close goodscursor 
      deallocate goodscursor 
      return
    end 

    while (@@fetch_status = 0)
    begin
      select @counter = @counter + 1
      insert into bpckdtl( num,     line,  settleno, stat,  gdgid, qty, total, cknum, ckline ,subwrh  ) 
                  values(@num, @counter, @settleno,    0, @gdgid,   0,     0,  null,   null ,@subwrh )
      if exists (select pgid from pkg where egid=@gdgid )
      begin   
         declare pkgcursor cursor for 
         select pgid from pkg  where egid=@gdgid 
         open pkgcursor
         if (@@error <> 0)
         begin
             raiserror( 'usp genbpck: open pkg cursor failed!',16, -1 ) 
             return
         end
         fetch next from pkgcursor into @pgid 
         if (@@fetch_status <> 0)
         begin
             close pkgcursor
             deallocate pkgcursor
             return
         end
         while @@fetch_status = 0 
         begin 
             select @counter = @counter + 1
             insert into bpckdtl( num,    line, settleno,stat, gdgid, qty, total, cknum, ckline,subwrh )
                          values(@num,@counter,@settleno,   0, @pgid,   0,     0,  null,   null,@subwrh)
             fetch next from pkgcursor into @pgid  
         end 
         close pkgcursor
         deallocate pkgcursor
      end 
 
      if (@@error <> 0) 
      begin
         raiserror( 'usp genbpck: insert into bpckdtl failed!' ,16,-1 )
         rollback transaction
         close goodscursor
         deallocate goodscursor
         return
      end
     
      select
        @last_wrh       = @wrh,
        @last_gdgid     = @gdgid,
        @last_vdrgid    = @vdrgid,
        @last_sortcode  = @sortcode,
        @last_subcode   = @subcode,
        @last_hj        = @shj ,
        @last_psr       = @spsr ,
        @last_subwrh    = @subwrh,
        @last_lhz       = @lhz ,
        @last_tm        = @tm

     fetch next from goodscursor into @wrh,@gdgid,@vdrgid,@sortcode,@subcode,@shj,@spsr,@subwrh,@lhz,@tm 

     if (@p_maxcount > 0 and @counter >= @p_maxcount)
         or ( @wrh <> @last_wrh)
         or ( @p_breakonsubwrh  > 0 and @subwrh <> @last_subwrh )
         or ( @p_breakonvendor  > 0 and @vdrgid <> @last_vdrgid)
         or ( @p_breakonsubcode > 0 and @subcode <> @last_subcode)
         or ( @p_breakonhj      > 0 and @shj <> @last_hj  )
         or ( @p_breakonpsr     > 0 and @spsr <>@last_psr )
         or ( (substring(@p_breakstr,1,1) = '1') and (@lhz <> @last_lhz) )
         or ( (substring(@p_breakstr,2,1) = '1') and (@tm  <> @last_tm ) )
     begin
         select @code_to = code from goods where gid = @gdgid 
         select @note = null 
         if (@p_breakonsubcode > 0)
             select @note = @note + ' 商品类别: ' + ltrim(@last_subcode) 
         if (@p_breakonvendor > 0)
         begin
             select @vendorcode = code, @vendorname = name from vendor where gid = @last_vdrgid 
             select @note = @note + ' 供应商：' +@vendorname+'(' + @vendorcode+')'
         end
         if ( @p_breakonhj > 0 )
             select @note = @note + ' 货架：'+ ltrim(@last_hj)
         if  (@p_breakonpsr > 0)
         begin 
             select @psrcode = code, @psrname = name from employee where gid = @last_psr 
             select @note = @note + ' 采购员：'+ @psrname +'(' + @psrcode + ')' 
         end 
         if (@p_breakonsubwrh > 0 ) 
         begin 
             select @subwrhcode = code,@subwrhname= name from subwrh(nolock) where gid =@last_subwrh 
             select @note =@note + ' 货位: '+ rtrim(@subwrhname)+ '('+rtrim(@subwrhcode)+')'
         end 
         
         if ( substring(@p_breakstr,1,1) = '1' )
             select @note = @note + ' 理货组：'+ ltrim(@last_lhz)

         if ( substring(@p_breakstr,2,1) = '1' )
             select @note = @note + ' 商标：'  + ltrim(@last_tm)


         update bpck set reccnt = @counter, note = ltrim(@note) where num = @num
         if (@@error <> 0)
         begin
             raiserror( ' usp genbpck: update bpck failed! ',16,-1 ) 
             rollback transaction
             close goodscursor
             deallocate goodscursor 
             return
         end

         commit transaction

         select
           @counter = 0,
           @code_from = '', 
           @code_to = '',
           @vendorcode = '',
           @vendorname = ''

         execute nextbn @num, @num output
         if exists(select * from bpck where num = @num)
         begin 
             select @num = max(num) from bpck
             execute nextbn @num, @num output 
         end 

         begin transaction
         insert into bpck(  num,  settleno,    filler,  fildate, wrh, stat, reccnt, note )
                   values( @num, @settleno, @p_filler, @fildate,@wrh,    0,      0, null )
         if (@@error <> 0)
         begin
             raiserror( ' usp genbpck: insert into bpck failed! ',16,-1 ) 
             rollback transaction
             close goodscursor
             deallocate goodscursor
             return
         end
         select @code_from = code from goods where gid = @gdgid
     end
 end 

 if (@counter <> 0)
 begin
     select @code_to = code from goods where gid = @last_gdgid
     select @note = null 
     if (@p_breakonsubcode > 0)
          select @note = @note + ' 商品类别：' + ltrim(@last_subcode)
     if (@p_breakonvendor > 0)
     begin
          select @vendorcode = code, @vendorname = name from vendor where gid = @last_vdrgid
          select @note = @note + ' 供应商：' + @vendorname +'(' + @vendorcode +')' 
     end
     if (@p_breakonhj > 0 )
     begin 
         select @note =@note + ' 货架：'  + ltrim(@last_hj) 
     end  
     if (@p_breakonpsr > 0)
     begin 
         select @psrcode = code, @psrname = name from employee where gid = @last_psr 
         select @note = @note + ' 采购员：' + @psrname + '(' + @psrcode + ')'
     end 

     if (@p_breakonsubwrh > 0  ) 
     begin 
         select @subwrhcode = code,@subwrhname= name from subwrh(nolock) where gid =@last_subwrh 
         select @note =@note + ' 货位: '+ rtrim(@subwrhname)+ '('+rtrim(@subwrhcode)+')'
     end 

     if ( substring(@p_breakstr,1,1) = '1' )
         select @note = @note + ' 理货组：'+ ltrim(@last_lhz)

     if ( substring(@p_breakstr,2,1) = '1' )
         select @note = @note + ' 商标：'  + ltrim(@last_tm)

     update bpck set reccnt = @counter, note = ltrim(@note) where num = @num
     if (@@error <> 0)
     begin
         raiserror( ' usp genbpck: update bpck failed! ',16,-1 )
         rollback transaction
         close goodscursor
         deallocate goodscursor
         return
     end
     commit transaction
 end else
 begin
     delete from bpck where num = @num
     commit transaction 
 end 

 close goodscursor
 deallocate goodscursor

 return
end
GO
