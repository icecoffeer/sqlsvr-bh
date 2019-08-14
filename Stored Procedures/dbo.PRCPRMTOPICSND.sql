SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMTOPICSND]
(
    @p_rcv int,
    @n_billid int
) with encryption as
begin
  declare
    @user_gid int,
    @User_Prop int
  select @user_gid = UserGid, @User_Prop = USERPROPERTY from System(nolock);
  if @User_Prop & 16 = 16
    begin
      delete from NPRMTOPIC where RCV = @p_rcv;
      insert into NPRMTOPIC(RCV, ID, CODE, NAME, NOTE, CREATOR, CREATETIME, MODIFIER, LSTUPDTIME, PRI, TYPE, SRC)
                    select @p_rcv, @n_billid, CODE, NAME, NOTE, CREATOR, CREATETIME, MODIFIER, LSTUPDTIME, PRI, 0, @user_gid
                    from PRMTOPIC(nolock);
    end;
  return(0);
end
GO
