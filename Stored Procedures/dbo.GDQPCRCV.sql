SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GDQPCRCV](
	@p_teamid	int,
	@p_n_gid int
) as
begin
    declare
      @l_gid int,
      @n_frcupd smallint,
      @QPCSTR varchar(20),
      @QPC decimal(24, 4),
      @MUNIT varchar(6),
      @VOL varchar(20),
      @WEIGHT varchar(10),
      @ISDU smallint,
      @ISPU smallint,
      @ISWU smallint,
      @ISRU smallint,
      @RTLPRC decimal(24, 4),
      @WHSPRC decimal(24, 4),
      @MBRPRC decimal(24, 4),
      @LWTRTLPRC decimal(24, 4),
      @TOPRTLPRC decimal(24, 4),
      @BQTYPRC varchar(100),
      @PROMOTE smallint
    select
        @n_frcupd = FrcUpd
    from NGDQPC
    where TEAMID = @p_teamid

    select @l_gid = LGid
        from GDXLATE
    where NGid = @p_n_gid

    if @n_frcupd = 0
      return 0

    if @l_gid is null
    begin
        raiserror('该商品本地不存在。', 16, 1)
        return(1)
    end
    declare C_QpcStr cursor for
      select QPCSTR, QPC, MUNIT, VOL, WEIGHT, ISDU, ISPU, ISWU, ISRU, RTLPRC, WHSPRC,
             MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE
      from NGDQPC where TEAMID = @p_teamid and GID = @p_n_gid  --ShenMin
    open C_QpcStr
    fetch next from C_QpcStr into @QpcStr, @QPC, @MUNIT, @VOL, @WEIGHT, @ISDU, @ISPU, @ISWU, @ISRU,
                                  @RTLPRC, @WHSPRC, @MBRPRC, @LWTRTLPRC, @TOPRTLPRC, @BQTYPRC, @PROMOTE
    while @@fetch_status = 0
      begin
   -- delete from GDQPC where GID = @l_gid
        if not exists (select 1 from GDQPC where GID = @l_gid and QPCSTR = @QpcStr)
          begin
            insert into GDQPC(GID, QPCSTR, QPC, MUNIT, VOL, WEIGHT, ISDU, ISPU, ISWU, ISRU, RTLPRC, WHSPRC,
                              MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE)
            VALUES(@l_gid, @QpcStr, @QPC, @MUNIT, @VOL, @WEIGHT, @ISDU, @ISPU, @ISWU, @ISRU,@RTLPRC, @WHSPRC,
                              @MBRPRC, @LWTRTLPRC, @TOPRTLPRC, @BQTYPRC, @PROMOTE )
          end
        else
        	begin
            update GDQPC
            set QPC = @QPC, MUNIT = @MUNIT, VOL = @VOL, WEIGHT = @WEIGHT,
                ISDU = @ISDU, ISPU = @ISPU, ISWU = @ISWU, ISRU = @ISRU, PROMOTE = @PROMOTE
            where  GID = @l_gid and QPCSTR = @QpcStr
        	end
        fetch next from C_QpcStr into @QpcStr, @QPC, @MUNIT, @VOL, @WEIGHT, @ISDU, @ISPU, @ISWU, @ISRU,
                                      @RTLPRC, @WHSPRC, @MBRPRC, @LWTRTLPRC, @TOPRTLPRC, @BQTYPRC, @PROMOTE
      end
    close C_QpcStr
    deallocate C_QpcStr
    return 0
end
GO
