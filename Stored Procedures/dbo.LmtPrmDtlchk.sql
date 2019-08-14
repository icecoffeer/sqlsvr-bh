SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LmtPrmDtlchk](
    @p_num char(10),
    @p_storegid int
) with encryption as
begin
    declare
        @s_usergid int,
        @s_zbGid int,
        @s_SRC  int,
        @line smallint,
        @gdgid int,
	@LstID varchar(16),
        @Stat int,/*正常or中止*/

	@FLAG int,
        @LstId_Max varchar(20),
        @store_code varchar(10),
	@year_char char(2),
	@mnth_char char(2),
	@day_char char(2),
        @date_char char(6)


    set @FLAG = 1
    select @s_usergid = USERGID,@s_zbgid = zbgid from [SYSTEM]
    select @s_SRC = src from LmtPrm where num = @p_num /*来源单位*/
    /*取年月日 (020717)*/   
    if len(month(getdate())) = 1 
       set  @mnth_char = '0'+convert(char(1),month(getdate()))
    else
       set  @mnth_char = convert(char(2),month(getdate()))
    if len(day(getdate())) = 1 
       set  @day_char = '0'+convert(char(1),day(getdate()))
    else
       set  @day_char = convert(char(2),day(getdate()))
    set  @year_char = substring( convert(char(4),year(getdate())),3,2) 
    set @date_char = @year_char+@mnth_char+@day_char

    /*取店号0001*/
    select @store_code = code  from store where gid = @s_userGid
    if len(ltrim(rtrim(@store_code))) >= 4
       set @store_code = substring(ltrim(rtrim(@store_code)),1,4)
    else if  len(ltrim(rtrim(@store_code))) = 3
       set @store_code = '9'+@store_code
    else if  len(ltrim(rtrim(@store_code))) = 2
       set @store_code = '99'+@store_code
    else if  len(ltrim(rtrim(@store_code))) = 1
       set @store_code = '999'+@store_code
    /**/
    
    select @lstId_max = max(b.LstID) from LmtPrm a ,LmtPrmDtl b 
            where  a.Num = b.Num 
--              and convert(datetime,convert(varchar(10),a.FilDate)) = (select convert(datetime,convert(varchar(10),getdate())))
		and convert(varchar(10),a.FilDate,102) =  convert(varchar(10),getdate(),102)
              and a.Src = @s_usergid
    if isnull(@lstID_max,'0') ='0'
           set @LstId_max = @store_code+@date_char+'000000'


    declare c_prcprm cursor for
        select LINE, GDGID,Stat,lstID from LmtPRMDTL where NUM = @p_num
    open c_prcprm
    fetch next from c_prcprm into @line, @gdgid,@stat,@LstId/*正常or中止*/
    while @@fetch_status = 0
    begin
        /*计算@lstID*/
      if (@s_src = @s_usergid)/*来源单位是本单位*/
      begin
        select @FLAG = 1
        if exists (select * from LmtPrmDtl where num = @p_num and lstId is not null and line = @line)
        begin
           select @lstID = lstID from LmtPrmDtl where num = @p_num and line = @line
           select @FLAG = 0
        end
	while @FLAG = 1 
        begin
            execute NEXTBNLmtPrm @lstId_max,@LstId output
           -- if exists(select * from LmtPrmDtl where LstId = @LstId) 
           --    execute NEXTBNLmtPrm @lstId,@LstId output
	   -- else 
	       set @FLAG = 0
            select @LstId_max  = @LStId
        end
        -- select @LStId
        update LmtPrmDtl set LstId = @LstID where num = @p_num and line = @line
  
        delete from LMTPRICE where storeGid = @p_storeGid and LstId = @LstId /*计算得出*/
	insert into LmtPrice (lstId,StoreGid,LmtCls,GdGid,aStart,aFinish,qtyLmt,
			  price,srcNum,srcLine)
            select @lstId,@p_storeGid,a.LmtCls,b.Gdgid,b.Start,b.Finish,b.QtyLmt,
			b.price,@p_num,@line
                from LmtPrm a ,LmtPrmDtl b
                where b.Num = @p_num and Line = @line          
                   and a.num = b.num
      end
      else/*门店审核从总部发来的单据*/
      begin
        delete from LMTPRICE where storeGid = @p_storeGid and LstId = @LstId 
	insert into LmtPrice (lstId,StoreGid,LmtCls,GdGid,aStart,aFinish,qtyLmt,
			  price,srcNum,srcLine)
            select @lstID,@p_storeGid,a.LmtCls,b.Gdgid,b.Start,b.Finish,b.QtyLmt,
			b.price,@p_num,@line
                from LmtPrm a ,LmtPrmDtl b
                where b.Num = @p_num and Line = @line          
                   and a.num = b.num
      end
      if @stat = 1 /*中止*/
      begin
		if not exists(select * from LmtPriceHst where LstId = @LstId)	
                    insert into LmtPriceHst (lstID,StoreGid,LmtCls,gdGid,aStart,aFinish,
                          QtyLmt,Price,SrcNum,CancelDate) 
                       select lstID,StoreGid,LmtCls,GdGid,aStart,aFinish,
                          QtyLmt,Price,SrcNum, getDate()
            	       from LmtPrice 
            	       where lstId = @lstId 
	        delete from  LmtPrice where LstId = @lstId
      end

        fetch next from c_prcprm into @line, @gdgid,@stat,@LstId
    end
    close c_prcprm
    deallocate c_prcprm

    return(0)
end
GO
