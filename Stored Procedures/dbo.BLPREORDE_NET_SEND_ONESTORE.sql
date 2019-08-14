SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[BLPREORDE_NET_SEND_ONESTORE]
  (
  @piNum    varchar(32),
  @piRcv    int,
  @piUID   int,
  @poErrMsg varchar(255) output
  )
  as
  begin
    set nocount on;     
    declare @vNID   int;
    declare @vItem  int; 

    
    /*
    
    
    
    select @vItem = STAT
      from BLPREORD
      where NUM = @piNUM;
      
    if @@rowcount = 0
    begin
      set @poErrMsg = '单据不存在。';
      return(1);
    end;
    
    if @vItem = 0
    begin
      set @poErrMsg = '单据状态不符，拒绝发送。';
      return(1);
    end;
    */
    
    exec GETNETBILLID @vNID output;
    
    insert into NBLPREORD( [ID], RCV, SRC, FRCCHK,NTYPE ,NSTAT ,NNOTE
                         , NUM, STAT, PREORDSET, PSR, FILDATE, FILLER, CHECKER, CHKDATE 
                         , DEADDATE,LSTUPDTIME ,PRNTIME ,SNDTIME ,SETTLENO,NOTE, RECCNT 
                         )
             select @vNID, @piRcv, @piUID, 1, 0, 0, null
                         , NUM, STAT, PREORDSET, PSR, FILDATE, FILLER, CHECKER, CHKDATE 
                         , DEADDATE,LSTUPDTIME ,PRNTIME ,getdate() ,SETTLENO,NOTE, RECCNT 
              from BLPREORD
              where NUM = @piNum;   
    
    insert into NBLPREORDDTL( [ID], SRC, NUM, LINE, FLAG
                            , GDGID, MINORDCases, MINORDQTY, ORDPRC, RTLPRC, WHSPRC, NOTE)
              select @vNID, @piUID, NUM, LINE, FLAG
                            , GDGID, MINORDCases, MINORDQTY, ORDPRC, RTLPRC, WHSPRC, NOTE
              from BLPREORDDTL	
              where NUM = @piNum;       
              
    return (0);
  end
GO
