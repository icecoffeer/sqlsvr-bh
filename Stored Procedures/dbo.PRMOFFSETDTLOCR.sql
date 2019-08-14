SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETDTLOCR]
(
    @num char(14),
    @storegid int
) as
begin
    declare
        @s_usergid int,
        @line smallint,
        @gdgid int,
        @vdrgid int,
        @QPC money,
        @QPCSTR char(15),
        @optUseGdQpc char(1)

    select @s_usergid = USERGID from SYSTEM;
    select @optUseGdQpc = optionvalue from hdoption where optioncaption = 'USEGDQPC' and moduleno = 0;
    if @optUseGdQpc is null set @optUseGdQpc = '0';

    select @vdrgid = VDRGID from PRMOFFSET(nolock) where NUM= @num;

    declare c_prmoffset cursor for
        select LINE, GDGID, QPC, QPCSTR from PRMOFFSETDTL where NUM = @num;
    open c_prmoffset
    fetch next from c_prmoffset into @line, @gdgid, @QPC, @QPCSTR
    while @@fetch_status = 0
      begin
      --若GDSTORE表中不存在此商品，则插入GDSTORE表
        if @optUseGdQpc = '0'
          begin
            if not exists (select 1 from GDSTORE
                where STOREGID = @storegid and GDGID = @gdgid)
                insert into GDSTORE (STOREGID, GDGID, BILLTO, ALC, SALE, RTLPRC, INPRC, PROMOTE, GFT,
                    LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, ISLTD, CNTINPRC)
                select @storegid, GID, BILLTO, ALC, SALE, RTLPRC, INPRC, PROMOTE, GFT, LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, 0, CNTINPRC
                from GOODS where GID = @gdgid
          end else begin
            if @QPCSTR = '1*1'
              begin
                if not exists (select 1 from GDSTORE
                  where STOREGID = @storegid and GDGID = @gdgid)
                  insert into GDSTORE (STOREGID, GDGID, BILLTO, ALC, SALE, PROMOTE, GFT, RTLPRC, INPRC,
                    LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, ISLTD, CNTINPRC)
                  select @storegid, GID, BILLTO, ALC, SALE, PROMOTE, GFT, RTLPRC, INPRC,
                    LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, 0, CNTINPRC
                  from GOODS where GID = @gdgid
              end
            if not exists (select 1 from GDQPCSTORE
                where STOREGID = @storegid and GDGID = @gdgid and QPCSTR = @QPCSTR)
                insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC, RTLPRC, PROMOTE, LWTRTLPRC, MBRPRC)
                  select @storegid, GID, @QPCSTR, @QPC, RTLPRC, PROMOTE, LWTRTLPRC, MBRPRC
                from GDQPC where GID = @gdgid and QPCSTR = @QPCSTR
          end
        update PRMOFFSETDTL
        set CNTINPRC = GOODS.CNTINPRC
        from GOODS
        where NUM = @num
          and LINE = @line
          and gdgid = GOODS.GID;
        delete from PRMOFFSETEFFECT where VDRGID = @vdrgid and GDGID = @gdgid and STOREGID = @storegid and QPCSTR = @QPCSTR;
        insert into PRMOFFSETEFFECT(STOREGID, VDRGID, GDGID, QPC, QPCSTR, OFFSETPRC, CNTINPRC, QTY, START, FINISH, Alc, Total, Tax, Amount, DiffPrc, OffsetType, OffsetCalcType)
            select @storegid, @vdrgid, @gdgid, QPC, QPCSTR, OFFSETPRC, CNTINPRC, QTY, START, FINISH, Alc, d.Total, d.Tax, d.Amount, d.DiffPrc, m.OffsetType, m.OffsetCalcType
            from PRMOFFSETDTL d, PrmOffset m where d.NUM = @num and d.LINE = @line AND m.Num = d.Num
        fetch next from c_prmoffset into @line, @gdgid, @QPC, @QPCSTR
      end
    close c_prmoffset
    deallocate c_prmoffset
    return(0)
end
GO
