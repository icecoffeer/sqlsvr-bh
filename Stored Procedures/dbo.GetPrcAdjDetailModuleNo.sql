SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetPrcAdjDetailModuleNo] (
  @p_cls char(10),
  @op_moduleno int output
) as
begin
  declare @error varchar(100)
  if @p_cls = '核算售价'
    set @op_moduleno = 24
  else if @p_cls = '核算价' 
    set @op_moduleno = 26
  else if @p_cls = '最低售价' 
    set @op_moduleno = 32
  else if @p_cls = '批发价' 
    set @op_moduleno = 34
  else if @p_cls = '代销价' 
    set @op_moduleno = 81
  else if @p_cls = '联销率' 
    set @op_moduleno = 86
  else if @p_cls = '会员价' 
    set @op_moduleno = 185
  else if @p_cls = '合同进价' 
    set @op_moduleno = 245
  else if @p_cls = '库存价' 
    set @op_moduleno = 430
  else if @p_cls = '量贩价' 
    set @op_moduleno = 452
  else if @p_cls = '积分' 
    set @op_moduleno = 375
  else 
  begin
    set @error = '不能识别调价单类型：' + @p_cls
    raiserror(@error, 16, 1)
  end
end
GO
