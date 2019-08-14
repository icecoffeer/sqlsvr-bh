SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ABOLISHORD](
	@num char(10)
)
as
begin
        declare @src int, @qty money, @gdgid int, @wrh int, @alc char(10)
        select @src = USERGID from SYSTEM
	if not exists(select * from ORD where NUM = @num and STAT = 1
        		and FINISHED = 0)        --2002.08.16 Jianweicheng 删除SRC = @src
	begin
		raiserror('将被取消的单据不存在!', 16, 1)
		return(1)
	end

        update ORD set FINISHED = 1 where NUM = @num

 	if (select RECEIVER from ORD where NUM = @num) = @src	--20010702 CQH
	--//只有要货单位为本单位的定货单才影响在单量
	begin
        	declare c_ord cursor for
		  select GDGID, WRH, -(QTY-ARVQTY) from ORDDTL where NUM = @num
		open c_ord
		fetch next from c_ord into @gdgid, @wrh, @qty
		while @@fetch_status = 0
		begin
		    select @alc = alc from goods(nolock) where gid = @gdgid
			-- 在单量
			--2006.11.29 added by zhanglong, 供应单位若为总部，则配货方式必须为‘统配’才可影响在单量
			if not exists(select 1 from store s(nolock), ord o(nolock) where s.gid = o.vendor and o.num = @num)
				or (@alc = '统配')
				execute IncOrdQty @wrh, @gdgid, @qty

			fetch next from c_ord into @gdgid, @wrh, @qty
		end
		close c_ord
		deallocate c_ord
	end

	--2003.01.07
	exec OrdUpdAlcPool @num

end
GO
