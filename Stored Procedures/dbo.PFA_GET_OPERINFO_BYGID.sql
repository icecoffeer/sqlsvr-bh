SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_GET_OPERINFO_BYGID](
  @p_gid int output,
  @p_code varchar(10) output,
  @p_name varchar(20) output  
) as  
begin
  declare @gid int,
          @code varchar(10),
          @name varchar(20)
  set @gid = @p_gid
  --设默认值
  set @p_gid  = 1
  set @p_code = '-'
  set @p_name = '未知'
  --数据库尝试取值
  select @gid=GID, @code=RTRIM(CODE), @name=RTRIM(NAME) from EMPLOYEE where GID=@gid
  if @code is null return -1 --找不到对应记录
  --返回找到的信息
  set @p_gid = @gid
  set @p_code = @code
  set @p_name = @name
  return 0  
end
GO
