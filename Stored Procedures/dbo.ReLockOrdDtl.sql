SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ReLockOrdDtl](
            @old_num char(10),
            @old_locknum char(10),
            @old_lockcls char(10)
)with encryption as
 
       declare 
              @OrdLine integer

        begin     
               update orddtl 
               set inuse = 0,locknum = null,lockcls = null  --先全部解锁
               where     num=@old_num 
                   and  locknum = @old_locknum 
                   and  lockcls = @old_lockcls        
       
              
              if @old_lockcls = '自营'            --重新加锁,如果是自营进货单
                begin
                 if (select stat from stkin where num = @old_locknum and cls = '自营')=0  --如果未审核则加锁
                 begin       
                 declare C_stkindtl cursor for            
              	 select ordline
                     from stkindtl where num = @old_locknum 
                                     and cls = '自营' 
                                     and ordline > 0                                     
       
                 open C_stkindtl
                 fetch next from C_stkindtl into  
                     @OrdLine
              
                 while @@fetch_status = 0            --遍历自营进货单明细
             
                  begin
              		update orddtl 
                	set inuse = 1,locknum = @old_locknum,lockcls = @old_lockcls 
                	    where num = @old_num 
                              and line = @OrdLine 
              		fetch next from C_stkindtl into
                    	     @OrdLine
            	  end   
	      close C_stkindtl
	      deallocate C_stkindtl 
              end	                       
             end

	

               if @old_lockcls in ('直配进','直配出')--如果是直配进货单或者直配出货单
                begin
                  if (select stat from diralc where num = @old_locknum and cls =@old_lockcls )=0  --如果未审核则加锁
		  begin
                   declare C_diralcdtl cursor for
                   select ordline
                        from diralcdtl where num = @old_locknum 
                                         and cls = @old_lockcls 
                                         and ordline > 0
                                     
                   
                   open C_diralcdtl
                   fetch next from C_diralcdtl into
                        @OrdLine
                   
                     while @@fetch_status =0

                       begin
                           update orddtl
                          set inuse = 1,locknum = @old_locknum,lockcls = @old_lockcls
                                where num = @old_num 
                                  and line = @OrdLine
                          fetch next from C_diralcdtl  into 
                              @OrdLine
                       end
                      	close C_diralcdtl
	                deallocate C_diralcdtl
                  end
		                     
		
		end


end
GO
