SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LmtPrmRcvGo](
    @p_src int,
    @p_id int,
    @p_l_filler int,
    @p_l_checker int
) with encryption as
begin
    declare
    @ret_status int,
    @curr_settleno int,
    @n_num char(10),
    @n_frcchk smallint,
    @l_num char(10),
    @l_newnum char(10),
    @lstId  varchar(16),
    @old_num char(10),  /*如果此单据已经接受过了，则覆盖原来的单据，单号不改变*/
    @old_stat int
  

    select @ret_status = 0
    select @n_num = Num, @n_frcchk = FrcChk
        from NLmtPrm where Src = @p_src and Id = @p_id
    select @l_num = max(Num) from LmtPrm
    if @l_num is not null
        execute NEXTBN @l_num, @l_newnum output
    else
        select @l_newnum = '0000000001'
    select @curr_settleno = max(No) from MONTHSETTLE
 
    if exists (select * from LmtPrm where Src = @p_src and SrcNum = @n_num)  
    begin
         select @old_num = num,@old_stat = stat from LmtPrm where Src = @p_src and SrcNum = @n_num      
             
         delete from LmtPrmDtl where num = @old_num
         delete from LmtPrm where num =@old_Num

         insert into LmtPrmDtl(
            num,line,settleNO,
            gdGid,start,finish,qtyLmt,price,stat,lstID)
          select 
            @old_num,n.line,@curr_settleNO,
            X.LGid,N.start,n.finish,N.QtyLmt,N.price,N.stat,N.lstId
           from nLmtPrmDtl n,GdXlate X
           where n.src = @p_src and n.Id = @p_id and n.gdGid = X.NGid        
               
         insert into LmtPrm(
            num,settleNo,filDate,filler,checker,
            recCnt,stat,lmtCls,note,eon,src,srcNum,
            sndTime,rcvtime)
           select 
                 @Old_num,@curr_settleNo,filDate,@p_l_filler,@p_l_checker,
                 recCnt,0,lmtCls,note,1,src,num,
                 null,getDate()
             from nLmtPrm
             where Src = @p_src and Id = @p_id  
       if @n_frcchk = 1
            execute @ret_status = LmtPrmChk @old_num/*审核*/
       else             
          if @old_stat = 1 
             execute @ret_status = LmtPrmChk @old_num/*审核*/
                   
    end
    else
    begin
        insert into LmtPrmDtl(
            num,line,settleNO,
            gdGid,start,finish,qtyLmt,price,stat,lstID)
       	   select 
            @l_newNum,n.line,@curr_settleNO,
            X.LGid,N.start,n.finish,N.QtyLmt,N.price,N.stat,N.lstId
           from nLmtPrmDtl n,GdXlate X
           where n.src = @p_src and n.Id = @p_id and n.gdGid = X.NGid        
               
	insert into LmtPrm(
            num,settleNo,filDate,filler,checker,
            recCnt,stat,lmtCls,note,eon,src,srcNum,
            sndTime,rcvtime)
           select 
                 @l_newNum,@curr_settleNo,filDate,@p_l_filler,@p_l_checker,
                 recCnt,0,lmtCls,note,1,src,num,
                 null,getDate()
             from nLmtPrm
             where Src = @p_src and Id = @p_id               
       if @n_frcchk = 1
            execute @ret_status = LmtPrmChk @l_newnum/*审核*/
    end

    

    delete from NLmtPrmDtl
        where Src = @p_src and Id = @p_id
    delete from NLmtPrm
        where Src = @p_src and Id = @p_id

    return(@ret_status)
end
GO
