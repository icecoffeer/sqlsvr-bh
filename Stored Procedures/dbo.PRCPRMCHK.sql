SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMCHK](
    @num char(10)
) with encryption as
begin
    declare
        @return_status int,
        @stat smallint,
	@m_launch datetime --2002.09.02 2002081344986

    select @return_status = 0

    select @stat = STAT, @m_launch = LAUNCH from PRCPRM where NUM = @num
    if @stat <> 0
    begin
        raiserror('审核的不是未审核的单据.', 16, 1)
        return(1)
    end
    update PRCPRM set STAT = 1 where NUM = @num
 --2005.10.14, Added by ShenMin, Q5047, 售价调整单促销单记录操作日志
    exec WritePrcPrmLog '促销单', @num, '审核'

 --2007.12.17 Added by Zhuhaohui, 促销单审核消息提醒

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

  --提取信息
  select @usergid=CHECKER, @applydate=getdate() from PRCPRM where NUM = @num

  --触发的数据字典dict
  execute PFA_SERIALIZEXML_SETINTEGER 'NUM', @num, @xml_num output
  set @xml_map_dict=@xml_num

  --模块参数  
  execute PFA_GET_OPERINFO_BYGID @usergid output, @usercode output, @Username output
  set @xml_title = '促销单[' + RTRIM(@num) + ']在' + Convert(varchar, @applydate, 20) + '被审核了' 
  execute PFA_SERIALIZEXML_SETSTRING 'title', @xml_title , @xml_title output
  execute PFA_SERIALIZEXML_SETINTEGER 'moduleNo', 62, @xml_moduleNo output
  execute PFA_SERIALIZEXML_SETSTRING 'pkgName', '', @xml_pkgName output
  execute PFA_SERIALIZEXML_SETSTRING 'procName', 'MsgShowPrcPrm', @xml_procName output
  set @xml_params = Convert(varchar, @num)
  execute PFA_SERIALIZEXML_SETSTRING 'params', @xml_params, @xml_params output
  set @xml_map_prompt = @xml_title + @xml_moduleNo + @xml_pkgName + @xml_procName + @xml_params

  --插入触发记录
  execute PFA_MscbNotify_AppendNotify 'PS3_HDBasic_PrcPrmDetail', '促销单审核提醒', @xml_map_dict, @xml_map_prompt, @applydate, @usergid, @usercode, @username, @return output

 --结束促销单审核消息提醒
  
    if (@m_launch is null or @m_launch < getdate())--2002-09-02
    	execute @return_status = PRCPRMGO @num
    return(@return_status)
end
GO
