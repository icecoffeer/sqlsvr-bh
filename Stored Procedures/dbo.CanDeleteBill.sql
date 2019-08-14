SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CanDeleteBill]
  @bill varchar(10),
  @cls char(10),
  @num char(10),
  @errmsg varchar(200) = '' output
as begin
  /* 00-3-30
  STKIN 自营  1
  STKIN 配货  2
  STKIN 调入  1
  STKINBCK  自营  1
  STKINBCK  配货  2
  STKOUT  批发  1
  STKOUT  配货  2
  STKOUT  调出  1
  STKOUTBCK 批发  1
  STKOUTBCK 配货  2
  DIRALC  直配出  2
  DIRALC  直配进  2
  DIRALC  直配出退  2
  DIRALC  直配进退  2
  DIRALC  直销  1
  DIRALC  直销退  1
  说明：
  方案1：只有没有发生过成本调整的单据可以冲单和修正。
  方案2：禁止冲单和修正。
  参见：<file:\\HOST\HDPOS31\项目\华联家电\设计方案\批次管理成本调整.doc>[3.6]
  */
  declare @acls char(10), @anum char(10), @return_status int
  select @return_status = 0
  if (select batchflag from system) = 1 begin
    if (@cls like '%配%') begin
      select @errmsg = '使用批次管理时(直)配货单不能被冲单或修正',
             @return_status = 1021
    end else begin
      select @acls = null, @anum = null
      select @acls = CLS, @anum = NUM from INPRCADJDTL
      where STORE = (select USERGID FROM SYSTEM)
      and BILL = @bill and BILLCLS = @cls and BILLNUM = @num
      and LACTIME is not null
      if @acls is not null
        select @errmsg = '本单据已被进价调整单调整(' + @acls + ', ' + @anum + '),不能冲单或修正.',
               @return_status = 1022
    end
  end
  return @return_status
end
GO
