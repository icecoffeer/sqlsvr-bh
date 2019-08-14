SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MXFDMD_Rcv]
(
  @bill_id int,
  @src_id int,
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  declare
    @cur_settleno int,    @stat smallint,
    @rcv_gid int,         @net_stat smallint,
    @net_type smallint,   @num char(14),
    @net_num char(14),    @pre_num char(14),
    @net_billid int,
    --
    @nd_gdgid int,        @ld_gdgid int,
    @BillSrc int,         @vReNumFore char(4),
    @vFlowTag int,        @vInsSrc int,
    @vInsChkStoreGid int, @ret int,
    @d_line smallint,     @AutoMsg varchar(100),
    @AutoMsg2 varchar(100),
    --自动生成调拨单
    @AutoCreateMXF int,   @Confirm int,
    @MXFLine smallint,    @MXFTag int,
    @MXFNum char(14),
    @LogAction varchar(100)
  set @ret = 0
  set @vFlowTag = 0

  select @cur_settleno = max(no) from monthsettle
  select  @rcv_gid = RCV, @net_stat = STAT,
    @net_type = TYPE, @net_num = NUM
    from NMXFDMD where ID = @bill_id and SRC = @src_id
  if @@rowcount = 0 or @net_num is null
  begin
    SET @MSG = '该单据不存在'
    return(1)
  end

  if exists(select 1 from MXFDMD where num = @net_num and stat = @net_stat)
  begin
    SET @MSG = '该单据已经被接收'
    return(1)
  end
  if (select max(USERGID) from SYSTEM ) <>  @rcv_gid
  begin
    SET @MSG = '该单据的接收单位不是本单位'
    return(1)
  end
  if @net_type <> 1
  begin
    SET @MSG = '该单据不在接收缓冲区中'
    return(1)
  end
  --从单据前四位判断单据的来源
  set @vReNumFore = reverse(left(ltrim(@net_num), 4))
  select @BillSrc = gid from store(nolock)
    where substring(reverse(rtrim(code)),1,1) = substring(@vReNumFore,1,1)
    and ((substring(reverse(rtrim(code)),2,1) = substring(@vReNumFore,2,1)) or (substring(reverse(rtrim(code)),2,1) = ''))
    and ((substring(reverse(rtrim(code)),3,1) = substring(@vReNumFore,3,1)) or (substring(reverse(rtrim(code)),3,1) = ''))
    and ((substring(reverse(rtrim(code)),4,1) = substring(@vReNumFore,4,1)) or (substring(reverse(rtrim(code)),4,1) = ''))
  if @@rowcount <> 1
  begin
    set @msg = '根据单号前四位取来源单位时错误。['+@vReNumFore+']'
    return(1)
  end

  /*
  @vFlowTag:
  0 - Do nothing
  1 - Delete Local
  2 - Insert
  4 - Insert With No AllowedQtyPrice Control
  */
  set @vFlowTag = 0
  SET @MXFTag = 0
  --单据不存在
  if (select count(*) from MXFDMD a,nMXFDMD b where a.num = b.num
    and b.id = @bill_id and b.src = @src_id) = 0
  begin
    if @net_Stat = 401
    begin
      set @vInsSrc = @src_id
      set @vInsChkStoreGid = @rcv_gid
      if (@vFlowTag & 2) <> 2 set @vFlowTag = @vFlowTag + 2
    end
    else if @net_Stat = 400
    begin
      set @vInsSrc = @BillSrc
      set @vInsChkStoreGid = @src_id
      if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
    end
    --else no process
    else
    begin
      set @LogAction = '接收网络单据，网络单据状态是' + ltrim(str(@net_stat)) +
        '，本地无同号单据。不接收。'
      EXEC MXFDMD_ADD_LOG @net_num, @net_stat, @LogAction, @OPER
      delete from NMXFDMD where ID = @bill_id and SRC = @src_id
      delete from NMXFDMDDTL where ID = @bill_id and SRC = @src_id
      return(0)
    end
  end
  else --单据存在
  begin
    select @stat = a.stat, @num = a.num from MXFDMD a,nMXFDMD b
    where a.num = b.num and b.id = @bill_id and b.src = @src_id
    if @stat = 401 and @net_Stat = 400  --300不接收
    begin
      SET @MXFTag = 1
			if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			if @net_Stat = 401
			begin
				set @vInsSrc = @src_id
				set @vInsChkStoreGid = @rcv_gid
				if (@vFlowTag & 2) <> 2 set @vFlowTag = @vFlowTag + 2
			end
			else begin
				set @vInsSrc = @BillSrc
				set @vInsChkStoreGid = @src_id
				if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
			end
    end
    else if @stat = 401 and @net_Stat = 402 --申请单位收到审批单位发来的拒绝单
    begin
      if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			set @vInsSrc = @BillSrc
			set @vInsChkStoreGid = @src_id
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
    end
    else if @stat = 401 and @net_Stat = 411 --审批单位收到申请单位发来的申请作废单
    begin
      if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			set @vInsSrc = @BillSrc
			set @vInsChkStoreGid = @rcv_gid
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
    end
    else if @stat = 400 and @net_Stat = 411 --审批单位收到申请单位发来的申请作废单
    begin
      if (@vFlowTag & 1) <> 1 set @vFlowTag = @vFlowTag + 1
			set @vInsSrc = @BillSrc
			set @vInsChkStoreGid = @rcv_gid
			if (@vFlowTag & 4) <> 4 set @vFlowTag = @vFlowTag + 4
    end
    else
    begin
      set @LogAction = '接收网络单据，本地同号单据状态是' + ltrim(str(@stat)) +
        '，网络单据状态是' + ltrim(str(@net_stat)) + '。不接收。'
      EXEC MXFDMD_ADD_LOG @net_num, @stat, @LogAction, @OPER
      delete from NMXFDMD where ID = @bill_id and SRC = @src_id
      delete from NMXFDMDDTL where ID = @bill_id and SRC = @src_id
      return(0)
    end
  end

  if (@vFlowTag & 1) = 1
  begin
    delete from MXFDMD where num = @num
    delete from MXFDMDdtl where num = @num
  end
  if (@vFlowTag & 2) = 2 or (@vFlowTag & 4) = 4 --插入表头
  begin
    insert into MXFDMD (SRC, FROMSTORE, TOSTORE, XCHGSTORE, NUM, SETTLENO, RECCNT,
              NOTE, FILDATE, FILLER, DMDDATE, DMDOPER, CHKDATE, CHECKER,
              EXPDATE, STAT, LSTUPDTIME, LSTUPDOPER, SNDTIME, SRCNUM,
              FROMTOTAL, FROMTAX, RCVTIME, DEPT)
              select  @vInsSrc, FROMSTORE, TOSTORE, @vInsChkStoreGid, NUM, @cur_settleno, RECCNT,
                NOTE, FILDATE, FILLER, DMDDATE, DMDOPER, CHKDATE, CHECKER,
                EXPDATE, STAT, LSTUPDTIME, LSTUPDOPER, SNDTIME, SRCNUM,
                FROMTOTAL, FROMTAX, GetDate(), DEPT
              from NMXFDMD
      where SRC = @src_id and ID = @bill_id
    if @@error <> 0
    BEGIN
      SET @MSG = '接收'+@NET_NUM+'单据失败'
      return(1)
    END
    
    exec GENNEXTBILLNUMEX '', 'MXF', @MXFNum output
    EXEC OPTREADINT 8013, 'AutoCreateMXF', 0, @AutoCreateMXF output
    IF @MXFTag = 1 and @AutoCreateMXF = 1
    BEGIN
      SET @AutoMsg = '由网络调拨申请单'+@NET_NUM+'自动生成。'
      insert into MXF (NUM, SETTLENO, FROMSTORE, TOSTORE, XCHGSTORE, WRH, FILDATE, FILLER,
                FROMTOTAL, TOTOTAL, FROMTAX, TOTAX, FROMCOST, TOCOST, STAT, SRC,
                RECCNT, SNDTIME, NOTE, DMDNUM)
                select @MXFNum, @cur_settleno, a.FROMSTORE, a.TOSTORE, a.TOSTORE, c.WRH, Getdate(), b.GID,
                a.FROMTOTAL, a.FROMTOTAL, a.FROMTAX, a.FROMTAX, 0, 0, 0, @vInsSrc, a.RECCNT,
                null, @AutoMsg, @net_num
                from NMXFDMD a, EMPLOYEE b, NMXFDMDDTL c
                where a.SRC = @src_id and a.ID = @bill_id
                  and a.Filler = rtrim(b.NAME)+'['+rtrim(b.CODE)+']'
                  and c.SRC = @src_id and c.ID = @bill_id and c.line = 1
                
      if @@error <> 0
      BEGIN
        SET @MSG = '自动生成调拨单失败'
        SET @AutoCreateMXF = 0
      END
                  
    END
  end
  
  SET @MXFLine = 0
  declare c_nmxfdtl cursor for
    select LINE, GDGID from NMXFDMDDTL
      where SRC =@src_id and ID = @bill_id
    for read only
  open c_nmxfdtl
  fetch next from c_nmxfdtl into @d_line, @nd_gdgid
  while @@fetch_status = 0
  begin
      select @ld_gdgid = LGID from GDXLATE where NGID = @nd_gdgid
      if @@rowcount = 0
      begin
        select @MSG = '本地未包含单号'+@net_num+'的第'+rtrim(convert(char, @d_line))+'行的商品资料。请先下载商品资料，再下载网络门店调拨单！'
        select @ret = 1
        close c_nmxfdtl
        deallocate c_nmxfdtl
        return @ret
      end

  insert into MXFDMDDTL (NUM, LINE, GDGID, CONFIRM, NOTE, QTY, FROMPRC, FROMTOTAL, WRH, FROMTAX)
            select @net_num, @d_line, @ld_gdgid, CONFIRM, NOTE, QTY, FROMPRC, FROMTOTAL, WRH, FROMTAX
            from NMXFDMDDTL
            where src = @src_id and id = @bill_id and line = @d_line
  if @@error <> 0
  BEGIN
    SET @MSG = '接收'+@NET_NUM+'单据失败'
    select @ret = 1
    close c_nmxfdtl
    deallocate c_nmxfdtl
    return @ret
  END
  
  IF @MXFTag = 1 and @AutoCreateMXF = 1
  BEGIN
    select @Confirm = confirm from NMXFDMDDTL where LINE = @d_line
    if @confirm = 1
    begin
      SET @MXFLine = @MXFLine + 1
      insert into MXFDTL (NUM, LINE, GDGID, WRH, QTY, FROMPRICE, FROMTOTAL, FROMTAX, TOPRICE, TOTOTAL, TOTAX,
                FROMCOST, TOCOST, INPRC, RTLPRC)
                select @MXFNum, @MXFline, @ld_gdgid, a.WRH, QTY, FROMPRC, FROMTOTAL, FROMTAX, FROMPRC, FROMTOTAL, FROMTAX,
                0, 0, INPRC, RTLPRC
                from NMXFDMDDTL a, GOODS b
                where a.SRC = @src_id and a.ID = @bill_id and a.line = @d_line
                  and b.GID = @ld_gdgid

      if @@error <> 0
      BEGIN
        SET @MSG = '自动生成调拨单失败'
        SET @AutoCreateMXF = 0
        DELETE FROM MXF WHERE NUM = (SELECT NUM FROM NMXFDMD WHERE SRC = @src_id and ID = @bill_id)
        DELETE FROM MXFDTL WHERE NUM = @net_num
      END
    end
  END
  
  fetch next from c_nmxfdtl into @d_line, @nd_gdgid
  end
  close c_nmxfdtl
  deallocate c_nmxfdtl
  
  IF @MXFTag = 1 and @AutoCreateMXF = 1
  begin
    update MXF set RECCNT = @MXFLine
    where NUM = @MXFNum
    exec MXFCHK @MXFNum, @AutoMsg output
    exec MXFSND @MXFNum, @AutoMsg2 output
    if @@error <> 0
      BEGIN
        SET @MSG = @AutoMsg + '。' + @AutoMsg2
      END
  end
  
  --Receive Bill Over
  
  EXEC MXFDMD_ADD_LOG @net_num, @net_stat, '接收', @OPER

  delete from NMXFDMD where ID = @bill_id and SRC = @src_id
  delete from NMXFDMDDTL where ID = @bill_id and SRC = @src_id
  return(@ret)
END
GO
