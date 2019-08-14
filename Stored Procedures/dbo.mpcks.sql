SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[mpcks]
   @posno char(10),
   @gdgid  int
with encryption as
begin
   declare
	@t_wrh int,
	@settleno int,
	@t_line int,
        @t_acntqty money,
	@t_acnttl money,
	@t_qty money,
	@t_total money,
	@d_qty money,
	@d_total money,
	@t_inprc money,
	@t_rtlprc money,
	@t_losamt money,
	@t_ovfamt money,
	@prctype int,
        @adate datetime

select @settleno=max(no) from monthsettle
select @t_wrh=gid from warehouse where code=@posno
select @t_qty = qty, @t_total = amount, @t_inprc = inprc, @t_rtlprc = price 
       from mckpool 
       where gdgid = @gdgid and posno = @posno

select @t_line = null
select @t_line = max(line)+1 from pcks
if @t_line is null select @t_line=1
    select 
     @t_acntqty = qty,
     @t_acnttl = total
     from ckinv where wrh = @t_wrh and gdgid = @gdgid  
     if @@rowcount = 0 begin
       select @adate = getdate()
       select @t_inprc=inprc,@t_rtlprc=rtlprc
       from goods where gid=@gdgid
       insert into CKINV(wrh,gdgid,qty,total,keptdate,rtlprc,inprc)
       values( @t_wrh, @gdgid, 0, 0, getdate(), @t_rtlprc, @t_inprc )
--       execute snapinv @t_wrh , @gdgid, 0, 0, @adate,0
         select @t_acntqty=0,@t_acnttl=0
--       select @t_inprc=inprc,@t_rtlprc=rtlprc
--       from goods where gid=@gdgid
          insert into pcks(line,settleno,gdgid,wrh,acntqty,qty,
          acnttl,total,ovfamt,losamt,inprc,rtlprc)
          values(@t_line,@settleno,@gdgid,@t_wrh,@t_acntqty,0,
           @t_acnttl,0,0,0,@t_inprc,@t_rtlprc)
      end	
  select @prctype = prctype from goods where gid = @gdgid
  select
    @t_acntqty = ACNTQTY,
    @d_qty = QTY,
    @t_acnttl = ACNTTL,
    @d_total = TOTAL,
    @t_rtlprc = RTLPRC
  from PCKS where GDGID = @gdgid and WRH = @t_wrh
  select @t_qty=@t_qty+@d_qty,@t_total=@t_total+@d_total 
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
  update pcks set
    qty=@t_qty, total=@t_total,
    LOSAMT = @t_losamt, OVFAMT = @t_ovfamt
    where WRH = @t_wrh and GDGID = @gdgid
return
end
GO
