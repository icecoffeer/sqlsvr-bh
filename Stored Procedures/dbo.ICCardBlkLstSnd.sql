SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ICCardBlkLstSnd]
  @Store int
as begin
  declare @ID int, @UserGID int, @UserProperty int, @CardNum char(20)
  declare cur_cbl cursor for select * from ICCardBlkLst


  select @UserGID = UserGID,@UserProperty = UserProperty from System(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  if @UserProperty < 16 return


  delete from NICCardBlkLst where Rcv = @Store

  insert into NICCardBlkLst(CardNum, Src, Rcv, SndTime, FrcChk, NType, NStat)
      values('-1', @UserGID, @Store, GetDate(), 1, 0, 0)

  open cur_cbl
  fetch next from cur_cbl into @CardNum
  while @@fetch_status = 0
  begin
    insert into NICCardBlkLst(CardNum, Src, Rcv, SndTime, FrcChk, NType, NStat)
      values(@CardNum, @UserGID, @Store, GetDate(), 1, 0, 0)
    fetch next from cur_cbl into @CardNum
  end
  close cur_cbl
  deallocate cur_cbl
end
GO
