SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PIVC_NEXTCODE2]  
  @PICODE VARCHAR(15),  
  @POCODE VARCHAR(15) OUTPUT  
 AS  
begin  
  declare   
    @LEN    INT,  
    @I      INT,  
    @CARRY  INT,  
    @CURBIT CHAR(1),  
    @CODE   VARCHAR(15)  
  set @CODE = RTRIM(@PICODE)  
  set @CODE = REVERSE(@CODE)  
  set @LEN = LEN(@CODE)  
  set @I = 1  
  set @CARRY = 1 --是否进位  
  WHILE @CARRY = 1 AND @I <= @LEN  
  begin  
    set @CURBIT = SUBSTRING(@CODE, @I, 1)  
    IF @CURBIT ='9'  
      set @CODE = STUFF(@CODE, @I, 1, '0')  
    ELSE  
    begin  
      set @CODE = STUFF(@CODE, @I, 1, CHAR(ASCII(SUBSTRING(@CODE, @I, 1)) + 1))  
      set @CARRY = 0  
    end  
    set @I = @I + 1  
  end  
  set @POCODE = REVERSE(@CODE)  
  RETURN 0;  
end  
GO
