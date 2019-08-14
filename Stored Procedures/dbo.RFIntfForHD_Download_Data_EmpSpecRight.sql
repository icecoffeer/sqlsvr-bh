SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_EmpSpecRight](
  @poErrMsg varchar(255) output
)
as
begin
  --返回结果集必须以EMPID和SPECRIGHTNO为业务主键，因此，需要用union来去除重复记录。
  select esr.EMPID, esr.SPECRIGHTNO, esr.RIGHTLEVEL, mr.MODULE,
    rtrim(mr.COMPONENTNAME) COMPONENTNAME
    from MODULERIGHT mr(nolock), EMPSPECRIGHT esr(nolock)
    where mr.NO = esr.SPECRIGHTNO
    and mr.MODULE = 8146
    and esr.SPECRIGHTNO like '8146___'
    and esr.RIGHTLEVEL = 0
  union
  select er.EMPLOYEE EMPID, egsr.SPECRIGHTNO, min(egsr.RIGHTLEVEL) RIGHTLEVEL, mr.MODULE,
    rtrim(mr.COMPONENTNAME) COMPONENTNAME
    from MODULERIGHT mr(nolock), EMPGROUPSPECRIGHT egsr(nolock), EMPLOYEERIGHT er(nolock)
    where mr.NO = egsr.SPECRIGHTNO
    and egsr.EMPGROUPID = er.EMPLOYEEGROUP
    and mr.MODULE = 8146
    and egsr.SPECRIGHTNO like '8146___'
    and egsr.RIGHTLEVEL = 0
    group by er.EMPLOYEE, egsr.SPECRIGHTNO, mr.MODULE, mr.COMPONENTNAME
  return 0
end
GO
