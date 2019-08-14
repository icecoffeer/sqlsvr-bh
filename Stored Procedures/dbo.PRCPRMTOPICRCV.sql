SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMTOPICRCV](
    @p_src int,
    @p_id int
) with encryption as
begin
  declare
    @User_Prop int

  select @User_Prop = USERPROPERTY from System(nolock);
  if @User_Prop & 16 <> 16
    begin
      delete from PRMTOPIC where CODE IN (select CODE from NPRMTOPIC);
      insert into PRMTOPIC(CODE, NAME, NOTE, CREATOR, CREATETIME, MODIFIER, LSTUPDTIME, PRI)
                    select CODE, NAME, NOTE, CREATOR, CREATETIME, MODIFIER, LSTUPDTIME, PRI
                    from NPRMTOPIC(nolock)
                    where SRC = @p_src
                      and ID = @p_id;
    end;
  return(0);
end;
GO
