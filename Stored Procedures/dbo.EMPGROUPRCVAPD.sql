SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPGROUPRCVAPD](
    @p_src int,
    @p_id int
) as
begin
  declare @n_gid int

  DECLARE C_RcvGrp CURSOR FOR
    select Gid from NEMPLOYEEGROUP
     where Src = @p_src and id = @p_id
  OPEN C_RcvGrp
  FETCH NEXT FROM C_RcvGrp INTO @n_gid
  WHILE @@FETCH_STATUS = 0
  BEGIN
  	--先删除数据
  	/*if @n_gid <> 1
  	  delete from EMPLOYEEGROUP where gid = @n_gid*/
    delete from EMPGRPRIGHT where empgrpgid = @n_gid
    delete from EMPGROUPSPECRIGHT where empgroupid = @n_gid
    if @@error <> 0
      return (@@error)

    if not exists(select 1 from EMPLOYEEGROUP(nolock) where gid = @n_gid)
    BEGIN
      --员工组
      SET IDENTITY_INSERT EMPLOYEEGROUP ON
      insert into EMPLOYEEGROUP(GID, NO, NAME, [RIGHT], EXTRARIGHT, MEMO, SRC)
      select GID, NO, NAME, [RIGHT], EXTRARIGHT, MEMO, SRC
      from NEMPLOYEEGROUP
      where Src = @p_src and Id = @p_id and gid = @n_gid
      SET IDENTITY_INSERT EMPLOYEEGROUP OFF
       if @@error <> 0
        return (@@error)
    END ELSE
    BEGIN
      UPDATE EMPLOYEEGROUP SET NO = D.NO, NAME = D.NAME, [RIGHT] = D.[RIGHT], EXTRARIGHT = D.EXTRARIGHT,
       MEMO = D.MEMO, SRC = D.SRC
      FROM NEMPLOYEEGROUP D
      WHERE EMPLOYEEGROUP.GID = 1 and EMPLOYEEGROUP.GID = D.GID
    END

    --员工组权限
    insert into EMPGRPRIGHT(EMPGRPGID, ARIGHT, ARIGHT2)
    select EMPGRPGID, ARIGHT, ARIGHT2
    from NEMPGRPRIGHT
    where Src = @p_src and Id = @p_id and empgrpgid = @n_gid
    if @@error <> 0
      return (@@error)

    --员工组特殊权限
    insert into EMPGROUPSPECRIGHT(EMPGROUPID, SPECRIGHTNO, RIGHTLEVEL, SPECRIGHTNO2)
    select EMPGROUPID, SPECRIGHTNO, RIGHTLEVEL, SPECRIGHTNO2
    from NEMPGROUPSPECRIGHT
    where Src = @p_src and Id = @p_id and empgroupid = @n_gid
    if @@error <> 0
      return (@@error)

    FETCH NEXT FROM C_RcvGrp INTO @n_gid
  END
  CLOSE C_RcvGrp
  DEALLOCATE C_RcvGrp

  return 0
end

GO
