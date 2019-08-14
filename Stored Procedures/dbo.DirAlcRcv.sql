SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[DirAlcRcv](
       @SRC int,
       @ID int,
       @operator int
) with encryption as
begin
  declare
    @return_status smallint,
    @cur_settleno int,
    @stat smallint,
    @cls char(10),
    @num char(10),
    @max_num char(10),
    @next_num char(10),
    @rcv_gid int,
    @net_cls char(10),
    @net_stat smallint,
    @net_frcchk smallint,
    @net_type smallint,
    @net_num char(10),
    @net_modnum char(10),
    @pre_num char(10),
    @net_billid int,
    /*2002-10-28*/
    @s_AutoOcrDate int,
    @net_ocrdate datetime, 
    @net_verifier int  --ShenMin

  select  @rcv_gid = RCV, @net_cls = CLS, @net_stat = STAT, @net_frcchk = FRCCHK,
    @net_type = TYPE, @net_num = NUM, @net_modnum = MODNUM, @net_verifier = VERIFIER  --ShenMin
    from NDIRALC(updlock) where ID = @ID and SRC = @SRC --增加NDIRALC(updlock)逻辑

  if @@rowcount = 0 or @net_num is null 
  begin
    raiserror('该单据不存在', 16, 1)
    return(1)
  end

  if (select max(USERGID) from SYSTEM ) <>  @rcv_gid
  begin
    raiserror('该单据的接收单位不是本单位', 16, 1)
    return(1)
  end

  if @net_type <> 1
  begin
    raiserror('该单据不在接收缓冲区中', 16, 1)
    return(1)
  end

  if @net_stat not in (1, 4, 6)
  begin
    raiserror('该单据不是已审核、已复核或负单(冲单)，不能接收', 16, 1)
    return(1)
  end

  exec OPTREADINT 0, 'AutoOcrDate', 0, @s_AutoOcrDate output  --2002-10-28

  if @net_cls = '直配进' select @cls = '直配出'
  else if @net_cls = '直配出' select @cls = '直配进'
  else if @net_cls = '直配进退' select @cls = '直配出退'
  else if @net_cls = '直配出退' select @cls = '直配进退'
  else  return(1)

  --3566 如果网络单据的@NET_STAT小于@NET_FRCCHK那么@NET_FRCCHK也要减小
  if @net_stat < @net_frcchk 
    set @net_frcchk = @net_stat
    
  select @cur_settleno = max(NO) from MONTHSETTLE
  if @net_stat = 1 or @net_stat = 6
  begin
    if exists(select 1 from DIRALC where SRC = @SRC 
      and CLS = @cls and SRCNUM = @net_num and (STAT = 0 or STAT = 7/*2001-11-05*/))
    begin
      if  @net_frcchk = 0 begin
        raiserror('单据已被接收过', 16, 1)
     
       -- Q6402: 如果被拒绝，则自动删除单据
      IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
      BEGIN
        select  @net_billid = @ID, @net_modnum = MODNUM 
        from NDIRALC where ID = @ID and SRC = @SRC
        while (1=1)
        begin
          delete from NDIRALC where ID = @net_billid and SRC = @SRC
          delete from NDIRALCDTL where ID = @net_billid and SRC = @SRC
          if (select BATCHFLAG from SYSTEM ) = 2
              delete from NDIRALCDTL2 where ID = @net_billid and SRC = @SRC
          select @net_billid = max(ID), @net_modnum = max(MODNUM) from NDIRALC
            where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2
          if @net_billid is null break
        end
      END

      return(1)
      end
	
      select @num = NUM from DIRALC
        where SRC = @SRC and CLS = @cls and SRCNUM = @net_num and (STAT = 0 or STAT = 7/*2001-11-05*/)

      update DIRALC
        set CHECKER = @operator, FILDATE = getdate(), SETTLENO = @cur_settleno, VERIFIER = @net_verifier  --ShenMin
        where CLS = @cls and NUM = @num
      update DIRALCDTL
        set SETTLENO = @cur_settleno
        where CLS = @cls and NUM = @num
      if @net_frcchk = 1  --Fanduoyi 2004.02.25 1670
      begin
        execute @return_status = DIRALCCHK @cls, @num, 0
        if @return_status <> 0 return(@return_status)
      end
      if @net_frcchk = 6 --Fanduoyi 2004.02.25 1670 复核
      begin
        execute @return_status = DIRALCCHK @cls, @num, 2
        if @return_status <> 0 return(@return_status)
      end
	
      select  @net_billid = @ID, @net_modnum = MODNUM 
        from NDIRALC where ID = @ID and SRC = @SRC
      while (1=1)
      begin
        delete from NDIRALC where ID = @net_billid and SRC = @SRC
        delete from NDIRALCDTL where ID = @net_billid and SRC = @SRC
        if (select BATCHFLAG from SYSTEM ) = 2
            delete from NDIRALCDTL2 where ID = @net_billid and SRC = @SRC
        select @net_billid = max(ID), @net_modnum = max(MODNUM) from NDIRALC
          where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2
        if @net_billid is null break
      end
      return(0)
    end
    
    if exists(select 1 from DIRALC where SRC = @SRC       --Fanduoyi 2004.02.25 1670 复核
      and CLS = @cls and SRCNUM = @net_num and STAT = 1)
    begin
      if @net_frcchk = 6 --Fanduoyi 2004.02.25 1670 复核
      begin
        select @num = NUM from DIRALC
          where SRC = @SRC and CLS = @cls and SRCNUM = @net_num and (STAT=1)

        update DIRALC
          set CHECKER = @operator, FILDATE = getdate(), SETTLENO = @cur_settleno, VERIFIER = @net_verifier  --ShenMin
          where CLS = @cls and NUM = @num
        update DIRALCDTL
          set SETTLENO = @cur_settleno
          where CLS = @cls and NUM = @num
        
        execute @return_status = DIRALCCHK @cls, @num, 1   
        if @return_status <> 0 return(@return_status)

        select  @net_billid = @ID, @net_modnum = MODNUM 
           from NDIRALC where ID = @ID and SRC = @SRC
        while (1=1)
        begin
          delete from NDIRALC where ID = @net_billid and SRC = @SRC
          delete from NDIRALCDTL where ID = @net_billid and SRC = @SRC
          if (select BATCHFLAG from SYSTEM ) = 2
              delete from NDIRALCDTL2 where ID = @net_billid and SRC = @SRC
          select @net_billid = max(ID), @net_modnum = max(MODNUM) from NDIRALC
            where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2
          if @net_billid is null break
        end
        return(0)        
      end
      else
      begin
        raiserror('单据已被接收过', 16, 1)
       -- Q6402: 如果被拒绝，则自动删除单据
      IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
      BEGIN
        select  @net_billid = @ID, @net_modnum = MODNUM 
        from NDIRALC where ID = @ID and SRC = @SRC
        while (1=1)
        begin
          delete from NDIRALC where ID = @net_billid and SRC = @SRC
          delete from NDIRALCDTL where ID = @net_billid and SRC = @SRC
          if (select BATCHFLAG from SYSTEM ) = 2
              delete from NDIRALCDTL2 where ID = @net_billid and SRC = @SRC
          select @net_billid = max(ID), @net_modnum = max(MODNUM) from NDIRALC
            where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2
          if @net_billid is null break
        end
      END

        return(1)
      end
    end
    
    if exists(select 1 from DIRALC where SRC = @SRC 
      and CLS = @cls and SRCNUM = @net_num and STAT not in(0,1))
    begin
      raiserror('单据已被接收过', 16, 1)
       -- Q6402: 如果被拒绝，则自动删除单据
      IF EXISTS (SELECT 1 FROM HDOption WHERE ModuleNo = 0 AND OptionCaption = 'DelNBill' AND OptionValue = 1)
      BEGIN
        select  @net_billid = @ID, @net_modnum = MODNUM 
        from NDIRALC where ID = @ID and SRC = @SRC
        while (1=1)
        begin
          delete from NDIRALC where ID = @net_billid and SRC = @SRC
          delete from NDIRALCDTL where ID = @net_billid and SRC = @SRC
          if (select BATCHFLAG from SYSTEM ) = 2
              delete from NDIRALCDTL2 where ID = @net_billid and SRC = @SRC
          select @net_billid = max(ID), @net_modnum = max(MODNUM) from NDIRALC
            where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2
          if @net_billid is null break
        end
      END
      
      return(1)
    end

    select @max_num = MAX(NUM) from DIRALC where CLS = @cls
    if @max_num is null select @next_num = '0000000001'
      else execute NEXTBN @max_num, @next_num output
    execute @return_status = RCVONEDIRALC @cls, @next_num, @ID, @SRC, @operator
    if @return_status <> 0 return(@return_status)

    if @net_frcchk = 6 
    begin  --Fanduoyi 2004.02.25 1670 复核
      execute @return_status = DIRALCCHK @cls, @next_num, 2
      if @return_status <> 0 return(@return_status)
    end 
    else
      if (@net_frcchk = 1) or (@net_modnum is not null)  
      begin
        execute @return_status = DIRALCCHK @cls, @next_num, 0
        if @return_status <> 0 return(@return_status)
      end

    select @pre_num = @next_num
  end

  if  @net_stat = 4
  begin
    if (exists(select 1 from DIRALC where SRC = @SRC 
      and CLS = @cls and SRCNUM = @net_modnum and STAT = 2))
      and (not exists(select 1 from DIRALC where SRC = @SRC 
      and CLS = @cls and SRCNUM = @net_modnum and STAT in (1, 6)))
    begin
      raiserror('该单据已经被修正，不能再冲单', 16, 1)
      return(1)
    end
    select @pre_num = ''
  end
  while @net_modnum <> '' and @net_modnum is not null
  begin
    if @net_modnum = @net_num  break
  		--2002-10-28 LeeXM 2002122348830:直配单接收发生日期问题
    select @net_ocrdate = OCRDATE
      from NDIRALC
      where SRC = @src and CLS = @net_cls and MODNUM = @net_modnum

    select @net_modnum = max(MODNUM), @net_num = max(NUM), @net_billid = max(ID)
      from NDIRALC
      where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2

    if @net_num is null break

    select @stat = STAT, @num = NUM	 from DIRALC
      where CLS = @cls and SRCNUM = @net_num and SRC = @SRC
    if @@rowcount > 0
    begin
      if @stat = 0 or @stat = 7/*2001-11-05*/
      begin
        update DIRALC
          set CHECKER = @operator, FILDATE = getdate(), SETTLENO = @cur_settleno
          where  CLS = @cls and NUM = @num
        update DIRALCDTL
          set SETTLENO = @cur_settleno
          where CLS = @cls and NUM = @num
        if @net_frcchk = 6                                     --Fanduoyi 2004.02.25 1670
           execute @return_status = DIRALCCHK  @cls, @num, 2
        else 
           execute @return_status = DIRALCCHK  @cls, @num, 0
        if @return_status <> 0 return(@return_status)
        execute @return_status = DIRALCDLT  @cls, @num, @operator
        if @return_status <> 0 return(@return_status)
        /*2002-10-28*/
        if @s_AutoOcrDate = 1
          update DIRALC set OCRDATE = @net_ocrdate
            where CLS = @cls and MODNUM = @num and STAT in (3, 4)
      end
      if @stat = 1 or @stat = 6 begin
        execute @return_status = DIRALCDLT @cls, @num, @operator
        if @return_status <> 0 return(@return_status)
        /*2002-10-28*/
        if @s_AutoOcrDate = 1
          update DIRALC set OCRDATE = @net_ocrdate
            where CLS = @cls and MODNUM = @num and STAT in (3, 4)
      end

      if @pre_num <> ''
      begin
        update DIRALC
          set STAT = 3
          where CLS = @cls and NUM =
            (select max(NUM) from DIRALC where STAT = 4 and MODNUM = @num)

        update DIRALC
          set MODNUM = @num
          where CLS = @cls and NUM = @pre_num
      end
      break
    end
    select @max_num = MAX(NUM) from DIRALC where CLS = @cls
    if @max_num is null select @next_num = '0000000001'
      else execute NEXTBN @max_num, @next_num output
    execute @return_status = RCVONEDIRALC  @cls, @next_num, @net_billid, @SRC, @operator
    if @return_status <> 0 return(@return_status)
    if @net_frcchk = 6                                     --Fanduoyi 2004.02.25 1670
        execute @return_status = DIRALCCHK  @cls, @next_num, 2
    else 
        execute @return_status = DIRALCCHK  @cls, @next_num, 0
    if @return_status <> 0 return(@return_status)
    execute @return_status = DIRALCDLT  @cls, @next_num, @operator
    if @return_status <> 0 return(@return_status)
    /*2002-10-28*/
    if @s_AutoOcrDate = 1
      update DIRALC set OCRDATE = @net_ocrdate
        where CLS = @cls and MODNUM = @next_num and STAT in (3, 4)
    if @pre_num <> ''
    begin
      update DIRALC
        set STAT = 3
        where CLS = @cls and NUM =
          (select max(NUM) from DIRALC where STAT = 4 and MODNUM = @next_num)

      update DIRALC
        set MODNUM = @next_num
        where CLS = @cls and NUM = @pre_num
    end

    select @pre_num = @next_num
  end
        
  select  @net_billid = @ID, @net_modnum = MODNUM 
    from NDIRALC where ID = @ID and SRC = @SRC
  while (1=1)
  begin
    delete from NDIRALC where ID = @net_billid and SRC = @SRC
    delete from NDIRALCDTL where ID = @net_billid and SRC = @SRC
    if (select BATCHFLAG from SYSTEM ) = 2
        delete from NDIRALCDTL2 where ID = @net_billid and SRC = @SRC
    select @net_billid = max(ID), @net_modnum = max(MODNUM) from NDIRALC
      where SRC = @SRC and CLS = @net_cls and NUM = @net_modnum and STAT = 2
    if @net_billid is null break
  end
  
