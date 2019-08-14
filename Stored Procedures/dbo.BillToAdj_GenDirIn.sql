SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BillToAdj_GenDirIn]
(
  @PiNum varchar(14),
  @PiOper varchar(30),
  @PiGenType SmallInt --生成单据类型:0,进货单;1,退货单
) as
begin
  Declare
    @v_Ret SmallInt,
    @v_Cls char(20),
    @v_Num char(14),
    @v_SettleNo int,
    @v_UserGid int,
    @v_Sender Int, --直配单中的配货单位字段,这里取总部
    @v_DirAlcWrh int, --System字段
    @v_ModuleNo int, --模块号,用于取选项值
    @v_DefineCsAdj VarChar(500), --定义游标语句
    --单据分单使用
    @v_TaxRate Money,
    @v_Dept Varchar(20),
    @v_PreTaxRate Money,
    @v_PreDept Varchar(20),
    @v_PreBillto int,
    @v_TaxRateLmt int, --单据是否启用税率限制
    @v_DeptLmt int, --单据是否启用部门限制
    @v_PriceType char(20), --选项设置取什么价格
    @v_StartNewNum int, --开始新的一单
    --游标使用
    @v_GdGid int,
    @v_Billto int,
    --生成单据使用
    @v_GdQty Money,
    @v_Line SmallInt,
    @v_Total Money,
    @v_Tax Money,
    @v_AlcTotal Money,
    @v_Filler Int,
    @v_InPrcTax Int, --是否去税,SYSTEM字段
    @v_KeepSame Varchar(30),
    @v_OutPrc Money,
    @v_Note VarChar(255),
    @v_Msg VarChar(255)

  If @PiGenType = 0
  begin
    Select @v_Cls = '直配进'
    Select @v_ModuleNo = 84
    Select @v_DefineCsAdj =
      'Declare C_Gd Cursor For
         Select Gdgid, OBillto, G.F1, G.TaxRate
           From BILLTOADJDTL D, GOODS G(Nolock)
         Where NUM = ''' + @PiNum  + ''' And D.GdGid = G.Gid
           and (SALE = 1) and (ALC = ''直配'')
         Order By OBillto'
  end else
  begin
    Select @v_Cls = '直配进退'
    Select @v_ModuleNo = 88
    Select @v_DefineCsAdj =
      'Declare C_Gd Cursor For
         Select Gdgid, NBillto, G.F1, G.TaxRate
           From BILLTOADJDTL D, GOODS G(Nolock)
         Where NUM = ''' + @PiNum  + ''' And D.GdGid = G.Gid
           and (SALE = 1) and (ALC = ''直配'')
         Order By NBillto'
  end
  Select @v_SettleNo = Max(No) from MONTHSETTLE
  Select @v_UserGid = UserGid, @v_Sender = ZBGID,
    @v_DirAlcWrh = DirAlcWrh, @v_InPrcTax = Inprctax --是否去税
  from System
  --取得用户GID
  Select @v_Filler = ISNULL(GID, 1) FROM EMPLOYEE(NOLOCK)
    WHERE RTRIM(NAME) + '[' + RTRIM(CODE) + ']' = @PiOper

  --部门和税率限制选项
  EXEC OPTREADINT @v_ModuleNo, 'MstInputDept', 0, @v_DeptLmt OUTPUT
  EXEC OPTREADINT @v_ModuleNo, 'MstInputTaxRateLmt', 0, @v_TaxRateLmt OUTPUT
  EXEC OPTREADSTR @v_ModuleNo, 'Chkoption', '', @v_KeepSame OUTPUT
  --根据HDOPIOTN取得"直配进退"模块选项PriceType
  EXEC OPTREADINT @v_ModuleNo, 'pricetype', 0, @v_PriceType OUTPUT
  SELECT @v_PriceType =
    CASE @v_PriceType
      WHEN '0' THEN    'LSTINPRC'
      WHEN '1' THEN    'INPRC'
      WHEN '2' THEN    'RTLPRC'
      WHEN '3' THEN    'CNTINPRC'
      WHEN '4' THEN    'WHSPRC'
      WHEN '5' THEN    'INVPRC'
      WHEN '6' THEN    'LWTRTLPRC'
      WHEN '7' THEN    'OLDINVPRC'
      WHEN '8' THEN    'MBRPRC'
      WHEN '9' THEN    'MKTINPRC'
      WHEN '10' THEN   'MKTRTLPRC'
      ELSE 'INPRC'
    END

  --分单初始值
  Select @v_PreTaxRate = 0
  Select @v_PreBillto = 0
  Select @v_PreDept = '0'

  Select @v_Line = 0
  Select @v_StartNewNum = 0
  --取得新单号
  SELECT @v_Num = Right(Max(Num) + 10000000001, 10)
    From DirAlc where Cls = @v_Cls
  IF @v_Num IS NULL SET @v_Num = '0000000001'

  Exec (@v_DefineCsAdj)
  Open C_Gd
  Fetch Next From C_Gd into @v_GdGid, @v_Billto, @v_Dept, @v_TaxRate
  While @@fetch_status = 0
  Begin
    --取得库存表中对应门店和仓位中商品的数量作为进/退货的数量
    Select @v_GdQty = Qty From INV
      Where Store = @v_UserGid and WRH = 1 and GdGid = @v_GdGid
    --若门店不存在该商品的库存,那么跳到下一个商品
    If (@v_GdQty Is Null) Or (@v_GdQty <= 0)
    Begin
      Fetch Next From C_Gd into @v_GdGid, @v_Billto, @v_Dept, @v_TaxRate

      Continue
    End
    --根据供应商、商品的税率及部门分单
    if @v_PreBillto <> @v_Billto
      Select @v_StartNewNum = 1
    else if (@v_DeptLmt = 1) and (@v_PreDept <> @v_Dept)
      Select @v_StartNewNum = 1
    else if (@v_TaxRateLmt = 1) and (@v_PreTaxRate <> @v_TaxRate)
      Select @v_StartNewNum = 1
    --如果分单条件满足,那么开始一张新单据
    if (@v_StartNewNum = 1) and (@v_PreBillto <> 0)
    begin
      --写汇总
      Select @v_Note = '由商品缺省供应商调整单''' + @PiNum + '''生成'
      Insert Into DIRALC(CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, PSR, TOTAL, TAX, ALCTOTAL, SRC, RECCNT, NOTE)
      Values(@v_Cls, @v_Num, @v_SettleNo, @v_Billto, @v_Sender, @v_UserGid, @v_Filler, 0, 0, 0, @v_UserGid, 0, @v_Note)
      --合计 DIRALCDTL 表中TOTAL,TAX,AlcTotal
      SELECT @v_Total = Convert( Decimal(20, 2), Sum(Total) ),
        @v_Tax = Convert( Decimal(20, 4), Sum(Tax) ),
        @v_AlcTotal = Convert( Decimal(20, 4), SUM(Qty * AlcPrc) )
      FROM DIRALCDTL
      WHERE NUM = @v_Num AND CLS = @v_Cls

      --更新 DIRALC 中的TOTAL, TAX, WRH
      UPDATE DIRALC
        SET TOTAL = Convert( Decimal(20, 2), @v_Total ), TAX = Convert( Decimal(20, 4), @v_Tax ),
          ALCTOTAL = Convert( Decimal(20, 2), @v_AlcTotal ), WRH = @v_DirAlcWrh
        WHERE Num = @v_Num and CLS = @v_Cls

      --更新 DIRALC 中的 FILLER
      UPDATE DIRALC
      SET FILLER = @v_Filler
      WHERE Num = @v_Num and Cls = @v_Cls

      --审核生成的 直配/退 单据
      Exec @v_Ret = DIRALCCHK @v_Cls, @v_Num, 0
      If @v_Ret <> 0
      Begin
        Select @v_Msg = '审核生成的' + @v_Cls + '单(' + @v_Num + ')出错'
        --更新缺省供应商调整单反馈明细状态为接收失败,并记录错误信息
        UPDATE BILLTOADJFEEDBCKDTL
          SET STAT = 3, RTNNOTE = @v_Msg
        WHERE Num = @PiNum and StoreGid = @v_UserGid
          and Exists(Select D.GdGid from DirAlcDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = @v_Cls and Num = @v_Num)

        Close c_Gd
        Deallocate c_Gd
        Return 1
      End
      --更新缺省供应商调整单反馈明细状态为已生效
      UPDATE BILLTOADJFEEDBCKDTL
        SET STAT = 2
      WHERE Num = @PiNum and StoreGid = @v_UserGid
        and Exists(Select D.GdGid from DirAlcDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = @v_Cls and Num = @v_Num)

      --取下一单号
      SELECT @v_Num = RIGHT( Max(Num) + 10000000001, 10)
        FROM DIRALC WHERE Cls = @v_Cls
      IF @v_Num IS NULL SET @v_Num = '0000000001'

      --行号清零
      Set @v_Line = 0
    End
    --分单值
    Select @v_PreBillto = @v_Billto
    Select @v_PreDept = @v_Dept
    Select @v_PreTaxRate = @v_TaxRate

    --插入明细
    set @v_Line = @v_Line + 1
    INSERT INTO DirAlcDtl (CLS, NUM, LINE, GDGID, SETTLENO, WRH, QTY, CASES, PRICE, TOTAL, TAX, ALCPRC, ALCAMT, WSPRC,
      INPRC, RTLPRC)
    VALUES(@v_Cls, @v_Num, @v_Line, @v_GdGid, @v_SettleNo, @v_DirAlcWrh, @v_GdQty, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    -- 更新 DIRALCDTL 中的inprc,rtlprc,wsprc,Cases
    UPDATE DIRALCDTL
      SET INPRC = B.Inprc, Rtlprc = B.Rtlprc, Wsprc = B.Whsprc, CASES = Qty/B.QPC
    FROM DIRALCDTL A, Goods B
    WHERE A.Gdgid = B.Gid And A.Num = @v_Num and A.Cls = @v_Cls
    -- 更新 DIRALCDTL 中的price,当DIRALCDTL.price<=0
    EXEC('UPDATE DIRALCDTL SET Price = b.' + @v_PriceType +
      ' FROM DIRALCDTL a, Goods b WHERE a.Price <= 0 and a.Gdgid = b.Gid AND A.CLS = ''' +
      @v_Cls+''' AND a.num ='''+@v_Num+'''')

    IF @v_InPrcTax = 1
    BEGIN
      -- 更新 DIRALCDTL 中的total
      UPDATE DIRALCDTL
        SET Total = Round(Price * Qty, 2)
      WHERE NUM = @v_Num AND CLS = @v_Cls

      --更新 DIRALCDTL 中的tax
      UPDATE DIRALCDTL
        SET Tax = Convert( Decimal(20, 4), a.Total - Round(a.Total / (1+ (b.Taxrate/100)), 2) )
      FROM DIRALCDTL a, Goods b
      WHERE a.Gdgid = b.Gid AND a.Num = @v_Num AND a.CLS = @v_Cls
    END ELSE
    BEGIN
      --更新 DIRALCDTL 中的tax
      UPDATE DIRALCDTL
      SET Tax = Convert( Decimal(20, 4), Round(Qty*(
        a.Price - a.Price /(1+ (gd.Taxrate/100)) ), 2) )
      FROM Goods gd(nolock) , Diralcdtl a
      WHERE gd.Gid = a.Gdgid and a.Num = @v_Num AND a.CLS = @v_Cls
      -- 更新 DIRALCDTL 中的total
      UPDATE DIRALCDTL
        SET Total = Round(a.Price /(1+ (b.Taxrate/100)) * Qty, 2)
      From Diralcdtl a, Goods b(Nolock)
      WHERE a.Gdgid = b.Gid and a.Num = @v_Num AND a.CLS = @v_Cls
      --去税则重算price
      UPDATE DIRALCDTL
        SET Price = Round(a.Price /(1+ (b.Taxrate/100)), 2)
      FROM DIRALCDTL a, Goods b
      WHERE a.Gdgid = b.Gid and a.Num = @v_Num AND a.CLS = @v_Cls
    END

    --更新明细的AlcPrc字段
    IF SUBSTRING(@v_KeepSame, 17, 1) = '1'
    BEGIN
      UPDATE DIRALCDTL Set Alcprc = Price Where Num = @v_Num AND CLS = @v_Cls
    END ELSE
    BEGIN
      EXEC @v_Ret = GETSTOREOUTPRC @v_UserGid, @v_GdGid, @v_DirAlcWrh, @v_OutPrc Output
      If @v_Ret <> 0
      Begin
        Select @v_Msg = '取出货单价的时候发生异常'

        Close c_Gd
        Deallocate c_Gd
        Return 1
      End

      UPDATE Diralcdtl SET ALCPRC = @v_OutPrc
      WHERE Cls = @v_Cls AND Num = @v_Num AND GDGID = @v_GdGid
    END
    --计算 Diralcdtl 中Alcamt和Outtax
    UPDATE Diralcdtl Set Alcamt = Convert( Decimal(20, 2), Qty * Alcprc )
      Where Num = @v_Num and CLS = @v_Cls

    UPDATE DIRALCDTL
      SET Outtax = Convert( Decimal(20, 4), a.Alcamt - Round(a.Alcamt / (1+ (b.Taxrate/100)), 2) )
    FROM DIRALCDTL a, Goods b(Nolock)
    WHERE a.Gdgid = b.Gid and a.Num = @v_Num AND a.Cls = @v_Cls

    --回写 缺省供应商调整单反馈明细
    If @PiGenType = 0
      Select @v_Note = '生成直配进单号:''' + @v_Num + ''''
    else
      Select @v_Note = '生成直配进退单号:''' + @v_Num + ''''
    UPDATE BILLTOADJFEEDBCKDTL
      SET STAT = 1, RTNNOTE = @v_Note
    WHERE Num = @PiNum and StoreGid = @v_UserGid and GdGid = @v_GdGid

    Fetch Next From C_Gd into @v_GdGid, @v_Billto, @v_Dept, @v_TaxRate
  End
  --生成最后一张
  if @v_PreBillto <> 0
    begin
      --写汇总
      Select @v_Note = '由商品缺省供应商调整单''' + @PiNum + '''生成'
      Insert Into DIRALC(CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, PSR, TOTAL, TAX, ALCTOTAL, SRC, RECCNT, NOTE)
      Values(@v_Cls, @v_Num, @v_SettleNo, @v_Billto, @v_Sender, @v_UserGid, @v_Filler, 0, 0, 0, @v_UserGid, 0, @v_Note)
      --合计 DIRALCDTL 表中TOTAL,TAX,AlcTotal
      SELECT @v_Total = Convert( Decimal(20, 2), Sum(Total) ),
        @v_Tax = Convert( Decimal(20, 4), Sum(Tax) ),
        @v_AlcTotal = Convert( Decimal(20, 2), SUM(Qty * AlcPrc) )
      FROM DIRALCDTL
      WHERE NUM = @v_Num AND CLS = @v_Cls

      --更新 DIRALC 中的TOTAL, TAX, WRH
      UPDATE DIRALC
        SET TOTAL = @v_Total, TAX = @v_Tax,
          ALCTOTAL = @v_AlcTotal, WRH = @v_DirAlcWrh
        WHERE Num = @v_Num and CLS = @v_Cls

      --更新 DIRALC 中的 FILLER
      UPDATE DIRALC
      SET FILLER = @v_Filler
      WHERE Num = @v_Num and Cls = @v_Cls

      --审核生成的 直配/退 单据
      Exec @v_Ret = DIRALCCHK @v_Cls, @v_Num, 0
      If @v_Ret <> 0
      Begin
        Select @v_Msg = '审核生成的' + @v_Cls + '单(' + @v_Num + ')出错'
        --更新缺省供应商调整单反馈明细状态为接收失败,并记录错误信息
        UPDATE BILLTOADJFEEDBCKDTL
          SET STAT = 3, RTNNOTE = @v_Msg
        WHERE Num = @PiNum and StoreGid = @v_UserGid
          and Exists(Select D.GdGid from DirAlcDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = @v_Cls and Num = @v_Num)

        Close c_Gd
        Deallocate c_Gd
        Return 1
      End
      --更新缺省供应商调整单反馈明细状态为已生效
      UPDATE BILLTOADJFEEDBCKDTL
        SET STAT = 2
      WHERE Num = @PiNum and StoreGid = @v_UserGid
        and Exists(Select D.GdGid from DirAlcDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = @v_Cls and Num = @v_Num)
    end
  Close c_Gd
  Deallocate c_Gd

  Return 0
end
GO
