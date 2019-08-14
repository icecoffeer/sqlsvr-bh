SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_CNTR_ON_SETTLEDAY_TRIGGER](  
  @p_num varchar(14),  
  @p_version int,  
  @p_vendor int,    
  @p_days int  
) as  
begin  
  declare @xml_gid varchar(200),         
          @xml_title varchar(200),       
          @xml_moduleNo varchar(200),    
          @xml_pkgName varchar(200),     
          @xml_procName varchar(200),    
          @xml_params varchar(200),     
          @xml_dict varchar(200),  
          @applydate datetime            
  declare @xml_map_dict varchar(2100),   
          @xml_map_prompt varchar(2100)  
  declare @usergid int,                  
          @usercode varchar(10),         
          @username varchar(20),  
          @vendorcode varchar(10),  
          @vendorname varchar(50)  
  declare @days int,  
          @spchar varchar(10),  
          @return varchar(255)           
                                         
  --触发的数据字典dict   
  set @xml_map_dict=''  
  execute PFA_SERIALIZEXML_SETSTRING 'NUM', @p_num, @xml_dict output  
  set @xml_map_dict= @xml_map_dict + @xml_dict  
  execute PFA_SERIALIZEXML_SETINTEGER 'VERSION', @p_version, @xml_dict output  
  set @xml_map_dict= @xml_map_dict + @xml_dict                  
  execute PFA_SERIALIZEXML_SETINTEGER 'GID', @p_vendor, @xml_dict output  
  set @xml_map_dict= @xml_map_dict + @xml_dict  
  -- 如果日子为负数，也就是过期前  
  execute PFA_SERIALIZEXML_SETINTEGER 'ASettleDate', @p_days, @xml_dict output  
  set @xml_map_dict= @xml_map_dict + @xml_dict  
                                         
  --模块参数                             
  set @usercode = '-' --取未知用户       
  execute PFA_GET_OPERINFO_BYFILLER @usercode, @usergid output, @usercode output, @username output  
  select @vendorcode=RTRIM(code), @vendorname=RTRIM(name) from vendor where GID=@p_vendor  
  set @days = -@p_days  
  if (@p_days > 0)  
    set @xml_title = '供应商[' + @vendorname + '-' + @vendorcode + ']合约已经过期'+ convert(varchar, @p_days) + '天了。'  
  else if (@p_days < 0)    
    set @xml_title = '供应商[' + @vendorname + '-' + @vendorcode + ']合约离到期还有'+ convert(varchar, @days) + '天。'  
  else  
    set @xml_title = '供应商[' + @vendorname + '-' + @vendorcode + ']合约今天到期了'  
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output  
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 3004, @xml_moduleNo output  
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'AcntPay.bpl', @xml_pkgName output    
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowCntr', @xml_procName output  
  execute PFA_GET_SPCHAR @spchar output  --取通用分割符  
  set @xml_params = @p_num + @spchar + convert(varchar, @p_version)  
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output  
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params   
                                                                                                  
  --插入触发记录                                                                                  
  set @applydate = getdate()                                                                      
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_VENDOR', '供应商合约到期提醒', @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output  
end  

GO
