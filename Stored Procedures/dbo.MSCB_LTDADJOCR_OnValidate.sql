SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[MSCB_LTDADJOCR_OnValidate](
  @p_num varchar(14),
  @p_userid int
) as
begin
  declare @applydate datetime
  declare @xml_num varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200)
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
  set @usergid = @p_userid
  set @applydate = getdate()
  execute PFA_GET_OPERINFO_BYGID @usergid output, @usercode output, @Username output
  set @xml_title = '限制业务调整单[' + @p_num + ']在' + Convert(varchar, @applydate, 20) + '生效了。'
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 510, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'HD3Basic.Bpl', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowLtdAdj', @xml_procName output
  set @xml_params = @p_num
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_LtdAdjDtl', '限制业务调整单生效提醒', @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end
GO
