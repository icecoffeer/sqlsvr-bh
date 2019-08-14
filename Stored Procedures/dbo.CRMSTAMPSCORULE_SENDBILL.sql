SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CRMSTAMPSCORULE_SENDBILL]
(
  @num      varchar(14),
  @cls      varchar(10),
  @src      int,
  @rcv      int,
  @msg  varchar(255) output
)
as
begin
  declare @id int
  execute GetNetBillId @id output

  insert into NCRMSTAMPSCORULE(NUM,CLS,STAT,FILDATE,FILLER,SNDTIME,PRNTIME,CHKDATE,CHECKER,ABORTDATE,ABORTER,LSTUPDTIME,LSTUPDOPER,NOTE,SETTLENO,RECCNT,SRC,ID,RCV,RCVTIME,TYPE,NSTAT,NNOTE)  
  select NUM,CLS,STAT,FILDATE,FILLER,getdate(),PRNTIME,CHKDATE,CHECKER,ABORTDATE,ABORTER,LSTUPDTIME,LSTUPDOPER,NOTE,SETTLENO,RECCNT, @src, @id, @rcv, NULL, 0, 0, ''    
  from CRMSTAMPSCORULE(nolock)
  where num = @num 

  insert into NCRMSTAMPSCORULEDTL(NUM,LINE,CLS,UUID,TOTAL,SCORE,SCOTOP,BEGINDATE,ENDDATE,NOTE,SRC,ID)
  select NUM,LINE,CLS,UUID,TOTAL,SCORE,SCOTOP,BEGINDATE,ENDDATE,NOTE, @src, @id
  from CRMSTAMPSCORULEDTL(nolock)
  where num = @num 

  insert into NCRMSTAMPSCORULEDTL2(NUM,LINE,CLS,GOODS,CODE,NAME,NOTE,SRC,ID)
  select NUM,LINE,CLS,GOODS,CODE,NAME,NOTE, @src, @id
  from CRMSTAMPSCORULEDTL2(nolock)
  where num = @num 

  insert into NCRMSTAMPSCORULELACSTORE(NUM,CLS,STOREGID,SRC,ID)   
  select NUM,CLS,STOREGID,@src, @id
  from CRMSTAMPSCORULELACSTORE(nolock)
  where num = @num 
                                   
  return 0                         
end
GO
