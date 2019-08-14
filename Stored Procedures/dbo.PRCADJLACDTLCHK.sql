SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCADJLACDTLCHK](
  @cur_date datetime,
  @cur_settleno int,
  @d_cls char(8),
  @d_num char(10),
  @d_line smallint,
  @d_gdgid int,
  @d_gdqpcstr char(15),
  @d_gdqpc money,
  @d_newprc money
) with encryption as
begin
  declare
    @ret_status int,
    @d_storegid int,
    @qty money,
    @oldprc money,
    @sale smallint,
    @payrate money,
    @rtlprc money,
    @lwtrtlprc money,
    @toprtlprc money,
    @date datetime,
    @yno int

  select @ret_status = 0
  select @date = convert(datetime, convert(char, @cur_date, 102))
  select @yno = yno from v_ym where mno = @cur_settleno

  declare c_lac cursor for
    select STOREGID from PRCADJLACDTL
    where CLS = @d_cls and NUM = @d_num
    for read only
  open c_lac
  fetch next from c_lac into @d_storegid
  while @@fetch_status = 0
  begin
    select @qty = sum(QTY) from INV
      where STORE = @d_storegid and WRH = 1 and GDGID = @d_gdgid
    if @qty is null select @qty = 0

    if @d_cls = '核算价' begin

      if exists (select 1 from GDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid)
      begin
        select @oldprc = isnull(INPRC, 0) from GDSTORE
          where STOREGID = @d_storegid and GDGID = @d_gdgid
        update GDSTORE set INPRC = @d_newprc
          where STOREGID = @d_storegid and GDGID = @d_gdgid
      end else
      begin
        select @oldprc = INPRC from GOODS
          where GID = @d_gdgid
        insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,
          INPRC, /*LOWINV, HIGHINV, 2002-01-11*/ PROMOTE, GFT,
          LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)  --2001.4.2
          select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC,
            @d_newprc, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
            LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC  --2001.4.2
            from GOODS
            where GID = @d_gdgid
      end
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newprc - @oldprc)) )

    end else if @d_cls = '核算售价' begin

      if exists(select 1 from V_QPCGDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid and qpcqpcstr = @d_gdqpcstr)
      begin
        select @oldprc = isnull(QPCRTLPRC, 0), @sale = SALE, @payrate = isnull(PAYRATE, 0),
          @lwtrtlprc = isnull(QPCLWTRTLPRC, 0),@toprtlprc = isnull(QPCtoprtlprc,900000000000000)
          from V_QPCGDSTORE
          where STOREGID = @d_storegid and GDGID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        if @d_newprc < @lwtrtlprc
        begin
--          raiserror('新核算售价低于(非本店)最低售价.', 16, 1)
          select @ret_status = 1
          break
        end
        if @d_newprc > @toprtlprc
        begin
          select @ret_status = 3
          break
        end
        if @d_gdqpcstr = '1*1'
        begin
          update GDSTORE set RTLPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid
          update GDQPCSTORE set RTLPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid and QPCSTR = @d_gdqpcstr
        end
        else
          update GDQPCSTORE set RTLPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid and QPCSTR = @d_gdqpcstr
      end else
      begin
        select @oldprc = qpcRTLPRC, @sale = SALE, @payrate = PAYRATE,
          @lwtrtlprc = isnull(qpcLWTRTLPRC,0),
          @toprtlprc = isnull(qpctoprtlprc,900000000000000)
          from V_QPCGOODS(nolock)
          where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        if @d_newprc < @lwtrtlprc
        begin
