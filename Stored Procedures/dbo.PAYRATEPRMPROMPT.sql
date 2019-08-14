SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYRATEPRMPROMPT](
  @p_num varchar(14),
  @p_title varchar(200),
  @p_Event varchar(100)
)as
begin
  declare @xml_num varchar(200),
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
  execute PFA_SERIALIZEXML_SETSTRING 'NUM', @p_num, @xml_num output
  set @xml_map_dict=@xml_num

  --模块参数    
  select @usercode=CHECKER from PAYRATEPRM where NUM=@p_num  
  execute PFA_GET_OPERINFO_BYFILLER @usercode, @usergid output, @usercode output, @username output
  set @xml_title = @p_title
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 684, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'HD3Basic.bpl', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPayRatePrm', @xml_procName output
  execute PFA_SERIALIZEXML_SETSTRING 'params', @p_num, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  set @applydate = getdate()
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_PayRatePrm', @p_event, @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end
GO
