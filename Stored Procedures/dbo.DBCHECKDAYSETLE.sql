SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DBCHECKDAYSETLE](  
  @piSETTLEDAY datetime  
) as  
begin  
  declare  
    @ProcName varchar(100),  
    @nResult smallint,
    @settleno int,
    @old_date datetime,
    @new_date datetime     
         
  declare cur_All cursor for  
    select ProcName, nResult   
    from SettleDayRunResult(nolock)  
    where SettleDay = '2009.01.01'  
      
  open cur_All   
  fetch next from cur_All into @ProcName, @nResult  
  while @@fetch_status = 0  
  begin           
    if not exists(select 1 from SettleDayRunResult(nolock) where SettleDay = convert(varchar(12), @piSettleDay, 102)   
        and ProcName = @ProcName and nResult = 0) 
     if @ProcName = 'SETTLEDAY'
      begin
       select @old_date = max(ADATE) from INVDRPT(nolock)  
       select @settleno = max(NO) from MONTHSETTLE(nolock)
       select @new_date = convert(datetime, convert(char, getdate(), 102)) 
       --     
       exec SETTLEDAY @settleno,@old_date,@settleno,@new_date
      end
     else
      exec @ProcName  
    fetch next from cur_All into @ProcName, @nResult     
  end    
  close cur_All  
  deallocate cur_All    
end  

GO
