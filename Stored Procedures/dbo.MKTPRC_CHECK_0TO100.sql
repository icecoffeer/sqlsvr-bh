SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MKTPRC_CHECK_0TO100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RE INT,
    @StoreGid INT,
    @GdPrmPrc decimal(24, 4),
    @GdPrmInPrc decimal(24, 4),
    @GdPrmMbrPrc decimal(24, 4),
    @GdGid int,
    @QpcStr varchar(20),
    @Line int,
    @Date datetime

  declare c_PrmPrcGdgid CURSOR for
    select LINE, GDGID, GDQPCSTR from MktPrcDtl
    where NUM = @NUM

  select @StoreGid = USERGID from SYSTEM(NOLOCK);

  UPDATE MKTPRC
  SET STAT = 100, CHKDATE = GETDATE(), CHECKER = @OPER, LSTUPDTIME = GETDATE()
  WHERE NUM = @NUM

  update MktPrcDtl
  set LRTLPRC = G.QPCRTLPRC, LCNTINPRC = G.CNTINPRC, LWHSPRC = G.QPCWHSPRC,
      LMBRPRC = G.QPCMBRPRC
  from V_QPCGOODS G
  where NUM = @NUM
    and GDGID = G.GID
    and GDQPCSTR = G.QPCQPCSTR

--取促销价
  open c_PrmPrcGdgid;
  fetch next from c_PrmPrcGdgid
  into @Line, @Gdgid, @QpcStr;
  while @@Fetch_Status = 0
    begin
      select @Date = getdate();
      select @GdPrmPrc = null;
      select @GdPrmInPrc = null;
      select @GdPrmMbrPrc = null;
      EXEC @RE = GetGoodsPrmPrc @STOREGID = @StoreGid, @GDGID = @Gdgid,
    	      @adate = @Date, @qty = 1, @prmprc = @GdPrmPrc output, @QpcStr = @QpcStr
      IF @RE <> 0
      BEGIN
        SET @MSG = '取促销价失败';
      END
      EXEC @RE = GetGoodsPrmInPrc @store = @StoreGid, @GDGID = @Gdgid,
    	      @curtime = @Date, @qty = 1, @prmInprc = @GdPrmInPrc output
      IF @RE <> 0
      BEGIN
        SET @MSG = '取促销进价失败';
      END
      EXEC @RE = GetGoodsPrmMbrPrc @store = @StoreGid, @GDGID = @Gdgid,
    	      @curtime = @Date, @qty = 1, @prmmbrprc = @GdPrmMbrPrc output, @QpcStr = @QpcStr
      IF @RE <> 0
      BEGIN
        SET @MSG = '取促销会员价失败';
      END
      update MktPrcDtl
      set LPROMOTEPRICE = @GdPrmPrc, LPROMOTEINPRC = @GdPrmInPrc, LPROMOTEMBRPRC = @GdPrmMbrPrc
      where NUM = @NUM and LINE = @Line;
      fetch next from c_PrmPrcGdgid
      into @Line, @Gdgid, @QpcStr;
    end;
  close c_PrmPrcGdgid;
  deallocate c_PrmPrcGdgid;
/*, LPROMOTEPRICE = PROMOTEPRICE, LPROMOTEINPRC = G.PROMOTEINPRC,
      LPROMOTEMBRPRC = G.PROMOTEMBRPRC*/
  IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID <> ZBGID)  --门店
  BEGIN
    EXEC @RE = MKTPRC_SEND @NUM, @OPER, NULL, 0, @MSG OUTPUT
    IF @RE <> 0
    BEGIN
      SET @MSG = '单据：' + @NUM + '发送失败'
      RETURN @RE
    END
  END ELSE BEGIN
    UPDATE MKTPRCSCHEMESTOREDTL SET STAT = 1 WHERE NUM =
      (SELECT SCHEMENUM FROM MKTPRC(NOLOCK) WHERE NUM = @NUM)
      AND STOREGID = @StoreGid
      AND STAT = 0
  END

  SET @MSG = '单据：' + @NUM + '审核成功' + CHAR(10) + CHAR(13) + @MSG

  RETURN 0
END
GO
