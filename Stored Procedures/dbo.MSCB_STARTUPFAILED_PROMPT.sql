SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MSCB_STARTUPFAILED_PROMPT](
  @p_title varchar(400)
) as
begin
  declare @xml_gid varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200),
          @applydate datetime
  declare @xml_map_dict varchar(2100),
          @xml_map_prompt varchar(2100)
  declare @usergid int,
          @usercode varchar(10),
          @username varchar(20)
  declare @return varchar(255)
                 
  --触发的数据字典dict      
  set @xml_map_dict=''
                 
  --模块参数     
  set @usercode = '-'
  execute PFA_GET_OPERINFO_BYFILLER @usercode, @usergid output, @usercode output, @username output
  set @xml_title = @p_title
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 0, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'ShowLogByEmpCode', @xml_procName output
  set @xml_params = 'STARTUP'
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params
                 
  --插入触发记录 
  set @applydate = getdate()
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_SystemMscb', '日结转处理失败提醒', @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end;
GO
