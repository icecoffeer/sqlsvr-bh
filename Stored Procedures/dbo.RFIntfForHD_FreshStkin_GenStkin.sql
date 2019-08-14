SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_FreshStkin_GenStkin](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @fetch_status int,
    @Opt_MstInputTaxRateLmt int,
    @Opt_MstInputDept int,
    @SQL varchar(8000),
    @d_VdrCode char(10),
    @d_WrhCode char(10),
    @d_TaxRateLmt decimal(24,4),
    @d_Dept char(14),
    @d_Note varchar(255)

  --选项：税率限制
  exec OPTREADINT 52, 'MstInputTaxRateLmt', 0, @Opt_MstInputTaxRateLmt output
  --选项：部门限制
  exec OPTREADINT 52, 'MstInputDept', 0, @Opt_MstInputDept output

  --声明游标
  set @SQL = ' declare c_RfFreshStkin_0 cursor for'
    + ' select distinct d.VDRCODE, d.WRHCODE, d.TAXRATELMT, d.DEPT, d.NOTE'
    + ' from RFFRESHSTKIN d(nolock)'
    + '   inner join VENDOR v(nolock) on v.CODE = d.VDRCODE'
    + '   inner join WAREHOUSE w(nolock) on w.CODE = d.WRHCODE'
    + '   inner join GOODS g(nolock) on g.CODE = d.GDCODE'
    + ' where d.OPERATORCODE = ''' + rtrim(@piEmpCode) + ''''
    + ' and d.GENBILLNAME is null'
    + ' and d.GENBILLNUM is null'
    + ' and d.GENTIME is null'
  --税率限制
  if @Opt_MstInputTaxRateLmt = 1
  begin
    set @SQL = @SQL + ' and d.TAXRATELMT is not null'
  end
  else begin
    set @SQL = @SQL + ' and d.TAXRATELMT is null'
  end
  --部门限制
  if @Opt_MstInputDept = 1
  begin
    set @SQL = @SQL + ' and d.DEPT is not null'
  end
  else begin
    set @SQL = @SQL + ' and d.DEPT is null'
  end
  --声明游标
  exec(@SQL)
  --打开游标
  open c_RfFreshStkin_0
  set @return_status = 0
  fetch next from c_RfFreshStkin_0 into @d_VdrCode, @d_WrhCode, @d_TaxRateLmt,
    @d_Dept, @d_Note
  set @fetch_status = @@fetch_status
  while @fetch_status = 0
  begin
    exec @return_status = RFIntfForHD_FreshStkin_GenOneStkin @piEmpCode,
      @d_VdrCode, @d_WrhCode, @d_TaxRateLmt, @d_Dept, @d_Note, @poErrMsg output
    if @return_status <> 0
      goto LABEL_BEFORE_EXIT
    fetch next from c_RfFreshStkin_0 into @d_VdrCode, @d_WrhCode, @d_TaxRateLmt,
      @d_Dept, @d_Note
    set @fetch_status = @@fetch_status
  end
LABEL_BEFORE_EXIT:
  close c_RfFreshStkin_0
  deallocate c_RfFreshStkin_0
  return(@return_status)
end
GO
