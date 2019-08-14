SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DMDPRMCHK](
    @num char(10),
    @operater int,
    @ntype smallint,    --0 提交 1批准
    @genprcprmnum char(10) output
) as
begin
    declare
      @return_status int,
      @stat smallint,
      @ratifystore int,
      @usergid int,
      @newnum char(10),
      @src int,
      @curr_settleno int,
      @sndtime datetime,
      @line smallint,
      @New_Line smallint,
      @RecCnt int

    select @return_status = 0
    select @usergid = USERGID from SYSTEM
    select @New_Line = 0;

    select @stat = STAT,@ratifystore = RATIFYSTORE,@src=src,@sndtime=sndtime from DMDPRM where NUM = @num
    if @ntype = 0
    begin
        if @src <> @usergid
        begin
            raiserror('不是本单位产生的单据。', 16, 1)
            return(11)
        end
        if @stat <> 0
        begin
            raiserror('不是未提交的单据.', 16, 1)
            return(12)
        end
        update DMDPRM set STAT = 1,SUBMITDATE = getdate(), SUBMITTER = @operater where NUM = @num
        return(@@error)
    end
    if @stat not in (0,1)
    begin
        raiserror('批准的不是未提交或已提交的单据.', 16, 1)
        return(13)
    end
    if @ratifystore <> @usergid
    begin
        raiserror('批准单位不是本单位.', 16, 1)
        return(14)
    end
    if @sndtime is not null
    begin
        raiserror('单据已发送', 16, 1)
        return(15)
    end
    update DMDPRM set STAT = 3,RATIFYDATE = getdate(), RATIFIER = @operater where NUM = @num
    select @newnum = max(Num) from PrcPrm
    if @newnum is not null
        execute NEXTBN @newnum, @newnum output
    else
        select @newnum = '0000000001'
    select @curr_settleno = max(No) from MONTHSETTLE    

    insert into PrcPrm( Num,SettleNo,  Checker, FilDate,  Filler,   RecCnt,Stat,Eon,Src,Note,Launch, Topic)
       select @newnum,@curr_settleno,@operater, Getdate(),@operater,RecCnt,  0 ,
       Eon,@usergid,Note+'  由 '+@num+' 促销申请单生成', Launch, Topic
       from DmdPrm
          where Num = @num
    if @@error <> 0
        return(@@error)

    insert into PrcPrmLacDtl(Num,StoreGid)
            select @newnum,StoreGid
              from DmdPrmLacDtl
              where Num = @num
    if @@error <> 0
        return(@@error)

    declare cur_dmddtl cursor for
      select PD.Line
        from DmdPrmDtl PD(nolock), DmdPrmDtlDtl PDD(nolock)
        where PD.Num = @num
          and PDD.Num = @num
          and PD.LINE = PDD.LINE
          and PDD.CONFIRM = 1
          order by PD.LINE
      for read only
    open cur_dmddtl
    fetch next from cur_dmddtl into @line
    while @@fetch_status = 0
    begin
      insert into PrcPrmDtl(Num, Line,SettleNo, GdGid, PrmType,CanGft, Qpc, QpcStr)
        select @newnum, @New_Line,@curr_settleno, GdGid, PrmType, CanGft, Qpc, QpcStr
        from DmdPrmDtl (nolock)
        where Num = @num
          and LINE = @line;
      if @@error <> 0
        return(@@error)

      insert into PrcPrmDtlDtl(Num,SettleNo,Line,Item,Start,Finish,Cycle,CStart,CFinish,CSpec,QtyLo,QtyHi,
                              Price,Discount,InPrc,MbrPrc,GftGid,GftQty,GftPer,GftType,PrmTag,prmlwtprc )
            select @newnum,@curr_settleno,@New_Line,Item,Start,Finish,Cycle,CStart,CFinish,CSpec,QtyLo,QtyHi,
                              Price,Discount,InPrc,MbrPrc,GftGid,GftQty,GftPer,GftType,PrmTag,prmlwtprc
             from DmdPrmDtlDtl
             where Num = @num
               and line = @line;
      if @@error <> 0
        return(@@error)
      select @New_Line = @New_Line + 1;
      fetch next from cur_dmddtl into @line;
    end;
    close cur_dmddtl;
    deallocate cur_dmddtl;
    if @@error <> 0    
      return(@@error)    
   
    --如果促销申请单批准的商品个数是0个,则不再生成促销单  tianlei 20070815     
    if not exists (select 1 from PrcPrmDtl(nolock) where num=@newnum)    
    begin     
      delete from PrcPrm where num = @newnum    
      delete from PrcPrmdtl where num = @newnum    
      delete from PrcPrmdtldtl where num = @newnum    
      delete from PrcPrmLacDtl where num = @newnum        
      --总部批准后自动发送
      if @src <> @usergid         
      begin
        exec DMDPRMSND @num    
      end  

    end else    
    begin    
      --将生成的促销单号记到促销申请单的备注里            
      update DMDPRM set note = Note+' 生成的促销单号:'+@newnum where NUM = @num
      --总部批准后自动发送
      if @src <> @usergid         
      begin
        exec DMDPRMSND @num    
      end  
      ---更新促销单的记录数 tianlei 2008.08.21
      select @RecCnt = count(1) from PrcPrmDtl(nolock) where Num = @NewNum
      update PrcPrm set RecCnt = @RecCnt where  Num = @NewNum         

      execute @return_status = PRCPRMCHK @newnum

      if (select OptionValue from hdoption where moduleno = 63 and optioncaption = 'AutoSendBill') = '1'  --add by jinlei Q5115
      begin
        if (select OptionValue from hdoption where moduleno = 63 and optioncaption = 'FrcChk') = '1'
          execute @return_status = PrcPrmSnd @newnum, 0, 1
        else 
        	execute @return_status = PrcPrmSnd @newnum, 0, 0
      end
      select @genprcprmnum = @newnum
      return(@return_status)
   end   
end
GO
