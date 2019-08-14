SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_To800_Eon0]
(
  @cur_date datetime,
  @cur_settleno int,
  @p_cls int,
  @p_num varchar(14),
  @d_line smallint,
  @d_gdgid int,
  @d_QpcStr varchar(15),
  @d_newrtlprc money,
  @d_newlwtprc money,
  @d_newtopprc money,
  @d_newmbrprc money,
  @msg varchar(255) output
)
With Encryption
as
begin
  declare
    @ret int,
    @d_storegid int,
    @storename varchar(80),
    @qty money,
    @topprc money,
    @lwtprc money,
    @rtlprc money,
    @oldrtlprc money,
    @sale smallint,
    @payrate money,
    @date datetime,
    @yno int,
    @tmp int,
    @optUseGdQpc char(1)

  select @ret = 0
  select @date = convert(datetime, convert(char, @cur_date, 102))
  select @yno = yno from v_ym where mno = @cur_settleno
  select @optUseGdQpc = optionvalue from hdoption where optioncaption = 'USEGDQPC' and moduleno = 0
  if @optUseGdQpc is null set @optUseGdQpc = '0'

  declare c_lac1 cursor for
    select STOREGID from rtlprcadjlacdtl
    where NUM = @p_num
    for read only
  open c_lac1
  fetch next from c_lac1 into @d_storegid
  while @@fetch_status = 0
  begin
    select @qty = sum(QTY) from INV
      where STORE = @d_storegid and WRH = 1 and GDGID = @d_gdgid
    if @qty is null select @qty = 0

    if @optUseGdQpc = '0'
    begin
      if exists(select 1 from GDSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid)
      begin
        select @topprc = isnull(TOPRTLPRC, 900000000000000) from GDSTORE(nolock)
          where STOREGID = @d_storegid and GDGID = @d_gdgid
        select @lwtprc = isnull(LWTRTLPRC, -900000000000000) from GDSTORE(nolock)
          where STOREGID = @d_storegid and GDGID = @d_gdgid
        select @rtlprc = isnull(RTLPRC, 0) from GDSTORE(nolock)
          where STOREGID = @d_storegid and GDGID = @d_gdgid
        set @tmp = 0
      end
      else
      begin
        select @topprc = isnull(TOPRTLPRC, 900000000000000) from GOODS(nolock) where GID = @d_gdgid
        select @lwtprc = isnull(LWTRTLPRC, -900000000000000) from GOODS(nolock) where GID = @d_gdgid
        select @rtlprc = rtlprc from goods(nolock) where gid = @d_gdgid
        set @tmp = 1
      end
    end
    else begin
      if exists(select 1 from GDQPCSTORE where STOREGID = @d_storegid and GDGID = @d_gdgid and QpcStr = @d_QpcStr)
      begin
        select @topprc = isnull(TOPRTLPRC, 900000000000000) from GDQPCSTORE(nolock)
          where STOREGID = @d_storegid and GDGID = @d_gdgid and QpcStr = @d_QpcStr
        select @lwtprc = isnull(LWTRTLPRC, -900000000000000) from GDQPCSTORE(nolock)
          where STOREGID = @d_storegid and GDGID = @d_gdgid and QpcStr = @d_QpcStr
        select @rtlprc = isnull(RTLPRC, 0) from GDQPCSTORE(nolock)
          where STOREGID = @d_storegid and GDGID = @d_gdgid and QpcStr = @d_QpcStr
        set @tmp = 0
      end
      else
      begin
        select @topprc = isnull(TOPRTLPRC, 900000000000000) from GDQPC(nolock) where GID = @d_gdgid and QpcStr = @d_QpcStr
        select @lwtprc = isnull(LWTRTLPRC, -900000000000000) from GDQPC(nolock) where GID = @d_gdgid and QpcStr = @d_QpcStr
        select @rtlprc = rtlprc from GDQPC(nolock) where gid = @d_gdgid and QpcStr = @d_QpcStr
        set @tmp = 1
      end
    end
    if @p_cls & 4 = 4 set @topprc = @d_newtopprc
    if @p_cls & 2 = 2 set @lwtprc = @d_newlwtprc
    if @p_cls & 1 = 1
    begin
      set @oldrtlprc = @rtlprc
      set @rtlprc = @d_newrtlprc
    end

    if @rtlprc < @lwtprc
    begin
      select @storename = name from store(nolock) where gid = @d_storegid
      set @msg = '第' + convert(varchar(5), @d_line) +
        '行核算售价低于门店' + @storename + '的最低售价'
      set @ret = 1
      break
    end
    if @rtlprc > @topprc
    begin
      select @storename = name from store(nolock) where gid = @d_storegid
      set @msg = '第' + convert(varchar(5), @d_line) +
        '行核算售价高于门店' + @storename + '的最高售价'
      set @ret = 1
      break
    end
    if @topprc = 900000000000000 set @topprc = null
    if @lwtprc = -900000000000000 set @lwtprc = null
    if @optUseGdQpc = '0'
    begin
      if @tmp = 1
        insert into GDSTORE (STOREGID, GDGID, BILLTO, SALE, ALC, RTLPRC,
          INPRC, PROMOTE, GFT,LWTRTLPRC,TOPRTLPRC, MBRPRC, DXPRC, PAYRATE, CNTINPRC)
          select @d_storegid, GID, BILLTO, SALE, ALC, @rtlprc,
          INPRC, PROMOTE, GFT, @lwtprc, @topprc ,@d_newmbrprc, DXPRC, PAYRATE, CNTINPRC
          from GOODS where GID = @d_gdgid
      else if @tmp = 0
        update GDSTORE SET LWTRTLPRC = @lwtprc,TOPRTLPRC = @topprc, RTLPRC = @rtlprc,
          MBRPRC = isnull(@d_newmbrprc, MBRPRC) where storegid = @d_storegid
          and gdgid= @d_gdgid
    end
    else begin
      if @tmp = 1
        insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, RTLPRC,
          PROMOTE, LWTRTLPRC, TOPRTLPRC, MBRPRC)
          select @d_storegid, GID, QpcStr, @rtlprc,
          PROMOTE, @lwtprc, @topprc ,@d_newmbrprc
          from GDQPC where GID = @d_gdgid and QpcStr = @d_QpcStr
      else if @tmp = 0
        update GDQPCSTORE SET LWTRTLPRC = @lwtprc, TOPRTLPRC = @topprc, RTLPRC = @rtlprc,
          MBRPRC = isnull(@d_newmbrprc, MBRPRC) where storegid = @d_storegid
          and gdgid= @d_gdgid and QpcStr = @d_QpcStr
    end

    if @p_cls & 1 = 1
    begin
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_R )
        values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newrtlprc - @oldrtlprc)))
      if @sale = 3
        insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@cur_date, @cur_settleno, @d_storegid, @d_gdgid, @qty,
          convert(decimal(20, 2), @qty * (@d_newrtlprc - @oldrtlprc) * @payrate / 100.00))
    end
    fetch next from c_lac1 into @d_storegid
  end
  close c_lac1
  deallocate c_lac1
  return(@ret)
end
GO
