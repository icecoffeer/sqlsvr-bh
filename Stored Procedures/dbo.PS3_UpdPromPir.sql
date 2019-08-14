SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_UpdPromPir](
  @tbName Char(30), --单据表名
  @tbCls Char(10), --单据类型
  @tbNum Char(14), --单号
  @ocrTbName Char(30), --单据生效表名
  @pirType Char(10) --优先级中类型(单品,组合)
)
as
begin
  declare
    @Priority int,
    @v_Sql VarChar(512),
    @v_PrmName VarChar(30),
    @v_Num VarChar(14),
    @v_PriOrity Int,
    @v_cntPir Int,
    @v_pirPrmName VarChar(30), --定义优先级中促销名称
    @v_OcrTbCls Char(10), --定义游标中生效表的类型
    @v_tbCls Char(10), --定义游标中促销单表类型
    @opt_UsePromPir smallint

  exec OPTREADINT 0, 'PS3_UsePromPriority', 0, @opt_UsePromPir OutPut
  if @opt_UsePromPir <> 1
    return 0

  if @tbName = 'PRCPRM'
    Set @v_pirPrmName = '价格促销'
  else if @tbName = 'POLYPRCPRM'
    Set @v_pirPrmName = '批量价格促销'
  else if @tbCls <> ''
  begin
    if ((@tbCls = '总额') or (@tbCls = '总量')) and (@tbName = 'POLYPROM')
      Set @v_pirPrmName = '批量' + Rtrim(@tbCls) + '促销'
    else
      Set @v_pirPrmName = Rtrim(@tbCls) + '促销'
  end

  --取得当前单据的优先级
  if object_id('#tmp_Pir') is not null drop table #tmp_Pir
  Create table #tmp_pir(PrmPir int)
  set @v_Sql = ' insert into #tmp_pir '
    + ' select PRIORITY From ' + Rtrim(@tbName) + '(nolock) WHERE NUM = ''' + @tbNum + ''''
  if @tbCls <> ''
    set @v_Sql = @v_Sql + ' and Cls = ''' + RTrim(@tbCls) + ''''
  Exec (@v_Sql)
  Select @Priority = PrmPir from #tmp_pir

  --只有设置优先级的促销单信息写入促销优先级表
  if (@Priority > 0) and Exists( Select 1 from PROMPIR(Nolock) Where (CLS = @pirType) and (PRIORITY = @Priority) )
  begin
    --更新原有促销单优先级及单据生效表
    set @v_cntPir = @Priority
    declare c_PromPir cursor for
      select PRMNAME, NUM, PRIORITY from PROMPIR(nolock)
        where (CLS = @pirType) and (PRIORITY >= @Priority)
      Order By PRIORITY DESC
    open c_PromPir
    fetch next from c_PromPir into @v_PrmName, @v_Num, @v_PriOrity
    while @@fetch_status = 0
    begin
      if @v_PriOrity >= @Priority
        set @v_cntPir = @v_PriOrity + 1
      else
        Break
      --首先根据PRMNAME得到对应促销单表的CLS
      if (CharIndex('价格促销', @v_PrmName) > 0)
      begin
        Set @v_tbCls = ''
        Set @v_OcrTbCls = ''
      end else
      begin
        Set @v_tbCls = SubString(@v_PrmName, 1, CharIndex('促销', @v_PrmName) - 1)
        Set @v_OcrTbCls = @v_tbCls
      end
      --如果指定类型促销已存在该优先级,那么该优先级及后面的数据优先级字段+1
      set @v_Sql = ' update ' + @tbName + ' Set PRIORITY = ' + str(@v_cntPir)
        + ' Where NUM = ''' + @v_Num + ''' and PRIORITY = ' + str(@v_PriOrity)
      if @v_tbCls <> ''
        set @v_Sql = @v_Sql + ' and Cls = ''' + RTrim(@v_tbCls) + ''''
      --更新生效表:PRICE表中没有BILLNUM,使用的是SRCNUM,因此区分来写
      set @v_Sql = @v_Sql + ' update ' + @ocrTbName + ' Set PRIORITY = ' + str(@v_cntPir)
      if @ocrTbName <> 'Price'
        set @v_sql = @v_sql + ' Where BILLNUM = '''
      else
        set @v_sql = @v_sql + ' Where SrcNum = '''
      set @v_sql = @v_sql + @v_Num + ''' and PRIORITY = ' + str(@v_PriOrity)
      if @v_OcrTbCls <> ''
        set @v_Sql = @v_Sql + ' and Cls = ''' + RTrim(@v_OcrTbCls) + ''''
      Exec (@v_Sql)

      fetch next from c_PromPir into @v_PrmName, @v_Num, @v_PriOrity
    end
    close c_PromPir
    deallocate c_PromPir
    --更新PROMPIR
    Update PROMPIR Set PRIORITY = PRIORITY + 1
      Where (CLS = @pirType) and (PRIORITY >= @Priority)
  end
  --将本次新增的单据优先级写入促销单优先级表
  if @Priority > 0
    INSERT INTO PROMPIR(CLS, PRMNAME, NUM, PRIORITY)
    VALUES(@pirType, @v_pirPrmName, @tbNum, @Priority)

  return 0
end
GO
