SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE  procedure [dbo].[MXFSND](    
  @p_num varchar(14),    
  @err_msg varchar(100) = '' output    
) as    
begin    
  declare @optvalue_sndfrcflag int, @n_billid int, @storeflag int, @batchflag int    
  declare @ret_status int, @usergid int, @cur_time datetime    
  declare @m_stat smallint, @m_src int, @m_fromstore int, @m_xchgstore int,@M_TOSTORE INT    
    
  select @usergid = USERGID, @batchflag = BATCHFLAG, @cur_time = getdate() from SYSTEM    
  select @m_stat = STAT, @m_src = SRC, @m_fromstore = FROMSTORE, @m_xchgstore = XCHGSTORE,@M_TOSTORE=TOSTORE    
    from MXF where NUM = @p_num    
    
  if @@rowcount = 0    
  begin    
    select @err_msg = '指定的单据不存在(NUM = ''' + rtrim(@p_num) + ''')。'    
    raiserror(@err_msg, 16, 1)    
    return(1)    
  end    
  if @m_stat = 0    
  begin    
    select @err_msg = '发送的不是已审核的单据。'    
    raiserror(@err_msg, 16, 1)    
    return(1)    
  end    
  if (@usergid <> @m_fromstore) and (@usergid <> @m_xchgstore)    
  begin    
    select @err_msg = '非调出单位或交换单位不能发送单据。'    
    raiserror(@err_msg, 16, 1)    
    return(1)    
  end    
    
  if @usergid = @m_fromstore    
     select @storeflag =0    
  else    
     select @storeflag =1    
    
  exec OPTREADINT 0, 'MXFSNDFRCFLAG', 0, @optvalue_sndfrcflag output    
    
  exec GETNETBILLID @n_billid output    
    
  if @storeflag =0    
  BEGIN    
      insert into NMXF (SRC, ID, NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, WRH, MODNUM, DMDNUM,    
                        FILDATE, FILLER, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST,    
                        STAT, RECCNT, SNDTIME, NOTE, RCV, RCVTIME, TYPE, NSTAT, FRCFLAG, NNOTE)    
         select @usergid, @n_billid, NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, 1, MODNUM, DMDNUM,  
                FILDATE, FILLER, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST,    
                0, RECCNT, null, NOTE, XCHGSTORE, null, 0, 0, @optvalue_sndfrcflag, null    
         from MXF where NUM = @p_num    
     exec LOGNETOBJSEQ 188, @usergid, @n_billid, @m_xchgstore, 1    
  END    
  else    
  BEGIN    
      insert into NMXF (SRC, ID, NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, WRH, MODNUM, DMDNUM,  
                        FILDATE, FILLER, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST,    
                        STAT, RECCNT, SNDTIME, NOTE, RCV, RCVTIME, TYPE, NSTAT, FRCFLAG, NNOTE)    
         select @usergid, @n_billid, NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, 1, MODNUM, DMDNUM,  
                FILDATE, FILLER, FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST,    
                0, RECCNT, null, NOTE, TOSTORE, null, 0, 0, @optvalue_sndfrcflag, null  
         from MXF where NUM = @p_num    
       exec LOGNETOBJSEQ 188, @usergid, @n_billid, @m_tostore, 1      
  END    
    
  insert into NMXFDTL (SRC, ID, LINE, GDGID, WRH, QTY, CASES, /*ADD CASES 箱数 BY LIUJUNPING 2005.1.11*/    
                      FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST,    
                      SUBWRH, INPRC,RTLPRC, FROMGDVDR, FROMGDALC)    
       select @usergid, @n_billid, LINE, GDGID, WRH, QTY, isnull(CASES,0),    
              FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX, FROMCOST, TOCOST,    
              (case when @batchflag = 0 then null else SUBWRH end), INPRC, RTLPRC, FROMGDVDR, FROMGDALC/*振华定制 20100810 WUDIPING ADD*/      
       from MXFDTL where NUM = @p_num    
    
  if @batchflag = 2    
  begin    
      if @storeflag = 0    
         insert into NMXFDTL2 (SRC, ID, LINE, GDGID, WRH, SUBWRH, QTY, COST, FROMTO)    
            select @usergid, @n_billid, LINE, GDGID, WRH, SUBWRH, QTY, COST, FROMTO    
            from MXFDTL2 where NUM = @p_num    
      else    
         insert into NMXFDTL2 (SRC, ID, LINE, GDGID, WRH, SUBWRH, QTY, COST, FROMTO)    
            select @usergid, @n_billid, LINE, GDGID, WRH, SUBWRH, QTY, COST, FROMTO    
            from MXFDTL2 where NUM = @p_num and FROMTO = 1    
  end    
    
  update MXF set SNDTIME = getdate()    
    where NUM = @p_num    
    
  -- Added by zhourong, 2006.05.10    
  -- Q6669: 增加数据完整性校验    
  DECLARE @fromBillRecordCount int    
  DECLARE @netBillRecordCount int    
  SELECT @fromBillRecordCount = RECCNT FROM MXF WHERE NUM = @p_num    
    
  SELECT @netBillRecordCount = Count(1) FROM NMXFDTL WHERE ID = @n_billID    
    
  IF @fromBillRecordCount <> @netBillRecordCount    
  BEGIN    
    SELECT @err_msg = '发送的来源单据中的明细数与网络表中的明细数不符。'    
    RAISERROR (@err_msg, 16, 1)    
  END    
    
  return(0)    
end    
  
GO
