SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure  [dbo].[DmdPrmSplit]
 @p_num char(10),
 @p_splitstr char(30),
 @p_orderstr varchar(255),
 @p_operater int
as
begin
 declare @cursettleno int,@counter int,@newnum char(10),@curdatetime datetime,@sql varchar(800)
 declare @line smallint,@gdgid int,@prmtype smallint,@cangft smallint,@stat smallint,@ratifystore int,@usergid int
 declare @psr char(10),@vdr char(10),@tm char(20),@lpsr char(10),@lvdr char(10),@ltm char(20)
 declare @Qpc money,@QpcStr char(15)
 select @curdatetime = getdate()
 select @counter = -1
 select @usergid=usergid from system
 select @cursettleno = max(no) from monthsettle
 if (@cursettleno is null)
 begin
     raiserror( 'use DmdPrmSplit: get current settleno failed!', 16, 1 )
     return(1)
 end

 select @stat=stat,@ratifystore=ratifystore from dmdprm where num=@p_num
 if @@rowcount = 0
 begin
     raiserror( '该单据不存在！' ,16, 1 )
     return(2)
 end
 if @stat <> 1
 begin
     raiserror( '该单据不是已提交单据！' ,16, 1 )
     return(3)
 end
 if @ratifystore <> @usergid
 begin
     raiserror( '批准单位非本店，不能进行拆分！' ,16, 1 )
     return(4)
 end
 select @newnum = max(num) from dmdprm
 if (@newnum is null)
     select @newnum = '0000000001'
 else
     execute nextbn @newnum, @newnum output

 select @sql = '
 declare c_dmdprmdtl cursor for
   select dmdprmdtl.line,dmdprmdtl.gdgid,dmdprmdtl.prmtype,dmdprmdtl.cangft,employeeh.code,vendorh.code,isnull(goodsh.tm,''''),dmdprmdtl.Qpc,dmdprmdtl.QpcStr
     from dmdprmdtl,employeeh,vendorh,goodsh
     where dmdprmdtl.num = '''+@p_num+''' and dmdprmdtl.gdgid = goodsh.gid
       and goodsh.psr = employeeh.gid and goodsh.billto = vendorh.gid
     order by ' + @p_orderstr + ',goodsh.name for read only '
 --raiserror(@sql,16,1) with nowait
 exec(@sql)
 open c_dmdprmdtl

 if (@@error <> 0)
 begin
     raiserror( ' use DmdPrmSplit: open c_dmdprmdtl cursor failed!' ,16, 1 )
     return(5)
 end

 fetch next from c_dmdprmdtl into @line,@gdgid,@prmtype,@cangft,@psr,@vdr,@tm,@Qpc,@QpcStr
 if (@@fetch_status <> 0)
 begin
     close c_dmdprmdtl
     deallocate c_dmdprmdtl
     raiserror( ' use DmdPrmSplit: fetch c_dmdprmdtl cursor failed!' ,16, 1 )
     return(6)
 end
 select
     @lpsr = @psr,
     @lvdr = @vdr,
     @ltm  = @tm

 while (@@fetch_status = 0)
 begin
     select @counter = @counter + 1
     insert into dmdprmdtl(num,line,settleno,gdgid,prmtype,cangft, Qpc, QpcStr)
                    values(@newnum,@counter,@cursettleno,@gdgid,@prmtype,@cangft,@Qpc,@QpcStr)

     insert into dmdprmdtldtl(num,line,settleno,item,start,finish,cycle,cstart,cfinish,cspec,
                              qtylo,qtyhi,price,discount,gftgid,gftqty,gftper,gfttype,inprc,prmtag,mbrprc)
         select @newnum,@counter,@cursettleno,item,start,finish,cycle,cstart,cfinish,cspec,
                              qtylo,qtyhi,price,discount,gftgid,gftqty,gftper,gfttype,inprc,prmtag,mbrprc
           from dmdprmdtldtl where num=@p_num and line=@line

     fetch next from c_dmdprmdtl into @line,@gdgid,@prmtype,@cangft,@psr,@vdr,@tm,@Qpc,@QpcStr

     if ( (substring(@p_splitstr,1,1) = '1') and (@psr <> @lpsr) )
         or ( (substring(@p_splitstr,2,1) = '1') and (@vdr  <> @lvdr ) )
         or ( (substring(@p_splitstr,3,1) = '1') and (@tm  <> @ltm ) )
     begin
         insert into dmdprmlacdtl(num,storegid) select @newnum,storegid from dmdprmlacdtl where num=@p_num
         insert into dmdprm(num,settleno,reccnt,stat,submitdate,submitter,note,
                            fildate,filler,eon,src,srcnum,ratifystore,Launch)
           select @newnum,@cursettleno,@counter + 1,1,@curdatetime,@p_operater,note+'  由 '+@p_num+' 拆分而来',
                            fildate,filler,eon,src,srcnum,ratifystore,Launch from dmdprm where num=@p_num
         if (@@error <> 0)
         begin
             raiserror( ' use DmdPrmSplit: insert into dmdprm failed! ',16,1 )
             close c_dmdprmdtl
             deallocate c_dmdprmdtl
             return(7)
         end

         select @counter = -1
         execute nextbn @newnum, @newnum output
         if exists(select * from dmdprm where num = @newnum)
         begin
             select @newnum = max(num) from dmdprm
             execute nextbn @newnum, @newnum output
         end
     end
     select
         @lpsr = @psr,
         @lvdr = @vdr,
         @ltm  = @tm
 end

 if (@counter <> -1)
 begin
     insert into dmdprmlacdtl(num,storegid) select @newnum,storegid from dmdprmlacdtl where num=@p_num
     insert into dmdprm(num,settleno,reccnt,stat,submitdate,submitter,note,
                            fildate,filler,eon,src,srcnum,ratifystore,Launch)
           select @newnum,@cursettleno,@counter + 1,1,@curdatetime,@p_operater,note+'  由 '+@p_num+' 拆分而来',
                            fildate,filler,eon,src,srcnum,ratifystore,Launch
                            from dmdprm where num=@p_num
     if (@@error <> 0)
     begin
         raiserror( ' use DmdPrmSplit: insert into dmdprm failed! ',16,1 )
         close c_dmdprmdtl
         deallocate c_dmdprmdtl
         return(7)
     end
 end

 close c_dmdprmdtl
 deallocate c_dmdprmdtl

 update dmdprm set stat = 2,note = left(rtrim(note)+' ['+convert(varchar(19),@curdatetime,120)+' 被拆分]',100) where num=@p_num
 return(@@error)

end
GO
