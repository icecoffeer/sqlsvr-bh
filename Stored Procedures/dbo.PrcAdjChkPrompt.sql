SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PrcAdjChkPrompt](
  @p_cls varchar(8),
  @p_num varchar(10)
) as
begin
  declare @applydate datetime,
          @moduleno int
  declare @xml_num varchar(200),
          @xml_cls varchar(200),
          @xml_title varchar(200),
          @xml_moduleNo varchar(200),
          @xml_pkgName varchar(200),
          @xml_procName varchar(200),
          @xml_params varchar(200),
          @xml_event varchar(100),
          @xml_subjectclass varchar(100)
  declare @xml_map_dict varchar(2100),
          @xml_map_prompt varchar(2100)
  declare @usergid int,
          @usercode varchar(10),
          @username varchar(20)
  declare @return varchar(255)

  --提取信息
  select @usergid=CHECKER, @applydate=getdate() from PRCADJ where NUM = @p_num and CLS=@p_cls

  --触发的数据字典dict
  execute PFA_SERIALIZEXML_SETSTRING 'NUM', @p_num, @xml_num output
  execute PFA_SERIALIZEXML_SETSTRING 'CLS', @p_cls, @xml_cls output
  set @xml_map_dict=@xml_num + @xml_cls

  --模块参数  
  execute PFA_GET_OPERINFO_BYGID @usergid output, @usercode output, @Username output
  set @xml_title = @p_cls + '调整单[' + @p_num + ']在' + Convert(varchar, @applydate, 20) + '被审核了'
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute GetPrcAdjDetailModuleNo @p_cls, @moduleno output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', @moduleno, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPrcDetail', @xml_procName output  
  declare @SP_CHAR varchar(4) 
  set @SP_CHAR = '#||#'  
  set @xml_params = 'moduleno_detail='+ Convert(varchar, @moduleno) + @SP_CHAR + 'NUM=' + @p_num + @SP_CHAR + 'CLS=' + @p_cls
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  set @xml_event= @p_cls + '审核提醒'
  set @xml_subjectclass = 'PS3_HDBasic_PrcDetail' + Convert(varchar, @moduleno)
  execute PFA_MscbNotify_AppendNotify @xml_subjectclass, @xml_event, @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end
GO
