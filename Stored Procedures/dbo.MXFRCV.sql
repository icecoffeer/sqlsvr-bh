SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[MXFRCV](  
  @p_src int,  
  @p_id int,  
  @err_msg varchar(100) = '' output  
) as  
begin  
  declare @ret_status int,  @optvalue_wrh int,   @sndfrcflag int  
  declare @n_type smallint, @usergid int,   @storeflag int  
  declare @nm_filler int, @nd_gdgid int,  @n_num varchar(14)  
  declare @lm_filler int, @ld_gdgid int,  @cur_settleno int  
  declare @m_xchgstore int, @m_tostore int, @batchflag int  
  declare @d_line smallint, @ld_wrh int  
  declare @n_stat smallint, @l_stat smallint, @md_stat smallint,  
         @pro_flag smallint, @n_modnum varchar(14), @mod_stat int  
  declare @filler int, @fillercode varchar(20)  
  select @usergid = USERGID, @batchflag = BATCHFLAG from SYSTEM  
  select @cur_settleno = max(NO) from MONTHSETTLE  
  select @n_modnum = isnull(modnum,''), @n_stat = stat, @n_type = TYPE,  @sndfrcflag = FRCFLAG, @n_num = NUM, @nm_filler = FILLER,  
         @m_xchgstore = XCHGSTORE, @m_tostore =TOSTORE   
    from NMXF  
    where SRC = @p_src and ID = @p_id  
  if @@rowcount = 0  
  begin  
    select @err_msg = '指定的网络单据不存在(SRC = ' + rtrim(convert(char, @p_src)) + ', ID = ' + rtrim(convert(char, @p_id)) + ')。'  
    raiserror(@err_msg, 16, 1)  
    return(1)  
  end  
  if @n_type <> 1  
  begin  
    select @err_msg = '不是可接收的网络单据。'  
    raiserror(@err_msg, 16, 1)  
    return(1)  
  end  
  if (@usergid <> @m_xchgstore) and (@usergid <> @m_tostore)  
  begin  
    select @err_msg = '非交换单位或调入单位不能接收门店调拨单'  
    raiserror(@err_msg, 16, 1)  
    return(1)  
  end  
  
  select @lm_filler = LGID from EMPXLATE where NGID = @nm_filler  
  if @@rowcount = 0  
  begin  
    select @err_msg = '本地未包含审核人资料(GID = ' + rtrim(convert(char, @nm_filler)) + ')。'  
    raiserror(@err_msg, 16, 1)  
    return(1)  
  end  
  
  exec OPTREADINT 0, 'MXFWRH', 0, @optvalue_wrh output    
  if @usergid = @m_xchgstore   
     select @storeflag = 1   
  else if @usergid = @m_tostore   
     select @storeflag = 2  
  set @mod_stat = -1  
    
  if @n_modnum<>''  
  begin  
   select @mod_stat = isnull(stat,-1) from mxf where num = @n_modnum   
   set @n_stat = 4  
  end  
  --if @n_stat = 4 and @mod_stat = -1 表示还未接收被修正的单据，这样则不能接收和删除网络冲单。  
  /*  
  @pro_flag :  
  0:不处理  
  1:需要删除  
  2:需要插入  
  4:需要审核  
  8:需要冲单  
  */  
  set @pro_flag = 0  
  if exists(select 1 from mxf where num = @n_num)  
  begin  
   select @l_stat = stat   
    from mxf where num = @n_num  
   if @n_stat in (0,1)  --will not be 1  
   begin  
    if @l_stat in(0)   
     set @pro_flag = 1+2+4  
  else   
   set @pro_flag = 0  
   end  
   else if @n_stat in(2)  
   begin  
  select @err_msg = '发现“已被修正”单据，不应被接收。'  
  Raiserror(@err_msg, 16, 1)  
  return(1)  
 end  
   else if @n_stat in(4)  
   begin  
  set @pro_flag = 0  
 end  
  end  
  else  --单据不存在  
  begin  
   if @n_stat in (0,1)  
   begin  
    if exists(select 1 from mxf where modnum = @n_num) --已经有冲单对应  
    begin  
     set @pro_flag = 2  
   set @n_stat = 2 --接收的单据已经被修正，强制变成已被修正的状态  
    end  
    else  
     set @pro_flag = 2+4  
 end     
   else if @n_stat =4  
   begin  
    if @mod_stat = -1 --找不到需要修正的单据，就直接插入不冲单  
   set @pro_flag = 2  
    else  
     set @pro_flag = 2+8  
 end    
  else   
  begin  
  select @err_msg = '接收冲单时发现网络单据状态异常(已被修正)，不被接收。'  
     Raiserror(@err_msg, 16, 1)  
     return(1)  
  end  
  end  
  /*  
  @pro_flag :  
  0:不处理  
  1:需要删除  
  2:需要插入  
  4:需要审核  
  8:需要冲单  
  */  
  if @pro_flag & 1 = 1 --1:需要删除  
  begin  
     delete from mxf where num like @n_num  
     delete from mxfdtl where num like @n_num  
     delete from mxfdtl2 where num like @n_num   
  end  
  if @pro_flag & 2 = 2 --2:需要插入  
  begin  
 insert into MXF(NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, WRH, MODNUM, DMDNUM,
              FILDATE, FILLER, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST,  
              STAT, RECCNT, SRC, SNDTIME, NOTE, PRNTIME)   
 select NUM, @cur_settleno, FROMSTORE, TOSTORE, XCHGSTORE, WRH, MODNUM, DMDNUM,
              FILDATE, @lm_filler, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST,  
              @n_stat, RECCNT, SRC, null, NOTE, null  
 from NMXF where src = @p_src and id = @p_id  
          
 declare c_nmxfdtl cursor for  
   select LINE, GDGID, WRH from NMXFDTL  
     where SRC = @p_src and ID = @p_id  
   for read only  
 open c_nmxfdtl  
 fetch next from c_nmxfdtl into @d_line, @nd_gdgid, @ld_wrh  
 while @@fetch_status = 0  
 begin  
     select @ld_gdgid = LGID from GDXLATE where NGID = @nd_gdgid  
     if @@rowcount = 0  
     begin  
        select @err_msg = '本地未包含单号'+@n_num+'的第'+rtrim(convert(char, @d_line))+'行的商品资料。请先下载商品资料，再下载网络门店调拨单！'  
       select @ret_status = 1  
          close c_nmxfdtl  
          deallocate c_nmxfdtl  
       return @ret_status  -- break -> return 2005.04.07 3785  
     end  
   
     if @optvalue_wrh = 1   
        select @ld_wrh = wrh from goodsh where gid = @ld_gdgid  
   
     insert into MXFDTL(NUM, LINE, GDGID, WRH, QTY, CASES, /*ADD CASES 箱数 BY LIUJUNPING 2005.1.11*/  
                 FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST,  
                 SUBWRH, INPRC,RTLPRC,FROMGDVDR, FROMGDALC)  
          select @n_num, @d_line, @ld_gdgid, @ld_wrh, QTY, isnull(CASES,0),   ---add by jzhu cases字段若为空默认值为0，否则会接收失败  
                 FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST,  
                 SUBWRH, INPRC,RTLPRC,FROMGDVDR, FROMGDALC/*振华定制 20100810 WUDIPING ADD*/  
          from NMXFDTL where src = @p_src and id = @p_id and line = @d_line  
   
     if @batchflag = 2  
         insert into MXFDTL2(NUM, LINE, GDGID, WRH, SUBWRH, QTY, COST, FROMTO)  
              select @n_num, @d_line, @ld_gdgid, @ld_wrh, SUBWRH, QTY, COST, FROMTO   
              from NMXFDTL2 where src = @p_src and id = @p_id and line = @d_line           
   
     fetch next from c_nmxfdtl into @d_line, @nd_gdgid, @ld_wrh  
 end  
 close c_nmxfdtl  
 deallocate c_nmxfdtl  
  end  
  if @pro_flag & 4 = 4  --4:需要审核  
  begin  
 if @sndfrcflag >= 1   
 begin  
   exec @ret_status = MXFCHK @n_num, @err_msg output  
   if @ret_status <> 0  
   begin  
     raiserror(@err_msg, 16, 1)  
     return(@ret_status)  
   end  
 end  
 /*if @sndfrcflag = 2 and @storeflag = 1  
 begin  
   exec @ret_status = MXFSND @n_num, @err_msg output  
   if @ret_status <> 0  
   begin  
     raiserror(@err_msg, 16, 1)  
     return(@ret_status)  
   end  
 end*/  
  end  
  if @pro_flag & 8 = 8 --8:需要冲单  
  begin  
   if not exists(select 1 from mxf where num = @n_modnum)  
   begin  
       set @err_msg = '找不到需要冲单的单据！'  
       raiserror(@err_msg, 16, 1)  
       return(@ret_status)  
   end   
   set @fillercode = rtrim(substring(suser_sname(), charindex('_', suser_sname()) + 1, 20))  
 select @filler = gid from employee where code like @fillercode  
   
   exec @ret_status = MXFDLT @n_modnum, @filler,@err_msg output  
    if @ret_status <> 0  
    begin  
      raiserror(@err_msg, 16, 1)  
      return(@ret_status)  
    end  
  end  
  if @sndfrcflag = 2 and @storeflag = 1  
  begin  
    exec @ret_status = MXFSND @n_num, @err_msg output  
    if @ret_status <> 0  
    begin  
      raiserror(@err_msg, 16, 1)  
      return(@ret_status)  
    end  
  end  
    
  -- Added by zhourong, 2006.05.10  
  -- Q6669: 增加数据完整性校验  
  DECLARE @fromBillRecordCount int  
  DECLARE @netBillRecordCount int  
  SELECT @fromBillRecordCount = RECCNT FROM MXF WHERE NUM = @n_num  
  
  SELECT @netBillRecordCount = Count(1) FROM NMXFDTL WHERE ID = @p_ID AND SRC = @p_src  
  
  IF @fromBillRecordCount <> @netBillRecordCount  
  BEGIN  
    SELECT @err_msg = '接收的目的单据中的明细数与网络表中的明细数不符。'  
    RAISERROR (@err_msg, 16, 1)  
  END  
    
  
  if @batchflag = 2  
     delete from NMXFDTL2 where SRC = @p_src and ID = @p_id  
  delete from NMXFDTL where SRC = @p_src and ID = @p_id  
  delete from NMXF where SRC = @p_src and ID = @p_id  
   
  return(0)  
end  

GO