--2005.11.2, Edited by ShenMin, Q5336, 直配单发送时应同步发送单据附件

  if exists(select * from NBILLAPDX
    where ID = @id and SRC = @SRC and BILL = 'DIRALC' and CLS = @net_cls)
      begin
        if (select max(USERGID) from SYSTEM ) =  @SRC
          begin
            raiserror('不能接收来源单位为本单位的单据附件！', 16, 1)
            delete from NBILLAPDX
            where ID = @id and SRC = @SRC and BILL = 'DIRALC' and CLS = @net_cls and SRCNUM = @net_num
            return(1)
          end
        delete from BILLAPDX where BILL = 'DIRALC' and CLS = @net_cls and SRC = @SRC and SRCNUM = @net_num

        insert into BILLAPDX(BILL, CLS, NUM, FILDATE, DSPMODE, DSPDATE,
                             OUTCTR, OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
                             INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, 
                             HDBILLNUM, INUNIT, NOTE2, SRCNUM, SRC)
        select 'DIRALC', @cls, @next_num, FILDATE, DSPMODE, DSPDATE,
                             OUTCTR, OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
                             INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE,
                             HDBILLNUM, INUNIT, NOTE2, SRCNUM, SRC
        from NBILLAPDX
        where ID = @id and SRC = @SRC and BILL = 'DIRALC' and CLS = @net_cls and SRCNUM = @net_num

        delete from NBILLAPDX
        where ID = @id and SRC = @SRC and BILL = 'DIRALC' and CLS = @net_cls and SRCNUM = @net_num
      end  
  return(0)
end
GO