--          raiserror('新核算售价低于(非本店)最低售价.', 16, 1)
          select @ret_status = 1
          break
        end
        if @d_newprc > @toprtlprc
        begin
          select @ret_status = 3
          break
        end

        if @d_gdqpcstr = '1*1'
        begin
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
          select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc, @d_newprc,
            QPCMBRPRC, QPCLWTRTLPRC, QPCTOPRTLPRC, QPCBQTYPRC, QPCPROMOTE
            from V_QPCGOODS
            where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
          if exists(select 1 from GDSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid)
            update GDSTORE set RTLPRC = @d_newprc
              where STOREGID = @d_storegid and GDGID = @d_gdgid
          else
            insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC, --Modified by wang xin 2003.05.21
              INPRC, /*LOWINV, HIGHINV,2002-01-11*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)  --2001.4.2
            select @d_storegid, GID, BILLTO, SALE, ALC, @d_newprc, --Modified by wang xin 2003.05.21
              INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC  --2001.4.2
              from GOODS
              where GID = @d_gdgid
        end else
        begin
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
          select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc, @d_newprc,
            QPCMBRPRC, QPCLWTRTLPRC, QPCTOPRTLPRC, QPCBQTYPRC, QPCPROMOTE
            from V_QPCGOODS
            where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        end
      end
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_R )
        values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @oldprc)))
      /*
      -- 库存报表
      execute CRTINVRPT @d_storegid, @cur_settleno, @date, 1, @d_gdgid
      update INVDRPT
        set FT = FT + convert(decimal(20, 2), @qty * (@d_newprc - @rtlprc))
        where INVDRPT.ASETTLENO = @cur_settleno and INVDRPT.ADATE = @date
        and INVDRPT.ASTORE = @d_storegid and INVDRPT.BWRH = 1
        and INVDRPT.BGDGID = @d_gdgid
      update INVMRPT
        set FT = FT + convert(decimal(20, 2), @qty * (@d_newprc - @rtlprc))
        where INVMRPT.ASETTLENO = @cur_settleno and INVMRPT.ASTORE = @d_storegid
        and INVMRPT.BWRH = 1 and INVMRPT.BGDGID = @d_gdgid
      update INVYRPT
        set FT = FT + convert(decimal(20, 2), @qty * (@d_newprc - @rtlprc))
        where INVYRPT.ASETTLENO = @yno and INVYRPT.ASTORE = @d_storegid
        and INVYRPT.BWRH = 1 and INVYRPT.BGDGID = @d_gdgid
      */
      if @sale = 3
        insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
          convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @oldprc) * @payrate / 100.00))

    end else if @d_cls = '最低售价' begin

      if exists(select 1 from V_QPCGDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid and qpcqpcstr = @d_gdqpcstr)
      begin
        select @rtlprc = isnull(QPCRTLPRC, 0) from V_QPCGDSTORE
          where STOREGID = @d_storegid and GDGID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        if @d_newprc > @rtlprc
        begin
--          raiserror('新最低售价高于(非本店)核算售价.', 16, 1)
          select @ret_status = 2
          break
        end
        if @d_gdqpcstr = '1*1'
        begin
          update GDSTORE set LWTRTLPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid
          update GDQPCSTORE set LWTRTLPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid and QPCSTR = @d_gdqpcstr
        end
        else
          update GDQPCSTORE set LWTRTLPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid and QPCSTR = @d_gdqpcstr
      end else
      begin
        select @rtlprc = QPCRTLPRC from V_QPCGOODS where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        if @d_newprc > @rtlprc
        begin
