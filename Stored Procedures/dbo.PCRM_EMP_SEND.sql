SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_EMP_SEND]    
(
  @piGid int, 
  @piRcvGid int,     
  @poErrMsg varchar(100) output    
) as
begin
  declare
    @m_OperNameCode varchar(100),
    @sWorkStation varchar(100),
    @m_OperTime datetime,
    @nID int
  select @m_OperTime = getdate()
  select @sWorkStation = HOST_NAME()
  
  delete from NCRMWEBEMP where GID = @piGid and RCV = @piRcvGid;
  EXEC @nID = SEQNEXTVALUE 'NCRMWEBEMP'
  
  insert into NCRMWEBEMP(ID, RCV, FRCCHK, NTYPE, NSTAT, GID, ISWEBUSER, WEBPWD,
                         STARTDATE,ENDDATE, INEFFECT,STORE, MEMO, SRC, SNDTIME, CREATETIME, 
                         CREATOR, LSTUPDTIME,LSTUPDOPER)
    select @nID, @piRcvGid, 1, 0, 0, GID, ISWEBUSER, WEBPWD,
      STARTDATE,ENDDATE, INEFFECT,STORE, MEMO, SRC, SNDTIME, CREATETIME, 
      CREATOR, LSTUPDTIME,LSTUPDOPER 
    from CRMWEBEMP  where Gid = @piGid
    
  return (0)
end
GO
