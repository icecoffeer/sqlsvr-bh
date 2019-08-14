SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[topcks]
@termno char(13)
with encryption as
begin
declare @return_status int,
	@c_wrh char(13),
	@c_gd  char(13), 
	@t_wrh int,
	@gdgid int,
	@t_qty money,
	@d_qty money,
	@t_rtlprc money,
	@t_inprc money,
	@t_total money,
	@d_total money,
	@settleno int,
	@t_acntqty money,
	@t_acnttl money,
        @t_line  int,
	@d_line  int,
	@t_losamt money,
	@t_ovfamt money,
	@adate datetime,
	@prctype int,
	@inputer char(13),
	@idno int,
	@e_gdgid int,
	@mult money

select @settleno=max(no) from monthsettle
declare termcursor  cursor for
       select  wrhcode, gcode ,qty ,price, amount, inputer, id, line
	from termpool
	where termno=@termno
      open termcursor
 fetch next from termcursor into @c_wrh ,@c_gd ,@t_qty ,@t_rtlprc ,@t_total ,@inputer ,@idno ,@d_line
while @@fetch_status = 0
  begin
    select @t_wrh = gid from warehouse where code=@c_wrh
    select @gdgid from goods where code=@c_gd
    if (select ISPKG from GOODS where GID = @gdgid) = 1
    begin
    /* 如果该商品是大包装的,进行转换 */
    execute @return_status = UNPACK @gdgid, @e_gdgid output, @mult output
    if @return_status <> 0   break
    select @gdgid = @e_gdgid, @t_qty = @t_qty * @mult, @t_total = @t_total * @mult
    end
    select @t_line = null
    select @t_line = LINE from PCKS where GDGID = @gdgid and WRH = @t_wrh
    if @t_line is null begin
    select @t_line = max(line)+1 from pcks
    if @t_line is null select @t_line=1
    select 
     @t_inprc = inprc,
     @t_rtlprc = rtlprc,		
     @t_acntqty = qty,
     @t_acnttl = total
     from ckinv where wrh = @t_wrh and gdgid = @gdgid  
     if @@rowcount = 0 begin
      select @adate = getdate()
       execute snapinv @t_wrh , @gdgid, 0, 0, @adate,0
       select @t_acntqty=0,@t_acnttl=0
       select @t_inprc=inprc,@t_rtlprc=rtlprc
       from goods where gid=@gdgid
       end
      insert into pcks(line,settleno,gdgid,wrh,acntqty,qty,
          acnttl,total,ovfamt,losamt,inprc,rtlprc)
          values(@t_line,@settleno,@gdgid,@t_wrh,@t_acntqty,0,
           @t_acnttl,0,0,0,@t_inprc,@t_rtlprc)
     end
    select @prctype = prctype from goods where gid = @gdgid
    select
       @t_acntqty = acntqty,
       @d_qty = qty,
       @t_acnttl = acnttl,
       @d_total = total,
       @t_rtlprc = rtlprc
    from PCKS where GDGID = @gdgid and WRH = @t_wrh
    select @t_qty = @t_qty+@d_qty, @t_total = @t_total+@d_total
    if @prctype = 1 begin
    if @t_total > @t_acnttl
      select @t_losamt = 0, @t_ovfamt = @t_total - @t_acnttl
    else
      select @t_losamt = @t_acnttl - @t_total, @t_ovfamt = 0
    end else begin
    if @t_qty > @t_acntqty
      select @t_losamt = 0, @t_ovfamt = (@t_qty-@t_acntqty)*@t_rtlprc
    else
      select @t_losamt = (@t_acntqty-@t_qty)*@t_rtlprc, @t_ovfamt = 0
  end
  update pcks set qty = @t_qty, total = @t_total,
    LOSAMT = @t_losamt, OVFAMT = @t_ovfamt
    where WRH = @t_wrh and GDGID = @gdgid
  fetch next from termcursor into @c_wrh ,@c_gd ,@t_qty ,@t_rtlprc ,@t_total ,@inputer ,@idno ,@d_line
 end
 close termcursor
 deallocate termcursor
end
return
GO
