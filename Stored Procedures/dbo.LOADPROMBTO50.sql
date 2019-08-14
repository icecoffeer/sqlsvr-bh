SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LOADPROMBTO50]
(
	@PICLS	  VARCHAR(10),
	@PINUM	  VARCHAR(14),
	@PIOPER	  VARCHAR(30),	
	@POERR_MSG VARCHAR(255) OUTPUT
) 
AS
BEGIN
  declare
	@VRET 		INT,
	@VASTART 	DATETIME,
	@VAFINISH 	DATETIME,
	@VCYCLE		DATETIME,
	@VCSTART	DATETIME,
	@VCFINISH	DATETIME,
	@VCSPEC		VARCHAR(255),
	@VPSETTLENO     INT,
	@StoreGid       int,
	@line           int,
	@GdGid          int,
	@GdCode         char(13),
	@vDltPriceProm  smallint ---是否取消原价格促销
	
	
  SELECT @VASTART = ASTART, @VAFINISH = AFINISH, @VCYCLE = CYCLE, 
    @VCSTART = CSTART, @VCFINISH = CFINISH, @VCSPEC = CSPEC, 
    @VPSETTLENO = PSETTLENO, @vDltPriceProm = DltPriceProm
  FROM PROMB WHERE NUM = @PINUM
  
  if @@rowcount = 0
  begin
    set @poErr_Msg = '指定单号：' + @piNum + ' 数据不存在'
    return(1)
  end

    
  INSERT INTO PRICEBDIS(BILLNUM, QTY, RTLPRC)
	  SELECT NUM, QTY, RTLPRC FROM PROMBDIS
	  WHERE NUM = @PINUM	
  declare SDTL cursor for
	  SELECT STOREGID FROM PROMBSTORE 
	  WHERE NUM = @PINUM;    
  declare CDTL cursor for
	  SELECT LINE,GDGID,GDCODE FROM PROMBGOODS
	  WHERE NUM = @PINUM
  open CDTL
  fetch next from CDTL into @line, @gdgid, @gdcode
  while @@fetch_status = 0
  begin
	  set @VRET = 0
	  open SDTL	
	  fetch next from SDTL into @StoreGid
	  while @@fetch_status = 0
	  begin
	    EXEC @VRET = LOADPROMBDTLTO50 @PICLS, @PINUM, @StoreGid, @VPSETTLENO,
		                 @VASTART,@VAFINISH,@VCYCLE,@VCSTART,@VCFINISH,@VCSPEC,
			               @line, @gdgid, @gdcode, @POERR_MSG
	    IF @VRET <> 0 RETURN(@VRET)
	    if @vDltPriceProm = 1 
	    begin
	      exec @vRet = DLTONEGOODSPRCPROM @GDGid, @StoreGid, @vAStart, @vAFinish, @poErr_Msg
        if @vRet <> 0 
          return(@vRet)
	    end 
	    fetch next from SDTL into @StoreGid 
	  end
	  close SDTL
	  fetch next from CDTL into @line, @gdgid, @gdcode	
  end
  CLOSE CDTL
  DEALLOCATE CDTL
  DEALLOCATE SDTL
END
GO
