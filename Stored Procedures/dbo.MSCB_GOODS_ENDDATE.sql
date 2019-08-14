SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_GOODS_ENDDATE](  
  @p_gid int,  
  @p_type varchar(4),  
  @p_days int  
) as  
begin  
  declare @code varchar(13),  
          @name varchar(50)  
  declare @xml_gid varchar(200),  
          @xml_title varchar(200),  
          @xml_moduleNo varchar(200),  
          @xml_pkgName varchar(200),  
          @xml_procName varchar(200),  
          @xml_params varchar(200),  
          @xml_days varchar(200),  
          @applydate datetime  
  declare @xml_map_dict varchar(2100),  
          @xml_map_prompt varchar(2100)  
  declare @usergid int,  
          @usercode varchar(10),  
          @username varchar(20),  
          @event varchar(100)  
  declare @return varchar(255),  
          @days int  
  
  --提取商品信息  
  select @code=RTRIM(CODE), @name=RTRIM(Name) from GOODS where GID=@p_gid  
  
  --触发的数据字典dict  
  execute PFA_SERIALIZEXML_SETINTEGER 'GID', @p_gid, @xml_gid output  
  execute PFA_SERIALIZEXML_SETINTEGER 'days', @p_days, @xml_days output   
  set @xml_map_dict=@xml_gid + @xml_days  
  
  --模块参数      
  execute PFA_GET_OPERINFO_BYFILLER '-', @usergid output, @usercode output, @username output  
  set @xml_title = '商品[' + @name + '-' + @code + ']' + @p_type + '促销期'  
  set @days = -@p_days  
  if (@p_days > 0)  
    set @xml_title = @xml_title + '已经过了'+ convert(varchar, @p_days) + '天了。'  
  else if (@p_days < 0)    
    set @xml_title = @xml_title + '还有'+ convert(varchar, @days) + '天结束。'  
  else  
    set @xml_title = @xml_title + '今天结束'    
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output  
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 10, @xml_moduleNo output  
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output  
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowGood', @xml_procName output  
  set @xml_params = Convert(varchar, @p_gid)  
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output  
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params  
  
  --插入触发记录  
  set @applydate = getdate()  
  set @event = '商品' + @p_type + '促销到期提醒'  
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_GOODS', @event, @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output  
end  

GO
