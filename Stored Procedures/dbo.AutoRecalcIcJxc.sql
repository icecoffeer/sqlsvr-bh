SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[AutoRecalcIcJxc]             
  as             
begin            
declare             
 @begindate datetime,                  
 @enddate datetime                  
            
select @begindate=convert(char(10),getdate()-7,102)            
select @enddate=convert(char(10),getdate(),102)            
            
exec ic_jxc_recalc @begindate,@enddate            
            
declare @insdate datetime            
declare @zhika money,@faka money,@chongzhi money,@xiaofei money,@tuihuo money,@chika money,@zuofei money            
declare @qichu money,@qimo money            
declare @allzhika money,@allfaka money,@allchongzhi money,@allxiaofei money,@alltuihuo money,@allchika money,@allzuofei money            
            
 declare cur_hdicjxc cursor for            
     select insdate,zhika,faka,chongzhi,xiaofei,tuihuo,chika,zuofei            
  from ic_jxc            
  where insdate >= @begindate and insdate <= @enddate            
 open cur_hdicjxc             
 fetch next from cur_hdicjxc            
 into @insdate,@zhika,@faka,@chongzhi,@xiaofei,@tuihuo,@chika,@zuofei            
 while @@fetch_status = 0            
  begin            
   if not exists (select 1 from hd_icjxc where insdate = dateadd(day,-1,@insdate))            
   begin            
    select @qichu = isnull(sum(zhika + faka + chongzhi - xiaofei + tuihuo + chika - zuofei),0)            
    from ic_jxc            
    where insdate < @insdate            
                            
     select @allzhika = sum (zhika), @allfaka = sum (faka),@allchongzhi = sum (chongzhi),            
     @allxiaofei = sum (xiaofei),@alltuihuo = sum (tuihuo),@allchika = sum (chika),@allzuofei = sum (zuofei)                                       
     from ic_jxc            
    where insdate < @insdate            
                
    insert into hd_icjxc(insdate,qichu,zhika,faka,chongzhi,xiaofei,tuihuo,chika,zuofei,qimo,allzhika,allfaka,allchongzhi,allxiaofei,alltuihuo,allchika,allzuofei)            
    values (@insdate, @qichu,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)            
                  
    update hd_icjxc set zhika = @zhika,faka = @faka,chongzhi = @chongzhi,xiaofei = @xiaofei,tuihuo = @tuihuo ,chika = @chika ,zuofei = @zuofei           
    where insdate = @insdate            
    update hd_icjxc set qimo = @qichu + @zhika + @faka + @chongzhi - @xiaofei + @tuihuo + @chika - @zuofei           
    where insdate = @insdate            
                
    update hd_icjxc set allzhika = isnull(@allzhika,0) + isnull(@zhika,0),            
          allfaka  = isnull(@allfaka,0)  + isnull(@faka,0),            
          allchongzhi = isnull(@allchongzhi,0) + isnull(@chongzhi,0),            
          allxiaofei  = isnull(@allxiaofei,0) + isnull(@xiaofei,0),            
          alltuihuo  = isnull(@alltuihuo,0) + isnull(@tuihuo,0),            
          allchika  = isnull(@allchika,0) + isnull(@chika,0),           
          allzuofei = isnull(@allzuofei,0) + isnull(@zuofei,0)              
    where insdate = @insdate            
   end            
   else            
      if exists(select 1 from hd_icjxc where insdate = @insdate)              
        begin              
        delete from hd_icjxc where insdate = @insdate                 
        end            
                 
        select @qichu = qimo            
        from hd_icjxc where insdate = dateadd(day,-1,@insdate)            
              
        select @allzhika = allzhika,@allfaka = allfaka,@allchongzhi = allchongzhi,            
        @allxiaofei = allxiaofei,@alltuihuo = alltuihuo,@allchika = allchika,@allzuofei = allzuofei            
        from hd_icjxc where insdate = dateadd(day,-1,@insdate)            
                
        insert into hd_icjxc(insdate,qichu,zhika,faka,chongzhi,xiaofei,tuihuo,chika,zuofei,qimo,allzhika,allfaka,allchongzhi,allxiaofei,alltuihuo,allchika,allzuofei)            
        values (@insdate, @qichu,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)            
                  
        update hd_icjxc set zhika = @zhika,faka = @faka,chongzhi = @chongzhi,xiaofei = @xiaofei,tuihuo = @tuihuo,chika = @chika,zuofei = @zuofei             
        where insdate = @insdate        
               
        update hd_icjxc set qimo = @qichu + @zhika + @faka + @chongzhi - @xiaofei + @tuihuo + @chika - @zuofei           
        where insdate = @insdate            
                
        update hd_icjxc set allzhika = @allzhika + @zhika,            
                            allfaka  = @allfaka  + @faka,            
                         allchongzhi = @allchongzhi + @chongzhi,            
                         allxiaofei  = @allxiaofei + @xiaofei,            
                    alltuihuo  = @alltuihuo + @tuihuo,            
                            allchika = @allchika + @chika,            
                           allzuofei = @allzuofei + @zuofei          
        where insdate = @insdate            
                     
   fetch next from cur_hdicjxc             
   into @insdate,@zhika,@faka,@chongzhi,@xiaofei,@tuihuo,@chika,@zuofei            
   end            
 close cur_hdicjxc            
 deallocate cur_hdicjxc            
            
end            
          

GO
