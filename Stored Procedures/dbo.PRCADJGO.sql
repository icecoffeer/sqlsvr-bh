SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCADJGO](
  @p_cls char(8),
  @p_num char(10),
  @errmsg varchar(255) output
) --with encryption 
as
begin
  declare
    @return_status int,
    @cur_date datetime,
    @fildate datetime,
    @cur_settleno int,

    @m_eon smallint,
    @m_adjamt money,
    @d_adjamt money,
    @d_cls char(8),
    @d_num char(10),
    @d_line smallint,
    @d_gdgid int,
    @d_newprc money,
    @pre_gdgid int,
    @t_qty money,
    @d_BQtyPrc money,
    @strBQtyPrc varchar(100),
    @d_storegid int,

    @msg varchar(100),
    @launch datetime,
    @canoccur int,
    @d_gdQpcStr char(15),
    @d_gdqpc money

  select @cur_date = convert(datetime, convert(char,getdate(),102)),
    @m_eon = EON, @launch = launch, @fildate = fildate
    from PRCADJ
    where CLS = @p_cls and NUM = @p_num

  select @cur_settleno = max(NO) from MONTHSETTLE

  if @p_cls <> '量贩价'
  begin
    declare c_prcadjchk cursor for
      select CLS, NUM, LINE, GDGID, NEWPRC, QPCSTR, QPC
      from PRCADJDTL where CLS = @p_cls and NUM = @p_num
      for update
    open c_prcadjchk
    fetch next from c_prcadjchk into
      @d_cls, @d_num, @d_line, @d_gdgid, @d_newprc, @d_gdqpcstr, @d_gdqpc
    select @m_adjamt = 0
    while @@fetch_status = 0
    begin
      if @m_eon = 1
      begin
        exec @return_status = PrcAdjChkOcr @p_cls, @p_num, @d_line, @d_gdgid, @d_gdQpcStr, @launch, @fildate, @canoccur output
        if @return_status <> 0 break
        if @canoccur = 1
        begin
          execute @return_status = PRCADJDTLCHK
            @cur_date, @cur_settleno,
            @d_cls, @d_num, @d_line, @d_gdgid, @d_gdqpcstr, @d_gdqpc, @d_newprc,
            @d_adjamt output
          if @return_status <> 0 break
          select @m_adjamt = @m_adjamt + @d_adjamt
        end
      end
      execute @return_status = PRCADJLACDTLCHK
        @cur_date, @cur_settleno,
        @d_cls, @d_num, @d_line, @d_gdgid, @d_gdqpcstr, @d_gdqpc, @d_newprc
      if @return_status <> 0 break
      fetch next from c_prcadjchk into
        @d_cls, @d_num, @d_line, @d_gdgid, @d_newprc, @d_gdqpcstr, @d_gdqpc
    end
    close c_prcadjchk
    deallocate c_prcadjchk

  end else      --Added By Wang xin 2002-05-06
  begin

    declare BQtyPrc cursor for
      select GDGID, QTY, NewPrc, QPCSTR, QPC, LINE from PRCADJDTL
      where cls = @p_cls and Num = @p_NUM --and NEWPRC > 0 modified by wang xin 2002.07.20
      order by GDGID, QTY
    open BQtyPrc
    fetch next from BQtyPrc into @d_gdgid, @t_qty, @d_BQtyPrc, @d_gdqpcstr, @d_gdqpc, @d_line
    select @pre_gdgid = @d_gdgid
    select @strBQtyPrc = ''
    while @@fetch_status = 0
    begin
      if @d_gdgid <> @pre_gdgid
      begin
      	if @strBQtyPrc = '' --Added by wang xin 2002.07.20
      		set @strBQtyPrc = null
        if @m_eon = 1
        begin
          exec PrcAdjChkOcr @p_cls, @p_num, @d_line, @d_gdgid, @d_gdQpcStr, @launch, @fildate, @canoccur output
          if @canoccur = 1
          begin
            if @d_gdqpcstr = '1*1'
            begin
              update GOODS set BQTYPRC = @strBQtyPrc where GID = @pre_gdgid
              update GDQPC set BQTYPRC = @strBQtyPrc where GID = @pre_gdgid and QPCSTR = @d_gdqpcstr
            end
            else
              update GDQPC set BQTYPRC = @strBQtyPrc where GID = @pre_gdgid and QPCSTR = @d_gdqpcstr
          end
        end
          declare c_lac cursor for
            select STOREGID from PRCADJLACDTL
            where CLS = @p_cls and NUM = @p_num
            for read only
          open c_lac
          fetch next from c_lac into @d_storegid
          while @@fetch_status = 0
          begin
            if exists(select 1 from V_QPCGDSTORE
              where STOREGID = @d_storegid and GDGID = @pre_GDGID and qpcqpcstr = @d_gdqpcstr)
            begin
              if @d_gdqpcstr = '1*1'
              begin
                update GDSTORE set BQTYPRC = @strBQtyPrc
                  where STOREGID = @d_storegid and GDGID = @pre_gdgid
                update GDQPCSTORE set BQTYPRC = @strBQtyPrc
                  where STOREGID = @d_storegid and GDGID = @pre_gdgid and QPCSTR = @d_gdqpcstr
              end
              else
                update GDQPCSTORE set BQTYPRC = @strBQtyPrc
                  where STOREGID = @d_storegid and GDGID = @pre_gdgid and QPCSTR = @d_gdqpcstr
            end
            else
            begin
              if @d_gdqpcstr = '1*1'
              begin
                insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
                select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
                  QPCRTLPRC, QPCRTLPRC, QPCLWTRTLPRC, QPCTOPRTLPRC, @strBQtyPrc, QPCPROMOTE
                  from V_QPCGOODS
                  where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
                if exists(select 1 from GDSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid)
                  update GDSTORE set BQTYPRC = @strBQtyPrc
                    where STOREGID = @d_storegid and GDGID = @d_gdgid
                else
                  insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,INPRC, PROMOTE, GFT, LWTRTLPRC, MBRPRC,DXPRC,PAYRATE, CNTINPRC, BQTYPRC)
                    select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC, INPRC, PROMOTE, GFT, LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC, @strBQtyPrc
                    from GOODS
                    where GID = @pre_gdgid
              end else
              begin
                insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
                select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
                  QPCRTLPRC, QPCRTLPRC, QPCLWTRTLPRC, QPCTOPRTLPRC, @strBQtyPrc, QPCPROMOTE
                  from V_QPCGOODS
                  where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
              end
            end
            fetch next from c_lac into @d_storegid
          end
          close c_lac
          deallocate c_lac
        select @pre_gdgid = @d_gdgid
        select @strBQtyPrc = ''
      end
      if @d_BQtyPrc > 0
      	select @strBQtyPrc = @strBQtyPrc + convert(varchar(10),@t_qty) + ':' + convert(varchar(10), @d_BQtyPrc)
      fetch next from BQtyPrc into @d_gdgid, @t_qty, @d_BQtyPrc, @d_gdqpcstr, @d_gdqpc, @d_line
      if @pre_gdgid = @d_gdgid and @@fetch_status = 0 and @strBQtyPrc <> '' and @d_BQtyPrc > 0--modified by wang xin 2002.07.20
        select @strBQtyPrc = @strBQtyPrc + ';'
      if @@fetch_status <> 0 begin
      	if @strBQtyPrc = ''--Added by wang xin 2002.07.20
      		set @strBQtyPrc = null
        if @m_eon = 1
        begin
          exec PrcAdjChkOcr @p_cls, @p_num, @d_line, @d_gdgid, @d_gdQpcStr, @launch, @fildate, @canoccur output
          if @canoccur = 1
          begin
            if @d_gdqpcstr = '1*1'
            begin
              update GOODS set BQTYPRC = @strBQtyPrc where GID = @pre_gdgid
              update GDQPC set BQTYPRC = @strBQtyPrc where GID = @pre_gdgid and QPCSTR = @d_gdqpcstr
            end
            else
              update GDQPC set BQTYPRC = @strBQtyPrc where GID = @pre_gdgid and QPCSTR = @d_gdqpcstr
          end
        end
          declare c_lac cursor for
            select STOREGID from PRCADJLACDTL
            where CLS = @p_cls and NUM = @p_num
            for read only
          open c_lac
          fetch next from c_lac into @d_storegid
          while @@fetch_status = 0
          begin
            if exists(select 1 from V_QPCGDSTORE
              where STOREGID = @d_storegid and GDGID = @pre_GDGID and qpcqpcstr = @d_gdqpcstr)
            begin
              if @d_gdqpcstr = '1*1'
              begin
               update GDSTORE set BQTYPRC = @strBQtyPrc
                 where STOREGID = @d_storegid and GDGID = @pre_gdgid
               update GDQPCSTORE set BQTYPRC = @strBQtyPrc
                 where STOREGID = @d_storegid and GDGID = @pre_gdgid and QPCSTR = @d_gdqpcstr
             end
             else
               update GDQPCSTORE set BQTYPRC = @strBQtyPrc
                 where STOREGID = @d_storegid and GDGID = @pre_gdgid and QPCSTR = @d_gdqpcstr
            end
            else
            begin
              if @d_gdqpcstr = '1*1'
              begin
                insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
                select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
                  QPCRTLPRC, QPCMBRPRC, QPCLWTRTLPRC, QPCTOPRTLPRC, @strBQtyPrc, QPCPROMOTE
                  from V_QPCGOODS
                  where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr

                if exists(select 1 from GDSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid)
                  update GDSTORE set BQTYPRC = @strBQtyPrc
                    where STOREGID = @d_storegid and GDGID = @d_gdgid
                else
                  insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,INPRC, PROMOTE, GFT, LWTRTLPRC, MBRPRC,DXPRC,PAYRATE, CNTINPRC, BQTYPRC)
                    select @d_storegid, GID, BILLTO, SALE, ALC, RTLPRC, INPRC, PROMOTE, GFT, LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC, @strBQtyPrc
                    from GOODS
                    where GID = @pre_gdgid
              end else
              begin
                insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
                select @d_storegid, GID, @d_gdqpcstr, @d_gdqpc,
                  QPCRTLPRC, QPCMBRPRC, QPCLWTRTLPRC, QPCTOPRTLPRC, @strBQtyPrc, QPCPROMOTE
                  from V_QPCGOODS
                  where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
              end
            end
            fetch next from c_lac into @d_storegid
          end
          close c_lac
          deallocate c_lac
      end
      select @return_status = 0
      select @m_adjamt = 0
    end
    close BQtyPrc
    deallocate BQtyPrc

  end

  if @return_status = 0
  begin
    if @d_cls = '库存价'
    update PRCADJ set
      STAT = 1,
      FILDATE = getdate(),
      SETTLENO = @cur_settleno
      where CLS = @p_cls and NUM = @p_num	--2002-07-03
    else
    update PRCADJ set
      STAT = 5,
      FILDATE = getdate(),
      SETTLENO = @cur_settleno
      where CLS = @p_cls and NUM = @p_num
    if @m_eon = 1
      update PRCADJ set
        ADJAMT = @m_adjamt
        where CLS = @p_cls and NUM = @p_num
    --消息提醒 add by zhuhaohui 2007.12.18
    execute PrcAdjChkValidate @p_cls, @p_num
    --结束消息提醒
  end else
  begin
    /* 99-6-16 */
    select @errmsg = @p_cls + '调整单  ' + @p_num
    if @return_status = 1
      select @errmsg = @errmsg + '新核算售价低于(非本店)最低售价.'
    else if @return_status = 2
      select @errmsg = @errmsg + '新最低售价高于(非本店)核算售价.'
    else if @return_status = 3
      select @errmsg = @errmsg + '新核算售价高于(非本店)最高售价.'
    else if @return_status = 4
      select @errmsg = @errmsg + '新最低售价高于本店核算售价.'
    else if @return_status = 5
      select @errmsg = @errmsg + '新核算售价低于本店最低售价.'
    else if @return_status = 6
      select @errmsg = @errmsg + '核算售价不能高于最高售价.'
  --2006.5.29, ShenMin, Q6676
    else if @return_status = 7
      select @errmsg = @errmsg + '新会员价不能高于调价方案中规定的上限.'
    else if @return_status = 8
      select @errmsg = @errmsg + '新会员价不能低于调价方案中规定的下限.'
    else
      select @errmsg = @errmsg + '单据生效时发生错误.'
  end
  return (@return_status)
end

GO
