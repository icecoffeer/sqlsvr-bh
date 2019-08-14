SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_ExchangePrmPir](
  @pirType Char(10), --优先级中类型(单品,组合)
  @oripriority int, --原优先级
  @newpriority int --新优先级
)
as
begin
  Declare
    @PrmName Char(30), --促销名称
    @PrmNum Char(14), --单号
    @tbName Char(30), --促销单据表名
    @tbCls Char(10), --促销单据类型
    @ocrTbName Char(30), --促销单据生效表名
    @OcrTbCls Char(10), --促销单据生效表类型
    @v_Sql VarChar(2048)

  --从PROMPIR中取得需更新的促销单据信息
  Select @PrmName = PrmName, @PrmNum = Num
  From PROMPIR
    Where Cls = @pirType And Priority = @oripriority
  --首先根据PRMNAME得到对应促销单表的CLS
  if (CharIndex('价格促销', @PrmName) > 0)
  begin
    Set @tbCls = ''
    Set @OcrTbCls = ''

    If @PrmName = '批量价格促销'
    begin
      Set @tbName = 'POLYPRCPRM'
      Set @ocrTbName = 'POLYPRCPRMOCR'
    end else
    begin
      Set @tbName = 'PRCPRM'
      Set @ocrTbName = 'PRICE'
    end
  end else
  begin
    Set @tbCls = SubString(@PrmName, 1, CharIndex('促销', @PrmName) - 1)
    Set @OcrTbCls = @tbCls

    if (CharIndex('批量总', @PrmName) > 0)--批量总额总量
    begin
      Set @tbName = 'POLYPROM'
      Set @ocrTbName = 'POLYPROMOCR'
    end else
    begin
      Set @tbName = 'PROM'
      Set @ocrTbName = 'PROMOTE'
    end
  end
  --指定类型促销更新为新的优先级
  set @v_Sql = ' update ' + @tbName + ' Set PRIORITY = ' + str(@newpriority)
      + ' Where NUM = ''' + @PrmNum + ''' and PRIORITY = ' + str(@oripriority)
  if @tbCls <> ''
    set @v_Sql = @v_Sql + ' and Cls = ''' + RTrim(@tbCls) + ''''
  --更新生效表:PRICE表中没有BILLNUM,使用的是SRCNUM,因此区分来写
  set @v_Sql = @v_Sql + ' update ' + @ocrTbName + ' Set PRIORITY = ' + str(@newpriority)
  if @ocrTbName <> 'Price'
    set @v_sql = @v_sql + ' Where BILLNUM = '''
  else
    set @v_sql = @v_sql + ' Where SrcNum = '''
  set @v_sql = @v_sql + @PrmNum + ''' and PRIORITY = ' + str(@oripriority)
  if @OcrTbCls <> ''
    set @v_Sql = @v_Sql + ' and Cls = ''' + RTrim(@OcrTbCls) + ''''
  Exec (@v_Sql)

  --由于PROMPIR有个UNIQE限制(CLS,PRIORITY),因此不能直接更新,先更新为新优先级的相反数,避免冲突
  --然后在客户端循环调用完该过程后,统一更新为新的优先级
  Update PROMPIR Set PRIORITY = -@newpriority
    Where Cls = @pirType and PRIORITY = @oripriority

  return 0
end
GO
