SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
cREATE procedure [dbo].[RtlPrcAdj_To800_Eon1]
(
  @cur_date datetime,
  @cur_settleno int,
  @d_cls int,
  @d_num char(14),
  @d_line smallint,
  @d_gdgid int,
  @d_QpcStr varchar(15),
  @d_newrtlprc money,
  @d_newlwtprc money,
  @d_newtopprc money,
  @d_newmbrprc money,
  @d_newwhsprc money
)
With Encryption
as
begin
  declare
    @iwrh int,
    @qty money,
    @t_qty money,
    @total money,
    @rtlprc money,
    @lwtrtlprc money,
    @toprtlprc money,
    @mbrprc money,
    @whsprc money,
    @payrate money,
    @sale smallint,
    @s_usergid int,
    @date datetime,
    @yno int,
    @zbgid int,
    @src int,
    @updatesql varchar(1000),
    @updatesql2 varchar(1000),
    @optUseGdQpc char(1),
    @QPCSTR varchar(15)

  select @optUseGdQpc = optionvalue from hdoption where optioncaption = 'USEGDQPC' and moduleno = 0
  if @optUseGdQpc is null set @optUseGdQpc = '0'
  select @s_usergid = USERGID, @zbgid = ZBGID from system
  select @date = convert(datetime, convert(char, @cur_date, 102))
  select @yno = yno from v_ym where mno = @cur_settleno
  select @src = src from rtlprcadj where num = @d_num
  set @updatesql = ' update goods set lstupdtime = getdate(), gid = gid '
  set @updatesql2 = ' update GDQPC set gid = gid '

  select @t_qty = sum(QTY) from INV
    where GDGID = @d_gdgid and STORE = @s_usergid
  if @t_qty is null select @t_qty = 0

  --处理批发价
  if @d_cls & 16 = 16
  begin
    select @whsprc = isnull(Qpcwhsprc,0) from V_QPCGOODS where gid = @d_gdgid and QpcQpcStr = @d_QpcStr
    if @optUseGdQpc = '0'
      set @updatesql = @updatesql + ' , WHSPRC = ' + cast(@d_newwhsprc as varchar(15))
    else begin
      if @QPCSTR = '1*1'
        set @updatesql = @updatesql + ' , WHSPRC = ' + cast(@d_newwhsprc as varchar(15))
      set @updatesql2 = @updatesql2 + ' , WHSPRC = ' + cast(@d_newwhsprc as varchar(15))
    end
  end

  --处理批发价
  if @d_cls & 8 = 8
  begin
    select @mbrprc = isnull(Qpcmbrprc,0) from V_QPCGOODS where gid = @d_gdgid and QpcQpcStr = @d_QpcStr
    if @optUseGdQpc = '0'
      set @updatesql = @updatesql + ' , MBRPRC = ' + cast(@d_newmbrprc as varchar(15))
    else begin
      if @QPCSTR = '1*1'
        set @updatesql = @updatesql + ' , MBRPRC = ' + cast(@d_newmbrprc as varchar(15))
      set @updatesql2 = @updatesql2 + ' , MBRPRC = ' + cast(@d_newmbrprc as varchar(15))
    end
  end

  ---处理最高售价
  if @d_cls & 4 = 4
  begin
    select @toprtlprc = isnull(QpcTOPRTLPRC,0) from V_QPCGOODS where GID = @d_gdgid and QpcQpcStr = @d_QpcStr
    if @optUseGdQpc = '0'
      set @updatesql = @updatesql + ' , TOPRTLPRC = ' + cast(@d_newtopprc as varchar(15))
    else begin
      if @QPCSTR = '1*1'
        set @updatesql = @updatesql + ' , TOPRTLPRC = ' + cast(@d_newtopprc as varchar(15))
      set @updatesql2 = @updatesql2 + ' , TOPRTLPRC = ' + cast(@d_newtopprc as varchar(15))
    end
  end

  ---处理最低售价
  if @d_cls & 2 = 2
  begin
    select @lwtrtlprc = isnull(QpcLWTRTLPRC,0) from V_QPCGOODS where GID = @d_gdgid and QpcQpcStr = @d_QpcStr
    if @optUseGdQpc = '0'
      set @updatesql = @updatesql + ', LWTRTLPRC = '+ cast(@d_newlwtprc as varchar(15))
    else begin
      if @QPCSTR = '1*1'
        set @updatesql = @updatesql + ' , LWTRTLPRC = ' + cast(@d_newlwtprc as varchar(15))
      set @updatesql2 = @updatesql2 + ' , LWTRTLPRC = ' + cast(@d_newlwtprc as varchar(15))
    end
  end

 -----处理核算售价
  if @d_cls & 1 = 1
  begin
    select @sale = SALE, @rtlprc = isnull(RTLPRC, 0),
      @payrate = isnull(PAYRATE, 75)
      from GOODS where GID = @d_gdgid
    declare c_wrh1 cursor for
      select WRH, sum(QTY), sum(TOTAL)
      from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
      group by WRH
      for read only
    open c_wrh1
    fetch next from c_wrh1 into @iwrh, @qty, @total
    while @@fetch_status = 0 begin
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_R )
        values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newrtlprc - @rtlprc)))
      update INV set TOTAL = TOTAL + convert(decimal(20, 2), @qty * (@d_newrtlprc - @rtlprc))
        where GDGID = @d_gdgid and STORE = @s_usergid and WRH = @iwrh

      -- 库存报表
      execute CRTINVRPT @s_usergid, @cur_settleno, @date, @iwrh, @d_gdgid
      update INVDRPT
        set FT = FT + convert(decimal(20, 2), @qty * (@d_newrtlprc - @rtlprc)),
        LSTUPDTIME = getdate()
        where INVDRPT.ASETTLENO = @cur_settleno and INVDRPT.ADATE = @date
        and INVDRPT.ASTORE = @s_usergid and INVDRPT.BWRH = @iwrh and INVDRPT.BGDGID = @d_gdgid
      update INVMRPT
        set FT = FT + convert(decimal(20, 2), @qty * (@d_newrtlprc - @rtlprc))
        where INVMRPT.ASETTLENO = @cur_settleno and INVMRPT.ASTORE = @s_usergid
        and INVMRPT.BWRH = @iwrh and INVMRPT.BGDGID = @d_gdgid
      update INVYRPT
        set FT = FT + convert(decimal(20, 2), @qty * (@d_newrtlprc - @rtlprc))
        where INVYRPT.ASETTLENO = @yno and INVYRPT.ASTORE = @s_usergid
        and INVYRPT.BWRH = @iwrh and INVYRPT.BGDGID = @d_gdgid

      if @sale = 3
      begin
        insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
          convert(decimal(20, 2), @qty * (@d_newrtlprc - @rtlprc) * @payrate / 100.00))
      end
      fetch next from c_wrh1 into @iwrh, @qty, @total
    end
    close c_wrh1
    deallocate c_wrh1
    if @optUseGdQpc = '0'
      set @updatesql = @updatesql + ' ,rtlprc = ' + cast(@d_newrtlprc as varchar(15))
    else begin
      if @QPCSTR = '1*1'
        set @updatesql = @updatesql + ' , rtlprc = ' + cast(@d_newrtlprc as varchar(15))
      set @updatesql2 = @updatesql2 + ' , rtlprc = ' + cast(@d_newrtlprc as varchar(15))
    end
  end
  set @updatesql = @updatesql + ' where gid = ' + cast(@d_gdgid as varchar(15))
  exec(@updatesql)
  set @updatesql2 = @updatesql2 + ' where gid = ' + cast(@d_gdgid as varchar(15)) + ' and QpcStr = ''' + RTRIM(@d_QpcStr) + ''''
  exec(@updatesql2)
  update rtlprcadjdtl set qty = @t_qty where num = @d_num and line = @d_line
  return 0
End
GO
