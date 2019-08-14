SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCADJCHK](
  @p_cls char(8),
  @p_num char(10)
) --with encryption 
as
begin
  declare
    @return_status int,
    @m_stat smallint,
    @m_launch datetime,
    @errmsg varchar(255)

  select
    @m_stat = STAT,
    @m_launch = LAUNCH
    from PRCADJ where CLS = @p_cls and NUM = @p_num
  if @m_stat <> 0 begin
    raiserror('审核的不是未审核的单据', 16, 1)
    return(3)
  end

  update PRCADJ set STAT = 1 where CLS = @p_cls and NUM = @p_num
--2005.8.9, Added by ShenMin, Q4706, 调价类单记录日志
    exec WritePrcAdjLog @p_cls, @p_num, '审核'
  --2007.12.18 调价单审核消息提醒
  exec PrcAdjChkPrompt @p_cls, @p_num
  --结束消息提醒
  
  if (@m_launch is null or @m_launch < getdate())
  begin
    execute @return_status = PRCADJGO @p_cls, @p_num, @errmsg output
    if @return_status <> 0
    begin
      raiserror(@errmsg, 16, 1)
    end
  end
  return (@return_status)
end

GO
