SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_CNTR_ON_SETTLEDAY] as    
begin    
  declare @num varchar(14),    
          @version int,    
          @vendor int,    
          @enddate datetime,    
          @days int     
 if not exists (select 1 from FAMSCBNOTIFY(nolock) where subjectclass='PS3_HDBasic_VENDOR'   
    and convert(char(10),opertime,102)=convert(char(10),getdate(),102))  
 begin  
  declare c_cntr cursor for    
    select NUM, VERSION, VENDOR, ENDDATE from CTCNTR where ((STAT = 500) or (STAT = 1400)) and TAG = 1    
  open c_cntr    
  fetch next from c_cntr into @num, @version, @vendor, @enddate    
  while @@fetch_status = 0    
  begin    
    set @days = DATEDIFF(day, @enddate, getdate())    
    execute MSCB_CNTR_ON_SETTLEDAY_TRIGGER @num, @version, @vendor, @days    
    fetch next from c_Cntr into @num, @version, @vendor, @enddate    
  end    
  close c_cntr    
  deallocate c_cntr    
 end
  --
  declare @selday datetime
  set @selday = getdate()
  exec APPEND_SETTLEDAYRESULT @selday, 'MSCB_CNTR_ON_SETTLEDAY', 0, ''    --合并日结
end    
  
GO
