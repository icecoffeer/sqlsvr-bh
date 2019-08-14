SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[PIVC_GENNEXTNUM] (
    @piTable VARCHAR(60),
    @piStore VARCHAR(6),
    @piLen INT,
    @poNum VARCHAR(10) output,
    @poErrMsg VARCHAR(255) OUTPUT
  )
  AS
  begin
    DECLARE   
      @V_CMD  VARCHAR(255),
      @VNum VARCHAR(10) 
      
      set @V_CMD = 'DECLARE Ivc_GENNEXTNum CURSOR FOR SELECT MAX(Rtrim(NUM)) FROM '+ @piTable
             + ' where NUM LIKE ' + '''' + @piStore + '%' + '''' 
             + ' and LEN(NUM) = ' + cast(@piLen as VARCHAR(2))
      EXEC (@V_CMD)  
      open Ivc_GENNEXTNum
       FETCH NEXT FROM Ivc_GENNEXTNum INTO @VNum
     IF @@FETCH_STATUS = 0 and @VNum is not NULL
     begin 
       set @VNum = SUBSTRING(@VNum + '0000000000', 1, @piLen)
     end
     else
     begin
         set @VNum = SUBSTRING(@piStore + '0000000000', 1, @piLen)
     end
    Close Ivc_GENNEXTNum
    DEALLOCATE Ivc_GENNEXTNum 
    EXEC PIVC_NEXTCODE @VNum, @poNum output
  if LEN(@poNum) > @piLen
  begin
    set @poErrMsg = '超过单据号最大值.'
    return 1
  end
  else
    return 0   
  end
GO