--          raiserror('新最低售价高于(非本店)核算售价.', 16, 1)
          select @ret_status = 2
          break
        end
        if @d_gdqpcstr = '1*1'
        begin
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
          select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
            QPCRTLPRC, QPCMBRPRC, @d_newprc, QPCTOPRTLPRC, QPCBQTYPRC, QPCPROMOTE
            from V_QPCGOODS
            where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr

          if exists(select 1 from GDSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid)
            update GDSTORE set LWTRTLPRC = @d_newprc
              where STOREGID = @d_storegid and GDGID = @d_gdgid
          else
            insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC, --Modified by wang xin 2003.05.21
              INPRC, /*LOWINV, HIGHINV,2002-01-11*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)  --2001.4.2
            select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC, --Modified by wang xin 2003.05.21
              INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
              @d_newprc, MBRPRC, DXPRC, PAYRATE, CNTINPRC  --2001.4.2
              from GOODS
              where GID = @d_gdgid
        end else
        begin
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
          select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
            QPCRTLPRC, QPCMBRPRC, @d_newprc, QPCTOPRTLPRC, QPCBQTYPRC, QPCPROMOTE
            from V_QPCGOODS
            where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        end
      end

    end else if @d_cls = '会员价' begin

      if exists(select 1 from V_QPCGDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid and qpcqpcstr = @d_gdqpcstr)
      begin
        if @d_gdqpcstr = '1*1'
        begin
          update GDSTORE set MBRPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid
          update GDQPCSTORE set MBRPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid and QPCSTR = @d_gdqpcstr
        end
        else
          update GDQPCSTORE set MBRPRC = @d_newprc
            where STOREGID = @d_storegid and GDGID = @d_gdgid and QPCSTR = @d_gdqpcstr
      end
      else
      begin
        if @d_gdqpcstr = '1*1'
        begin
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
          select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
            QPCRTLPRC, @d_newprc, QPCLWTRTLPRC, QPCTOPRTLPRC, QPCBQTYPRC, QPCPROMOTE
            from V_QPCGOODS
            where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
          if exists(select 1 from GDSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid)
            update GDSTORE set MBRPRC = @d_newprc
              where STOREGID = @d_storegid and GDGID = @d_gdgid
          else
            insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,
              INPRC, /*LOWINV, HIGHINV,2002-01-11*/ PROMOTE, GFT,
              LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)  --2001.4.2
            select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC, --Modified by wang xin 2003.05.21
              INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
              LWTRTLPRC, @d_newprc, DXPRC, PAYRATE, CNTINPRC  --2001.4.2
              from GOODS
             where GID = @d_gdgid
        end else
        begin
          insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
          select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
            QPCRTLPRC, @d_newprc, QPCLWTRTLPRC, QPCTOPRTLPRC, QPCBQTYPRC, QPCPROMOTE
            from V_QPCGOODS
            where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
        end
      end

    end else if @d_cls = '代销价' begin

      if exists(select 1 from GDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid)
      begin
        select @oldprc = isnull(DXPRC, 0) from GDSTORE
          where STOREGID = @d_storegid and GDGID = @d_gdgid
        update GDSTORE set DXPRC = @d_newprc
          where STOREGID = @d_storegid and GDGID = @d_gdgid
      end else
      begin
        select @oldprc = DXPRC from GOODS
          where GID = @d_gdgid
        insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,
          INPRC, /*LOWINV, HIGHINV,2002-01-11*/ PROMOTE, GFT,
          LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)  --2001.4.2
          select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC,
            INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
            LWTRTLPRC, MBRPRC, @d_newprc, PAYRATE, CNTINPRC  --2001.4.2
            from GOODS
            where GID = @d_gdgid
      end
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newprc - @oldprc)) )

    end else if @d_cls = '联销率' begin

      if exists(select 1 from GDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid)
      begin
        select @oldprc = isnull(PAYRATE, 75), @rtlprc = RTLPRC from GDSTORE
          where STOREGID = @d_storegid and GDGID = @d_gdgid
        update GDSTORE set PAYRATE = @d_newprc
          where STOREGID = @d_storegid and GDGID = @d_gdgid
      end else
      begin
        select @oldprc = PAYRATE, @rtlprc = RTLPRC
          from GOODS
          where GID = @d_gdgid
        insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,
          INPRC, /*LOWINV, HIGHINV,2002-01-11*/ PROMOTE, GFT,
          LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)  --2001.4.2
          select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC,
            INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
            LWTRTLPRC, MBRPRC, DXPRC, @d_newprc, CNTINPRC  --2001.4.2
            from GOODS
            where GID = @d_gdgid
      end
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newprc - @oldprc) / 100.00 * @rtlprc) )

    end else if @d_cls = '积分' begin   -- add by CQH 积分处理
      if exists(select 1 from GDSCORE where STORE = @d_storegid and GDGID = @d_gdgid)
         update GDSCORE set SCORE = @d_newprc where STORE = @d_storegid and GDGID = @d_gdgid
     else
        insert into GDSCORE (STORE, GDGID, SCORE) values(@d_storegid, @d_gdgid, @d_newprc)

    end else if @d_cls = '合同进价' begin  --2001.4.2 add by ysp 合同进价处理
      if exists(select 1 from GDSTORE
        where STOREGID = @d_storegid and GDGID = @d_gdgid)
        update GDSTORE set CNTINPRC = @d_newprc
          where STOREGID = @d_storegid and GDGID = @d_gdgid
      else
        insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,
          INPRC, /*LOWINV, HIGHINV,2002-01-11*/ PROMOTE, GFT,
          LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)
          select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC,
            INPRC, /*LOWINV, HIGHINV,*/ PROMOTE, GFT,
            LWTRTLPRC, @d_newprc, DXPRC, PAYRATE, @d_newprc
            from GOODS
            where GID = @d_gdgid

    end

    fetch next from c_lac into @d_storegid
  end
  close c_lac
  deallocate c_lac

  return(@ret_status)
end
GO
