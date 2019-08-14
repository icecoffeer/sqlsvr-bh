SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ShouldExchgDataTicketCheck]
	@SendDate datetime,
	@src int,
	@tgt int,
	@ErrMsg varchar(255) output
as
begin
	declare @cls varchar(20),@num varchar(20)
	declare @Result int
	update shouldexchgdatadtl set finished = 1
		from realexchgdatadtl r(nolock)
		where shouldexchgdatadtl.src = r.src and shouldexchgdatadtl.tgt = r.tgt
			and shouldexchgdatadtl.cls = r.cls
			and shouldexchgdatadtl.num = r.num 
			and shouldexchgdatadtl.checkint1 = r.checkint1
			and ((shouldexchgdatadtl.checkint2 = r.checkint2) or (Shouldexchgdatadtl.checkint2 in(1,6) and r.checkint2 in (1,6))) 
			and shouldexchgdatadtl.checkint3 = r.checkint3
			and shouldexchgdatadtl.checkdata1 = r.checkdata1
			and shouldexchgdatadtl.checkdata2 = r.checkdata2
			and shouldexchgdatadtl.checkdata3 = r.checkdata3
			and shouldexchgdatadtl.finished = 0
			and r.recvdate >= dateadd(day,-7,@senddate)
			and r.src = @src
			and r.tgt = @tgt

  if not exists(select 1 from ShouldExchgDataDtl (nolock) where SendDate = @SendDate 
    and src = @src and tgt = @tgt and Finished = 0)
    update ShouldExchgData set Finished = 1 
    where  SendDate = @SendDate and src = @src and tgt = @tgt
  else
    update ShouldExchgData set Finished = 0
    where  SendDate = @SendDate and src = @src and tgt = @tgt

	return 0
end
GO
