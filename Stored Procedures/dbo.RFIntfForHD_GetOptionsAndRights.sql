SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetOptionsAndRights]
(
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @poUserGid int output,        --传出参数：SYSTEM.USERGID。返回值为0时有效。
  @poZBGid int output,          --传出参数：SYSTEM.ZBGID。返回值为0时有效。
  @poErrMsg varchar(255) output --传出参数：错误消息。返回值不为0时有效。
)
as
begin
  declare
    @EmpGid int

  --操作员GID。
  select @EmpGid = GID from EMPLOYEE(nolock)
    where CODE = @piEmpCode

  --获取系统设定（SYSTEM）的值。
  select
    @poUserGid = USERGID,
    @poZBGid = ZBGID
    from SYSTEM(nolock)

  --获取相关选项。
  select MODULENO, OPTIONCAPTION, OPTIONVALUE
    from HDOPTION(nolock)
    where MODULENO = 8146/*RF虚拟模块*/
  union
  select MODULENO, OPTIONCAPTION, OPTIONVALUE
    from HDOPTION(nolock)
    where MODULENO = 114/*定货单(明细)*/
    and OPTIONCAPTION = 'DEFAULTWAREHOUSEGID'
  union
  select MODULENO, OPTIONCAPTION, OPTIONVALUE
    from HDOPTION(nolock)
    where MODULENO = 52/*自营进货单(明细)*/
    and (OPTIONCAPTION = 'MSTINPUTDEPT'
      or OPTIONCAPTION = 'MSTINPUTTAXRATELMT')
  union
  select MODULENO, OPTIONCAPTION, OPTIONVALUE
    from HDOPTION(nolock)
    where MODULENO = 84/*直配进货单(明细)*/
    and (OPTIONCAPTION = 'MSTINPUTDEPT'
      or OPTIONCAPTION = 'MSTINPUTTAXRATELMT')
  union
  select MODULENO, OPTIONCAPTION, OPTIONVALUE
    from HDOPTION(nolock)
    where MODULENO = 38/*自营进货退货单(明细)*/
    and (OPTIONCAPTION = 'MSTINPUTDEPT'
      or OPTIONCAPTION = 'MSTINPUTTAXRATELMT')

  --获取RF虚拟模块（8146）的特殊权限。
  select mr.MODULE, mr.COMPONENTNAME, esr.RIGHTLEVEL
    from MODULERIGHT mr(nolock), EMPSPECRIGHT esr(nolock)
    where mr.NO = esr.SPECRIGHTNO
    and esr.EMPID = @EmpGid
    and esr.SPECRIGHTNO / 1000 = 8146
    and esr.SPECRIGHTNO2 = '-'
    and esr.RIGHTLEVEL = 0
  union
  select mr.MODULE, mr.COMPONENTNAME, min(egsr.RIGHTLEVEL) RIGHTLEVEL
    from MODULERIGHT mr(nolock), EMPGROUPSPECRIGHT egsr(nolock), EMPLOYEERIGHT er(nolock)
    where mr.NO = egsr.SPECRIGHTNO
    and egsr.EMPGROUPID = er.EMPLOYEEGROUP
    and er.EMPLOYEE = @EmpGid
    and egsr.SPECRIGHTNO / 1000 = 8146
    and egsr.SPECRIGHTNO2 = '-'
    and egsr.RIGHTLEVEL = 0
    group by mr.MODULE, mr.COMPONENTNAME

  return 0
end
GO
