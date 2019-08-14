SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EmpGroupRcv](
  @p_src int,
  @p_id int
) as
begin
  declare
    @ret_status int,
    @n_gid int,
    @no int,
    @n_type smallint

  select @ret_status = 0
  select @n_gid = Gid, @no = no, @n_type = Type
   from NEMPLOYEEGROUP
   where Src = @p_src and Id = @p_id

  if @n_type <> 1
   begin
    raiserror('不是可接收员工组', 16, 1)
    return(1)
   end

  if exists (select 1 from EMPLOYEEGROUP where Gid = @n_gid)    --存在员工组
   begin
    if not exists (select 1 from EMPLOYEEGROUP where No = @no)
      begin
       raiserror('本地找到相同员工组,但员工组代码不相同,不能接收.', 16, 1)
       return(2)
      end
    else
      begin
        --修改员工组
        execute @ret_status = EMPGROUPRCVAPD @p_src, @p_id
        if @ret_status <> 0
         return(@ret_status)

        --删除网络数据
        delete from NEMPGROUPSPECRIGHT where Src = @p_src and Id = @p_id
        delete from NEMPGRPRIGHT where Src = @p_src and Id = @p_id
        delete from NEMPLOYEEGROUP where Src = @p_src and Id = @p_id
      end
   end
  else  --员工组不存在
   begin
     if exists (select 1 from EMPLOYEEGROUP where No = @no)
      begin
       raiserror('新员工组,但是与本地员工组代码重复,不能接收', 16, 1)
       return(3)
      end
     else
      begin
       --接收新员工组
        execute @ret_status = EMPGROUPRCVAPD @p_src, @p_id
        if @ret_status <> 0
         return(@ret_status)

       --删除网络数据
       delete from NEMPGROUPSPECRIGHT where Src = @p_src and Id = @p_id
       delete from NEMPGRPRIGHT where Src = @p_src and Id = @p_id
       delete from NEMPLOYEEGROUP where Src = @p_src and Id = @p_id
      end
   end

  return 0
end

GO
