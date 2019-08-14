SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[zhfn_DeCodeBar](
  @piBarCode varchar(50),
  @poPosno varchar(10) output,
  @poFlowno varchar(12) output,
  @poErrMsg varchar(255) output
) 
as 
begin     
  declare  
    @vBarCodeLen int,  
    @vSum int,  
    @VI int,  
    @VJ int,
    @VK int,   
    @vTmp char(1),       
    @vBarCodeStr VARCHAR(50),  
    @vUserCode varchar(10) 
    
  set @poPosno = ''
  set @poFlowno = ''
  
  select @vUserCode = a.UserCode from system a(nolock)
      
  if not exists (select 1 from system(nolock) 
    where UserCode in ('0021','0104','0105','0106','0107','0108','0111','0112','0113','0114','0116','0117','0118','0119','0120','0121',
                       '0122','0123','0124','0125','0127','0128','0129','0130','0131','0132','0134','0135','0136','0137','0138','0139',
                       '0140','0141','0142','0143','0144','0145','0146','0147','0148','0205','0401'))  
  begin   
    set @vBarCodeStr = @piBarCode  
    set @vBarCodeLen = len(@vBarCodeStr)  
    
    --提取码的构造: 商户简码(4位) + 订单类型(2位) + 单号(19位)
    --商户简码和订单类型, 不足位数, 前面补0
    --单号构造(不足位数, 前面补0): 门店号(4位) + pos机号(3位) + 流水(12位) = 19位
    --故提取码长度应为25位
    if @vBarCodeLen <> 25
    begin
      set @poErrMsg = '提取码长度不对';
      return(1)
    end
    
    set @VK = 6  
    while @VK < (@vBarCodeLen + 1) / 2    
    begin    
      set @vTmp = SUBSTRING(@vBarCodeStr, @VK, 1)  
      set @VI = @vBarCodeLen - (@VK - 4)    
      set @vBarCodeStr = SUBSTRING(@vBarCodeStr, 1, @VK - 1) + SUBSTRING(@vBarCodeStr, @VI, 1) + SUBSTRING(@vBarCodeStr, @VK + 1, @VI - @VK - 1) + @vTmp 
                   + SUBSTRING(@vBarCodeStr, @VI + 1, @vBarCodeLen - @VI)    
      set @VK = @VK + 1     
    end    
    
    set @vBarCodeLen = len(@vBarCodeStr)  
    set @vSum = 0  
     
    while @vBarCodeLen <> 0   
    begin 
      set @vSum = @vSum + CAST(SUBSTRING(@vBarCodeStr, @vBarCodeLen, 1) as INTEGER)   
      set @vBarCodeLen = @vBarCodeLen - 1    
    end    
    
    set @vBarCodeLen = len(@vBarCodeStr)   
    set @VI = @vSum % 15 + 1  
    set @VJ = @vSum % 10 + 1 
    
    set @vTmp = SUBSTRING(@vBarCodeStr, @VJ, 1)  
    set @vBarCodeStr = SUBSTRING(@vBarCodeStr, 1, @VJ - 1) + SUBSTRING(@vBarCodeStr, @vBarCodeLen - 1, 1) + SUBSTRING(@vBarCodeStr, @VJ + 1, @vBarCodeLen - @VJ - 2) + @vTmp 
                 + SUBSTRING(@vBarCodeStr, @vBarCodeLen, 1)   
    set @vTmp = SUBSTRING(@vBarCodeStr, @VI, 1)  
    set @vBarCodeStr = SUBSTRING(@vBarCodeStr, 1, @VI - 1) + SUBSTRING(@vBarCodeStr, @vBarCodeLen, 1) + SUBSTRING(@vBarCodeStr, @VI + 1, @vBarCodeLen - @VI - 1) + @vTmp 
    
    set @poPosno = SUBSTRING(@vBarCodeStr, 11, 3)
    set @poFlowno = SUBSTRING(@vBarCodeStr, 14, 12)
  end 
  else
  begin
    set @poErrMsg = 'UserCode: ' + @vUserCode + ' 不允许操作解析提取码';
    return(1)
  end
    
  return 0
end 
GO
