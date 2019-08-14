SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ICCardBlkLstRcv]
as 
begin
  declare @UserProperty int, @UserGID int
  declare @count int

  select @UserGID = UserGID,@UserProperty = UserProperty from System(nolock)--added nolock by hxs 2003.03.02任务单号2003030243129
  if @UserProperty < 16
  begin
    select @count = count(*) from niccardBlkLst where Rcv = @UserGID
    if isnull(@Count,0) <> 0 
    begin
	    delete from ICCardBlkLst
	    insert into ICCardBlkLst
	      select distinct CardNum from NICCardBlkLst where Rcv = @UserGID
			and cardNum <> '-1'
	    delete from NICCardBlkLst where Rcv = @UserGID
    end
  end
end
GO
