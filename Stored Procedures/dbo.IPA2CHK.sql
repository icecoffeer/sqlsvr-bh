SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2CHK](
  @p_cls char(10),
  @p_num char(10),
  @p_tostat smallint,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int
  declare @m_stat int
  
  if @p_tostat not in (1, 2)
  begin
    select @err_msg = '传入参数非法(@p_tostat=' + convert(char(1), @p_tostat) + '。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  
  select @m_stat = STAT from IPA2 where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end

  if @m_stat = 0 and @p_tostat >= 1
  begin
    exec @ret_status = IPA2CHK_0TO1 @p_cls, @p_num, @err_msg output
    if @ret_status <> 0
    begin
      raiserror(@err_msg, 16, 1)
      return(1)
    end
    select @m_stat = 1
  end
  if @m_stat = 1 and @p_tostat = 2
  begin
    exec @ret_status = IPA2CHK_1TO2 @p_cls, @p_num, @err_msg output
    if @ret_status <> 0
    begin
      raiserror(@err_msg, 16, 1)
      return(1)
    end
    select @m_stat = 2
  end
  
  return(0)
end
GO
