SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PRCINPRMPROMPT](
  @p_num varchar(10)
) as
begin
  declare @applydate datetime
  declare @xml_num varchar(200),
          @xml_cls varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200),
          @xml_subjectclass varchar(100)
  declare @xml_map_dict varchar(2100),
          @xml_map_prompt varchar(2100)
  declare @usergid int,
          @usercode varchar(10),
          @username varchar(20)
  declare @return varchar(255)

  --提取信息
  select @usergid=CHECKER, @applydate=getdate() from INPRCPRM where NUM = @p_num

  --触发的数据字典dict
  execute PFA_SERIALIZEXML_SETSTRING 'NUM', @p_num, @xml_num output
  set @xml_map_dict=@xml_num

  --模块参数  
  execute PFA_GET_OPERINFO_BYGID @usergid output, @usercode output, @Username output
  set @xml_title = '进价促销单[' + @p_num + ']在' + Convert(varchar, @applydate, 20) + '被审核了'
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 432, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPrcInPrm', @xml_procName output  
  execute PFA_SERIALIZEXML_SETSTRING 'params', @p_num, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  set @xml_subjectclass = '进价促销单审核提醒'
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_PRCINPRMDETAIL', @xml_subjectclass, @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end
GO
