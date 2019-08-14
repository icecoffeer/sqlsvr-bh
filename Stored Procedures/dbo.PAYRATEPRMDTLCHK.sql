SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYRATEPRMDTLCHK](
    @p_num char(14),
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
        @optUseGdQpc char(1)

    select @s_usergid = USERGID from SYSTEM
    select @optUseGdQpc = optionvalue from hdoption where optioncaption = 'USEGDQPC' and moduleno = 0
    if @optUseGdQpc is null set @optUseGdQpc = '0'

    declare c_PayRatePrm cursor for
        select LINE, GDGID, QPC, QPCSTR from PayRatePrmDTL where NUM = @p_num
    open c_PayRatePrm
    fetch next from c_PayRatePrm into @line, @gdgid, @QPC, @QPCSTR
    while @@fetch_status = 0
    begin
        if @s_usergid = @p_storegid
        begin
          if @optUseGdQpc = '0'
            update GOODS
                set PROMOTE = 1
                where GID = @gdgid
          else
          begin
            if @QPCSTR = '1*1'
              update GOODS
                set PROMOTE = 1
                where GID = @gdgid
            update GDQPC
                set PROMOTE = 1
                where GID = @gdgid and QPCSTR = @QPCSTR
          end
        end
        else
        begin
            if @optUseGdQpc = '0'
            begin
              if not exists (select 1 from GDSTORE
                where STOREGID = @p_storegid and GDGID = @gdgid)
                insert into GDSTORE (STOREGID, GDGID, BILLTO, ALC,
                    SALE, RTLPRC, INPRC, PROMOTE, GFT,
                    LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, ISLTD)
                    select @p_storegid, GID, BILLTO, ALC,
                        SALE, RTLPRC, INPRC, PROMOTE, GFT,
                        LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, 0
                        from GOODS where GID = @gdgid
              update GDSTORE set
                PROMOTE = 1
                where STOREGID = @p_storegid and GDGID = @gdgid
            end else begin
              if @QPCSTR = '1*1'
              begin
                if not exists (select 1 from GDSTORE
                  where STOREGID = @p_storegid and GDGID = @gdgid)
                  insert into GDSTORE (STOREGID, GDGID, BILLTO, ALC,
                    SALE, RTLPRC, INPRC, PROMOTE, GFT,
                    LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, ISLTD)
                    select @p_storegid, GID, BILLTO, ALC,
                        SALE, RTLPRC, INPRC, PROMOTE, GFT,
                        LWTRTLPRC, MBRPRC, DXPRC, PAYRATE, 0
                        from GOODS where GID = @gdgid
                update GDSTORE set
                  PROMOTE = 1
                  where STOREGID = @p_storegid and GDGID = @gdgid
              end
              if not exists (select 1 from GDQPCSTORE
                where STOREGID = @p_storegid and GDGID = @gdgid and QPCSTR = @QPCSTR)
                insert into GDQPCSTORE (STOREGID, GDGID, QPCSTR, QPC,
                  RTLPRC, PROMOTE,
                  LWTRTLPRC, MBRPRC)
                  select @p_storegid, GID, @QPCSTR, @QPC,
                      RTLPRC, PROMOTE,
                      LWTRTLPRC, MBRPRC
                      from GDQPC where GID = @gdgid and QPCSTR = @QPCSTR
              update GDQPCSTORE set
                PROMOTE = 1
                where STOREGID = @p_storegid and GDGID = @gdgid and QPCSTR = @QPCSTR
            end
        end
        delete from PAYRATEPRICE where GDGID = @gdgid and STOREGID = @p_storegid and QPCSTR = @QPCSTR
        insert into PAYRATEPRICE(STOREGID, GDGID, QPC, QPCSTR, ASTART, AFINISH, PAYRATE, SRCNUM)
            select @p_storegid, @gdgid, QPC, QPCSTR, ASTART, AFINISH, PAYRATE, @p_num
            from PAYRATEPRMDTL where NUM = @p_num and LINE = @line and PayRate >= 0 --zz 090804
        fetch next from c_PayRatePrm into @line, @gdgid, @QPC, @QPCSTR
    end
    close c_PayRatePrm
    deallocate c_PayRatePrm
    return(0)
end
GO
