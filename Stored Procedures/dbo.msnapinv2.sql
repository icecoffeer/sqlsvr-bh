SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[msnapinv2]
  @storegid int,
  @gdgid int
as
begin

declare @qty money,
	@rtlprc money,
	@inprc money,
	@prctype smallint,
	@total money,
	@wrh int,
	@line int,
	@settleno int 

 select @settleno=max(no) from monthsettle(nolock)  

 select @rtlprc = isnull(goods.rtlprc,0), @inprc = isnull(goods.inprc,0), @prctype = isnull(prctype,0), @qty = isnull(qty,0), @total = isnull(total,0)
	from inv(nolock),goods(nolock)
	where inv.gdgid=goods.gid
	and inv.store=@storegid
	and inv.wrh=1
	and goods.gid = @gdgid
        and inv.qty <> 0

 if exists(select 1 from gdstore where storegid = @storegid and gdgid = @gdgid)
		select @rtlprc = rtlprc from gdstore where storegid = @storegid and gdgid = @gdgid
        insert into CKINV(wrh,gdgid,qty,total,keptdate,rtlprc,inprc)
        values( @storegid, @gdgid, @qty, @total, getdate(), @rtlprc, @inprc )
        if  not exists (select * from pcks(nolock) where wrh=@storegid and gdgid=@gdgid)  begin
	  begin transaction
--           select @line=max(line)  from pcks(updlock) 
--           if @line is null     
--           select @line=0 
--           select @line=@line+1
           insert into PCKS ( SETTLENO, GDGID, WRH, ACNTQTY, QTY,  ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC)
                     values ( @settleno, @gdgid, @storegid, @qty, 0, @total, 0, 0, 0, @inprc, @rtlprc)
          commit transaction
        end  
 return
end
GO
