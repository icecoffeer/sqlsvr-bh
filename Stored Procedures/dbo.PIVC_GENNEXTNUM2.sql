SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PIVC_GENNEXTNUM2]  
(  
  @piTable VARCHAR(60),  
  @piStore VARCHAR(6),  
  @piLen INT,  
  @poNum VARCHAR(15) output,  
  @poErrMsg VARCHAR(255) OUTPUT  
) AS  
begin  
  DECLARE  
    @V_CMD     VARCHAR(255),  
    @VNum      VARCHAR(15),  
    @V_YYMMDD  VARCHAR(8)  
  
  SET @V_YYMMDD = CONVERT(VARCHAR(8), GETDATE(), 112)  
  set @V_CMD = 'DECLARE IVC_GENNEXTNUM2 CURSOR FOR SELECT MAX(Rtrim(NUM)) FROM '+ @piTable  
    + ' where NUM LIKE ' + '''' + @piStore + @V_YYMMDD + '%' + ''''  
    + ' and LEN(NUM) = ' + cast(@piLen as VARCHAR(2))  
  EXEC (@V_CMD)  
  open IVC_GENNEXTNUM2  
  FETCH NEXT FROM IVC_GENNEXTNUM2 INTO @VNum  
  IF @@FETCH_STATUS = 0  
  begin  
    IF @VNum IS NULL OR SUBSTRING(@VNum, Len(@piStore) + 1, 8) <> @V_YYMMDD  
      set @VNum = SUBSTRING(@piStore + @V_YYMMDD + '000000000000000', 1, @piLen)  
  end  
  else  
  begin  
    set @VNum = SUBSTRING(@piStore + @V_YYMMDD + '000000000000000', 1, @piLen)  
  end  
  Close IVC_GENNEXTNUM2  
  DEALLOCATE IVC_GENNEXTNUM2  
  EXEC PIVC_NEXTCODE2 @VNum, @poNum output  
  if LEN(@poNum) > @piLen  
  begin  
    set @poErrMsg = '超过单据号最大值.'  
    return 1  
  end  
  else  
    return 0  
end  
GO
