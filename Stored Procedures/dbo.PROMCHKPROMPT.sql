SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROMCHKPROMPT](
  @p_num varchar(14),
  @p_cls varchar(10),
  @p_title varchar(200),
  @p_Event varchar(100),
  @p_filler varchar(100)
)as
begin
  declare @xml_num varchar(200),
          @xml_cls varchar(200),
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
          @username varchar(20),
          @moduleno int,
          @subjectclass varchar(32)
  declare @return varchar(255)

  --触发的数据字典dict
  execute PFA_SERIALIZEXML_SETSTRING 'NUM', @p_num, @xml_num output
  execute PFA_SERIALIZEXML_SETSTRING 'CLS', @p_cls, @xml_cls output
  set @xml_map_dict=@xml_num + @xml_cls

  --模块参数
  execute PFA_GET_OPERINFO_BYFILLER @p_filler, @usergid output, @usercode output, @username output
  set @xml_title = @p_title
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output

  if (@p_cls = '组合' )
  begin
    set @moduleno = 677
    execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', @moduleno, @xml_moduleNo output
    execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'HD3Basic.bpl', @xml_pkgName output
    execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPromBDtl', @xml_procName output
  end
  else if (@p_cls = '捆绑')
  begin
    set @moduleno = 683
    execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', @moduleno, @xml_moduleNo output
    execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'HD3Basic.bpl', @xml_pkgName output
    execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPromFDtl', @xml_procName output
  end
  else if (@p_cls = '客单价')
  begin
    set @moduleno = 708
    execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', @moduleno, @xml_moduleNo output
    execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'Price.bpl', @xml_pkgName output
    execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPromBillPrc', @xml_procName output
  end
  else if (@p_cls = '客单量')
  begin
    set @moduleno = 710
    execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', @moduleno, @xml_moduleNo output
    execute PFA_SERIALIZEXML_SETSTRING 'pkgName', 'Price.bpl', @xml_pkgName output
    execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPromBillQty', @xml_procName output
  end

  execute PFA_SERIALIZEXML_SETSTRING 'params', @p_num, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  set @applydate = getdate()
  set @subjectclass = 'PS3_HDBasic_PromBill' + Convert(varchar, @moduleno)
  execute PFA_MscbNotify_AppendNotify @subjectclass, @p_event, @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output
end
GO
