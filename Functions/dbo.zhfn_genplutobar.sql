SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[zhfn_genplutobar](
  @posno varchar(10),
  @flowno varchar(12)
)  
 returns varchar(50)  
begin     
  declare  
    @VSL int,  
    @VSUM int,  
    @VI int,  
    @VJ int,  
    @VTMP char(1),  
    @VK INT,  
    @VSTRING VARCHAR(50),  
    @storecode varchar(4)  
   
  if not exists (select 1 from system(nolock) 
    where usercode in ('0021','0104','0105','0106','0107','0108','0111','0112','0113','0114','0116','0117','0118','0119','0120','0121',
                       '0122','0123','0124','0125','0127','0128','0129','0130','0131','0132','0134','0135','0136','0137','0138','0139',
                       '0140','0141','0142','0143','0144','0145','0146','0147','0148','0205','0401'))  
  begin  
    select @VSTRING = case len(a.usercode) when 2 then '00008800' + rtrim(a.usercode) + rtrim(@posno) + rtrim(@flowno) 
                                                  else '000088' + rtrim(a.usercode) + rtrim(@posno) + rtrim(@flowno) 
                      end 
    from system a(nolock)  
     
    set @VSL = len(@VSTRING)  
    set @VSUM = 0  
     
    while @VSL <> 0   
    begin 
      set @VSUM = @VSUM + CAST(SUBSTRING(@VSTRING, @VSL, 1) as INTEGER)   
      set @VSL = @VSL - 1    
    end      
              
    set @VSL = len(@VSTRING)   
    set @VI = @VSUM % 15 + 1  
    set @VJ = @VSUM % 10 + 1     
     
    set @VTMP = SUBSTRING(@VSTRING, @VI, 1)  
    set @VSTRING = SUBSTRING(@VSTRING, 1, @VI - 1) + SUBSTRING(@VSTRING, @VSL, 1) + SUBSTRING(@VSTRING, @VI + 1, @VSL - @VI - 1) + @VTMP  
    set @VTMP = SUBSTRING(@VSTRING, @VJ, 1)  
    set @VSTRING = SUBSTRING(@VSTRING, 1, @VJ - 1) + SUBSTRING(@VSTRING, @VSL - 1, 1) + SUBSTRING(@VSTRING, @VJ + 1, @VSL - @VJ - 2) + @VTMP 
                 + SUBSTRING(@VSTRING, @VSL, 1)  
     
    set @VSL = len(@VSTRING)  
    set @VK = 6  
    while @VK < (@VSL + 1) / 2    
    begin    
      set @VTMP = SUBSTRING(@VSTRING, @VK, 1)  
      set @VI = @VSL - (@VK - 4)    
      set @VSTRING = SUBSTRING(@VSTRING, 1, @VK - 1) + SUBSTRING(@VSTRING, @VI, 1) + SUBSTRING(@VSTRING, @VK + 1, @VI - @VK - 1) + @VTMP 
                   + SUBSTRING(@VSTRING, @VI + 1, @VSL - @VI)    
      set @VK = @VK + 1     
    end    
  end  
  else   
    set @VSTRING  = '-'  
     
  return @VSTRING   
end  
GO
