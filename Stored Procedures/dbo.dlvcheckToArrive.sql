SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[dlvcheckToArrive](
  @num char(10),
  @flag int  --@flag = 1 已送货  @flag = 0 取消送货
) as
begin
  declare
    @qty    money,
    @gdgid      int,
    @msg	varchar(255),
    @dspwrh     int,
    @cls char(10),
    @posno  char(10),
    @flowno char(12),
    @itemno smallint

    declare c_dlvdtl cursor for
    select qty, gdgid, cls, posno, flowno, itemno  from dlvdtl  where num = @num order by line
    open c_dlvdtl
    fetch next from c_dlvdtl into @qty, @gdgid, @cls, @posno, @flowno, @itemno
    while @@fetch_status = 0
    begin
             if @cls = '零售'
     	        select @dspwrh = isnull(wrh,1) from buy2(nolock) where posno=@posno and flowno=@flowno and itemno = @itemno
             else if @cls = '批发'
                select @dspwrh = isnull(wrh,1) from stkoutdtl(nolock) where cls = '批发' and num=@flowno and line = @itemno
	     if @@rowcount = 0
	     begin
	          set @msg = '对应送货单审核产生的待提货仓位没有找到'
		  raiserror(@msg, 16, 1)
		  return 1
	     end
	     if @flag = 1
	     begin
	          update inv  set dspqty = dspqty - @qty  where gdgid = @gdgid and wrh = @dspwrh
	     end
	     else begin
	          update inv  set dspqty = dspqty + @qty  where gdgid = @gdgid and wrh = @dspwrh
	     end
             fetch next from c_dlvdtl into @qty, @gdgid, @cls, @posno, @flowno, @itemno
    end
    close c_dlvdtl
    deallocate c_dlvdtl

    return(0)
end
GO
