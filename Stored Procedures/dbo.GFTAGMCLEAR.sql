SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTAGMCLEAR]
as
begin
  declare 
                @p_lstid                        char(16),
                @p_storegid                     int,
                @p_num                          char(10)

  declare c_gift cursor for
  select LSTID, STOREGID from GIFT where FINISH < getdate()
  for update
  open c_gift
  fetch next from c_gift into @p_lstid, @p_storegid
  while @@fetch_status = 0
  begin
                if not exists(select 1 from GIFTHST where LSTID = @p_lstid and STOREGID = @p_storegid)
                begin
                                insert into GIFTHST(LSTID, STOREGID, VENDOR, START, FINISH, GDGID, INQTY,
                                                GFTGID, GFTQTY, SRCNUM, SRCLINE, CANCELDATE, GFTWRH)
                                select LSTID, STOREGID, VENDOR, START, FINISH, GDGID, INQTY,
                                                GFTGID, GFTQTY, SRCNUM, SRCLINE, getdate(), GFTWRH
                                from GIFT where LSTID = @p_lstid and STOREGID = @p_storegid
                end
                delete from GIFT where current of c_gift
                if @@error <> 0
                begin
                                close c_gift
                                deallocate c_gift
                                return @@error
                end
                                
                fetch next from c_gift into @p_lstid, @p_storegid
  end
  close c_gift
  deallocate c_gift
  
  /*协议已结束*/
  declare c_gftagm cursor for
  select num from gftagm where finished = 0 and stat = 1
  for update of finished
  open c_gftagm
  fetch next from c_gftagm into @p_num
  while @@fetch_status = 0
  begin
                if not exists(select 1 from gftagmdtl(nolock)
                                where num = @p_num and stat = 0 and finish > getdate())
                                update gftagm set finished = 1 where current of c_gftagm
                                
                fetch next from c_gftagm into @p_num
  end
  close c_gftagm
  deallocate c_gftagm
end
GO
