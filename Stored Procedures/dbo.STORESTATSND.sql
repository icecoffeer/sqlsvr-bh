SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STORESTATSND]
as
begin
  declare
    @user_gid int,
    @zbgid int,
    @User_Prop int,
    @ID int

  exec GetNetBillID @ID output;
  select @user_gid = UserGid,@zbGid = ZBGID, @User_Prop = USERPROPERTY from System(nolock);
  if @User_Prop & 16 <> 16
  begin
    delete from NSTORESTAT where TYPE = 0;
    insert into NSTORESTAT(RCV, ID, UUID, STOREGID, BEGINDATE, STATTYPENAME, STOPDAYS, NOTE, TYPE, SRC)
                  select @zbgid, @ID, UUID, STOREGID, BEGINDATE, STATTYPENAME, STOPDAYS, NOTE, 0, @user_gid
                  from STORESTAT(nolock);
  end;
  return(0);
end
GO
