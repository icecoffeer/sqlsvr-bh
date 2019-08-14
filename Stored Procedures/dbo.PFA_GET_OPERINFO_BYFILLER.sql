SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_GET_OPERINFO_BYFILLER](
  @p_filler varchar(40),
  @p_gid int output,
  @p_code varchar(10) output,
  @p_name varchar(20) output  
) as  
begin
  --默认值
  set @p_gid  = 1
  set @p_code = '-'
  set @p_name = '未知'
  --试图解释p_filler
  declare @p int,
          @count int
  set @p = PATINDEX('%[[]%', @p_filler)
  if @p = 0 return -1 --不能解释就退出，使用默认值
  set @count = LEN(@p_filler) - @p
  set @p = @p + 1
  set @p_filler = SUBSTRING(@p_filler, @p, @count)
  set @p = PATINDEX('%]%', @p_filler)
  if @p = 0 return -1 --不能解释
  set @p = @p - 1
  set @p_filler = LEFT(@p_filler, @p)
  --尝试去取信息
  declare @gid int,
          @code varchar(10),
          @name varchar(20)
  select @gid=GID, @code=RTRIM(CODE), @name=RTRIM(NAME) from EMPLOYEE where CODE=@p_filler
  if @code is NULL return -1 --找不到对应记录
  --返回找到的信息
  set @p_gid = @gid
  set @p_code = @code
  set @p_name = @name
  return 0  
end
GO
