SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdjPrompt](
  @p_title varchar(200),
  @p_subjectclass varchar(200),
  @p_num varchar(14)
) as
begin
  declare @applydate datetime          
  declare @xml_num varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200),
          @xml_subjectclass varchar(100)
  declare @xml_map_dict varchar(2100),
          @xml_map_prompt varchar(2100)
  declare @filler varchar(50),
          @usergid int,
          @usercode varchar(10),
          @username varchar(20)
  declare @return varchar(255)

  --提取信息
  select @filler=checker from RtlPrcAdj where num=@p_num
  set @applydate=getdate()

  --触发的数据字典dict
  execute PFA_SERIALIZEXML_SETSTRING 'NUM', @p_num, @xml_num output
  set @xml_map_dict=@xml_num

  --模块参数  
  execute PFA_GET_OPERINFO_BYFILLER @filler, @usergid output, @usercode output, @Username output
  set @xml_title = @p_title
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output  
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 583, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'HD3Basic.bpl', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowRtlPrcAdj', @xml_procName output  
  execute PFA_SERIALIZEXML_SETSTRING 'params', @p_num, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_RtlPrcAdjDtl', @p_subjectclass, @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end
GO
