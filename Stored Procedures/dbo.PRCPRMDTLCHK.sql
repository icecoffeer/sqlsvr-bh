SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMDTLCHK](
  @p_num char(10),
  @p_storegid int
)as
begin
  declare
    @s_usergid int,
    @line smallint,
    @gdgid int,
    @prmtype smallint,
    @cangft smallint,
    @QPC money,
    @QPCSTR char(15),
    @optUseGdQpc char(1),

    @NewPrmPri decimal(24,4),  --ShenMin, Q7135
    @PrmTopicCode char(10),  --ShenMin, Q7135
    @OverWriteRule smallint,
    @ITEM int,
    @START datetime,
    @FINISH datetime,
    --促销优先级
    @opt_UsePromPir smallint,
    @v_Priority int

  exec OPTREADINT 0, 'PS3_UsePromPriority', 0, @opt_UsePromPir OutPut

  select @s_usergid = USERGID from SYSTEM
  select @optUseGdQpc = optionvalue from hdoption where optioncaption = 'USEGDQPC' and moduleno = 0
  if @optUseGdQpc is null set @optUseGdQpc = '0'
 --ShenMin, Q7135
  select @NewPrmPri = ISNULL(T.PRI, 0), @PrmTopicCode = P.TOPIC, @OverWriteRule = OverWriteRule,
    @v_Priority = PRIORITY
  from PRCPRM P(nolock), PRMTOPIC T (nolock)
    where P.NUM = @p_num and P.TOPIC = T.CODE
  set @NewPrmPri = isnull(@NewPrmPri, 0)

  declare c_prcprm cursor for
    select LINE, GDGID, PRMTYPE, CANGFT, QPC, QPCSTR from PRCPRMDTL where NUM = @p_num
  open c_prcprm
  fetch next from c_prcprm into @line, @gdgid, @prmtype, @cangft, @QPC, @QPCSTR
  while @@fetch_status = 0
  begin
    if @s_usergid = @p_storegid
    begin
      if @optUseGdQpc = '0'
        update GOODS
          set PROMOTE = @prmtype, GFT = @cangft
        where GID = @gdgid
      else
      begin
        if @QPCSTR = '1*1'
          update GOODS
            set PROMOTE = @prmtype, GFT = @cangft
            where GID = @gdgid
        update GDQPC
          set PROMOTE = @prmtype
            where GID = @gdgid and QPCSTR = @QPCSTR
      end
    end
    else
    begin
      if @optUseGdQpc = '0'
      begin
        if not exists (select 1 from GDSTORE
          where STOREGID = @p_storegid and GDGID = @gdgid)
          insert into GDSTORE (STOREGID, GDGID, BILLTO, ALC,   --Fanduoyi 1760
              SALE, RTLPRC, INPRC, /*LOWINV, HIGHINV,2002-02-04*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, ISLTD)
          select @p_storegid, GID, BILLTO, ALC, --Fanduoyi 1760
              SALE, RTLPRC, INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, 0
          from GOODS where GID = @gdgid
        update GDSTORE set
          PROMOTE = @prmtype, GFT = @cangft
          where STOREGID = @p_storegid and GDGID = @gdgid
      end else
      begin
        if @QPCSTR = '1*1'
        begin
          if not exists (select 1 from GDSTORE
            where STOREGID = @p_storegid and GDGID = @gdgid)
            insert into GDSTORE (STOREGID, GDGID, BILLTO, ALC,   --Fanduoyi 1760
              SALE, RTLPRC, INPRC, /*LOWINV, HIGHINV,2002-02-04*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, ISLTD)
            select @p_storegid, GID, BILLTO, ALC, --Fanduoyi 1760
              SALE, RTLPRC, INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, 0
            from GOODS where GID = @gdgid
          update GDSTORE set
            PROMOTE = @prmtype, GFT = @cangft
            where STOREGID = @p_storegid and GDGID = @gdgid
        end
        if not exists (select 1 from GDQPCSTORE
          where STOREGID = @p_storegid and GDGID = @gdgid and QPCSTR = @QPCSTR)
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC,   --Fanduoyi 1760
            RTLPRC, PROMOTE,
            LWTRTLPRC, MBRPRC)
          select @p_storegid, GID, @QPCSTR, @QPC, --Fanduoyi 1760
            RTLPRC, PROMOTE,
            LWTRTLPRC, MBRPRC
          from GDQPC where GID = @gdgid and QPCSTR = @QPCSTR
        update GDQPCSTORE set
          PROMOTE = @prmtype
          where STOREGID = @p_storegid and GDGID = @gdgid and QPCSTR = @QPCSTR
      end
    end
    --当启用优先级选项关闭(默认)时,保持原有逻辑,否则采用新的逻辑(直接写PRICE表)
    if @opt_UsePromPir = 0
    begin
      --ShenMin, Q7135
      --delete from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
      --符合以下情况之一的可以覆盖price表：1、上次的促销已结束。2、本次促销的优先级高于上次。
      if (select count(1)from price, prmtopic
       where price.GDGID = @gdgid and price.STOREGID = @p_storegid and price.QPCSTR = @QPCSTR
         and isnull(price.prmtopiccode, '-') = prmtopic.code and (price.finish <= getdate() or (Isnull(prmtopic.pri, 0) <= @NewPrmPri)))
         > 0
      begin
        if @OverWriteRule = 0 and @prmtype <> -1 --交叉生效方式
        begin --逐行促销方案处理
          declare c_prcprmdtl cursor for
            select ITEM, START, FINISH from PRCPRMDTLDTL where NUM = @p_num and LINE = @line
          open c_prcprmdtl
          fetch next from c_prcprmdtl into @ITEM, @START, @FINISH
          while @@fetch_status = 0
          begin
            --开始时间小于 + 结束时间大于:k < k1 and j > j1 3段有效值
            if exists (select 1 from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
              and START < @START and FINISH > @FINISH)
            begin
             if @START > getdate() --后面单据的开始时间大于当前时间
               insert into PRICE(STOREGID, GDGID, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT,
                 INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE, PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM)
               select STOREGID, GDGID, START, @START, CYCLE, CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT,
                 INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE, PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM
               from PRICE(nolock) where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
                 and START < @START and FINISH > @FINISH
             --开始时间修改为后一单的结束时间
             update PRICE set START = @FINISH where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
               and START < @START and FINISH > @FINISH
            end

            --开始时间小于 + 结束时间小于结束时间 + 结束时间大于原开始时间:k < k1 and j < j1 and j > k1
            if exists (select 1 from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
              and START < @START and FINISH < @FINISH and FINISH > @START)
              update PRICE set FINISH = @START where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
                and START < @START and FINISH < @FINISH and FINISH > @START

            --开始时间大于 + 结束时间大于 + 原结束时间大于现开始时间:k > k1 and j > j1 and j1 > k
            if exists (select 1 from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
              and START > @START and FINISH > @FINISH and START < @FINISH)
              update PRICE set START = @FINISH where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
                and START > @START and FINISH > @FINISH and START < @FINISH

            --开始时间大于 + 结束时间小于:k >= k1 and j <= j1(以现有时间为主语)
            if exists (select 1 from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
              and START >= @START and FINISH <= @FINISH)
              delete from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
                and START >= @START and FINISH <= @FINISH

            ----写入
            delete from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR and START = @START and FINISH = @FINISH
            insert into PRICE(STOREGID, GDGID, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID,
              GFTQTY, GFTPER, GFTTYPE, PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM)
            select @p_storegid, @gdgid, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID,
              GFTQTY, GFTPER, GFTTYPE, PRMTAG, MBRPRC, @QPC, @QPCSTR, @PrmTopicCode, @p_num
            from PRCPRMDTLDTL where NUM = @p_num and LINE = @line and ITEM = @ITEM

            fetch next from c_prcprmdtl into @ITEM, @START, @FINISH
          end
          close c_prcprmdtl
          deallocate c_prcprmdtl
        end else
        begin
          delete from PRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
          insert into PRICE(STOREGID, GDGID, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC,
              QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE,
              PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM)
          select @p_storegid, @gdgid, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC,
              QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE,
              PRMTAG, MBRPRC, @QPC, @QPCSTR, @PrmTopicCode, @p_num
          from PRCPRMDTLDTL where NUM = @p_num and LINE = @line
        end
      end
    --ShenMin, Q8174
      else if (select count(1)from price
               where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR) = 0
      begin
        insert into PRICE(STOREGID, GDGID, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC,
          QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE,
          PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM)
        select @p_storegid, @gdgid, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC,
          QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE,
          PRMTAG, MBRPRC, @QPC, @QPCSTR, @PrmTopicCode, @p_num
        from PRCPRMDTLDTL where NUM = @p_num and LINE = @line
      end
    end else
    --@opt_UsePromPir=1,直接写PRICE表
    begin
      insert into PRICE(STOREGID, GDGID, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC,
        QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE,
        PRMTAG, MBRPRC, QPC, QPCSTR, PRMTOPICCODE, SRCNUM, PRIORITY)
      select @p_storegid, @gdgid, START, FINISH, CYCLE, CSTART, CFINISH, CSPEC,
        QTYLO, QTYHI, PRICE, DISCOUNT, INPRC, GFTGID, GFTQTY, GFTPER, GFTTYPE,
        PRMTAG, MBRPRC, @QPC, @QPCSTR, @PrmTopicCode, @p_num, @v_Priority
      from PRCPRMDTLDTL where NUM = @p_num and LINE = @line
    end

    fetch next from c_prcprm into @line, @gdgid, @prmtype, @cangft, @QPC, @QPCSTR
  end
  close c_prcprm
  deallocate c_prcprm

  return(0)
end
GO
