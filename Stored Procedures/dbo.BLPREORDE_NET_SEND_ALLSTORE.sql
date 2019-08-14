SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[BLPREORDE_NET_SEND_ALLSTORE]
  (
  @piNum    varchar(32),
  @piOper   int,
  @poErrMsg varchar(255) output
  )
  as
  begin
    set nocount on;     
    declare @vNID   int;
    declare @vUID   int;
    declare @vZID   int;
    declare @vItem  int;    
    declare @vloop  int;    
    declare @vTop   int;    
    
    select @vUID = USERGID, @vZID = ZBGID
      from SYSTEM;
    if @@rowcount = 0
    begin
      set @poErrMsg = '门店信息访问出错。';
      return(1);
    end;
    if @vUID <> @vZID
    begin
      set @poErrMsg = '本店不是总部，而此单据只能由总部发往门店。';
      return(1);
    end;
    
    select @vItem = STAT
      from BLPREORD
      where NUM = @piNUM;
      
    if @@rowcount = 0
    begin
      set @poErrMsg = '单据不存在。';
      return(1);
    end;
    
    if @vItem <> 100
    begin
      set @poErrMsg = '单据状态不符，拒绝发送。';
      return(1);
    end;
        
    create table #TMP_NUM( tid int not null identity(1,1)  not for replication
                         , stid int default 0 not null
                         , primary key (tid));
                         
    exec GETNETBILLID @vNID output;
        
    insert into BLPREORDLOG(NUM, STAT, ACT, MODIFIER, [TIME])	
           values(@piNum, 100, '发往生效门店', @piOper, getdate());
           
    insert into #TMP_NUM(stid)  
         select ac.STOREGID 
           from BLPREORD mst, BLPREORDLAC ac
          where mst.NUM = ac.NUM 
            and mst.NUM = @piNum;
    
    select @vloop = min(tid), @vTop = max(tid)
      from #TMP_NUM;

    while @vloop <= @vTop
    begin
      
      select @vItem = stid  
        from #TMP_NUM 
       where tid = @vloop;  
      
      exec BLPREORDE_NET_SEND_ONESTORE @piNum, @vItem, @vUID, @poErrMsg out
      set @vloop = @vloop + 1;
    end;

    /*
    
    insert into BLPREORDLOG(NUM, STAT, ACT, MODIFIER, [TIME])	
         select mst.NUM, mst.STAT, 'send', @piOper, getdate()
              from BLPREORD mst
              where mst.NUM = @piNum;   
              
    insert into NBLPREORD( [ID], RCV, SRC, FRCCHK,NTYPE ,NSTAT ,NNOTE
                         , NUM, STAT, PREORDSET, PSR, FILDATE, FILLER, CHECKER, CHKDATE 
                         , DEADDATE,LSTUPDTIME ,PRNTIME ,SNDTIME ,SETTLENO,NOTE, RECCNT 
                         )
             select @vNID, ac.STOREGID, @vUID, 1, 0, 0, null
                         , mst.NUM, STAT, PREORDSET, PSR, FILDATE, FILLER, CHECKER, CHKDATE 
                         , DEADDATE,LSTUPDTIME ,PRNTIME ,SNDTIME ,SETTLENO,NOTE, RECCNT 
              from BLPREORD mst, BLPREORDLAC ac
              where mst.NUM = ac.NUM 
                and mst.NUM = @piNum;   
                
    insert into NBLPREORDDTL( [ID], SRC, NUM, LINE, FLAG
                            , GDGID, MINORDCases, MINORDQTY, ORDPRC, RTLPRC, WHSPRC, NOTE)
              select @vNID, ac.STOREGID, mst.NUM, LINE, FLAG
                            , GDGID, MINORDCases, MINORDQTY, ORDPRC, RTLPRC, WHSPRC, dtl.NOTE
              from BLPREORDDTL dtl, BLPREORD mst, BLPREORDLAC ac             
              where dtl.NUM = mst.NUM
                and mst.NUM = ac.NUM
                and mst.NUM = @piNum;       
                
    */
    
    update BLPREORD 
       set SNDTIME = getdate()
     where NUM = @piNum;
   
    return(0);
  end
GO
