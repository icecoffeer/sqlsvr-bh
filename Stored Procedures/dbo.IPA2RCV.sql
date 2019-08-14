SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2RCV](
  @p_src int,
  @p_id int,
  @p_checker int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @ret_status int
  declare @n_type smallint
  
  select @n_type = TYPE from NIPA2
    where SRC = @p_src and ID = @p_id
  if @@rowcount = 0
  begin
    select @err_msg = '指定的网络单据不存在(SRC = ' + rtrim(convert(char, @p_src)) + ', ID = ' + rtrim(convert(char, @p_id)) + ')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  if @n_type <> 1
  begin
    select @err_msg = '不是可接收的网络单据。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  
  exec @ret_status = IPA2RCVGO @p_src, @p_id, @p_checker, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  delete from NIPA2DTL where SRC = @p_src and ID = @p_id
  delete from NIPA2SWDTL where SRC = @p_src and ID = @p_id
  delete from NIPA2 where SRC = @p_src and ID = @p_id
  
  return(0)
end
GO
