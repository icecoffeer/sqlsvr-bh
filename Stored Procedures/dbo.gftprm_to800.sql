SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_to800]
(
  @piNum	char(14),
  @piOper	char(30),
  @poErrMsg varchar(255) output
)
as
begin
  declare @stat int
  declare @rcode varchar(18), @ret int, @aMsg varchar(255)
  select @stat = stat from gftprm where num = @piNum;
  if @stat <> 100
  begin
    set @poErrMsg = @piNum + '不是已审核单据，不能生效'
    return 1
  end
  
  /*update gftprmrule set stat = 1, begintime = getdate()
  where code in (select rulecode from gftprmdtl where num = @piNum)*/
  
  if object_id('c_gftprmdtl') is not null deallocate c_gftprmdtl
  declare c_gftprmdtl cursor for
  select rulecode from gftprmdtl where num = @piNum
  open c_gftprmdtl
  fetch next from c_gftprmdtl into @rcode
  while @@fetch_status = 0
  begin
    exec @ret = gftprmrule_start @rcode, @piOper, @aMsg output
    if @ret<>0
    begin
      if @ret = 1 
        set @poErrMsg = @poErrMsg + @aMsg + char(10)
      if @ret = 1
      begin
        close c_gftprmdtl
        deallocate c_gftprmdtl
        set @poErrMsg = '发生错误'+ @aMsg
        return @ret
      end
    end 
    fetch next from c_gftprmdtl into @rcode
  end
  close c_gftprmdtl
  deallocate c_gftprmdtl
   
  update gftprm set stat = 800, lstupdtime = getdate() where num = @piNum;
  exec gftprm_addlog @piNum, 800,@piOper
  
  --Added by Zhuhaohui 2007.12.14 生效消息提醒    
    declare @title varchar(500),
            @event varchar(100)
    --触发提醒
    set @title = '赠品促销单[' + @piNum + ']在' + Convert(varchar, getdate(), 20) + '生效了。'
    set @event = '赠品促销单生效提醒'
    execute GFTPRMCHKPROMPT @piNum, @title, @event
  --end of 促销单生效提醒
  
  return 0
end
GO
