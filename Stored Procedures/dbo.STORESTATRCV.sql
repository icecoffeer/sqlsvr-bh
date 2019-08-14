SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STORESTATRCV](
    @src_id int,
    @bill_id int,
    @Oper varchar(50),
    @Msg varchar(255) output
)as
begin
  declare
    @User_Prop int

  select @User_Prop = USERPROPERTY from System(nolock);
  if @User_Prop & 16 = 16
    begin
      delete from STORESTAT where STOREGID IN (select STOREGID from NSTORESTAT(nolock)
                    where SRC = @src_id )

      insert into STORESTAT(UUID, STOREGID, BEGINDATE, STATTYPENAME, STOPDAYS, NOTE)
                    select UUID, STOREGID, BEGINDATE, STATTYPENAME, STOPDAYS, NOTE
                    from NSTORESTAT(nolock)
                    where SRC = @src_id and TYPE = 1;

      delete from NSTORESTAT where TYPE = 1 and SRC = @src_id;
    end;
  return(0);
end;
GO
