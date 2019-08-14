SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_to100]
(
  @piNum char(14),
  @pioper	 char(30),
  @poErrmsg varchar(255) output
)
as
begin
  declare @stat int
  declare @rcode char(18)
  declare @retMsg varchar(255)
  declare @begintime datetime, @endtime datetime
  select @stat = stat, @begintime = begintime, @endtime = endtime 
  	from gftprm where num = @pinum
  if @stat <> 0
  begin
    set @poErrmsg = @piNum + '不是未审核单据，不能审核'
    return 1
  end
  if @begintime >= @endtime
  begin
    set @poErrmsg = @piNum + '开始结束时间非法'
    return 1
  end
/*  if (@BeginTime < GetDate()) or (@EndTime < GetDate()) 
  begin
    set @poErrMsg = '促销规则' + @piNum + '开始结束时间非法，不能生效'
    return(1)
  end*/

  update gftprm set stat = 100, lstupdtime = getdate(),checker = @pioper, chkdate = getdate() where num = @piNum;
  
  --Added by Zhuhaohui 2007.12.14 审核消息提醒    
    declare @title varchar(500),
            @event varchar(100)
    --触发提醒
    set @title = '赠品促销单[' + @piNum + ']在' + Convert(varchar, getdate(), 20) + '被审核了。'
    set @event = '赠品促销单审核提醒'
    execute GFTPRMCHKPROMPT @piNum, @title, @event
  --end of 促销单审核提醒
  
  exec gftprm_addlog @piNum, 100,@piOper
  exec gftprm_to800 @piNum, @piOper,@poErrMsg output
  return 0
end
GO
