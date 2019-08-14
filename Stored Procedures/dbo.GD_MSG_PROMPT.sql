SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GD_MSG_PROMPT](
  @p_gid int,
  @p_usergid int,
  @p_title varchar(200),
  @p_Event varchar(100)
)as
begin
  declare @code varchar(13),
          @name varchar(50)
  declare @xml_gid varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200),
          @applydate datetime
  declare @xml_map_dict varchar(2100),
          @xml_map_prompt varchar(2100)
  declare @usercode varchar(10),
          @username varchar(20)
  declare @return varchar(255)

  --提取商品信息
  select @code=RTRIM(CODE), @name=RTRIM(Name) from GOODS where GID=@p_gid

  --触发的数据字典dict
  execute PFA_SERIALIZEXML_SETINTEGER 'GID', @p_gid, @xml_gid output
  set @xml_map_dict=@xml_gid

  --模块参数    
  execute PFA_GET_OPERINFO_BYGID @p_usergid output, @usercode output, @username output
  set @xml_title = @p_title
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 10, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowGood', @xml_procName output
  set @xml_params = Convert(varchar, @p_gid)
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  set @applydate = getdate()
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_GOODS', @p_event, @xml_map_dict, @xml_map_prompt, @applydate, @p_usergid, @usercode, @username, @return output
end
GO
