SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BillToAdj_GenWhsBill]
(
  @PiNum varchar(14),
  @PiOper varchar(30),
  @PiGenType SmallInt --生成单据类型:0,批发;1,批发退
) As
begin
  Declare
    @v_UserGid int,
    @v_ZbGid int,
    @v_Num VarChar(14),
    @v_SettleNo int,
    @v_Filler int,
    @v_Note VarChar(255),
    @v_Line int,
    @v_GdGid int,
    @v_Wrh int,
    @v_TaxRate Money,
    @v_GdQty Money,
    @v_Qpc Money,
    @v_InvQty Money,
    @v_OutPrc Money,
    @v_Total Money,
    @v_Tax Money,
    @v_Reccnt Int,
    @v_Msg VarChar(255),
    --构造语句
    @v_TableNameM Char(10),
    @v_TableNameD Char(15),
    @v_GenSql VarChar(1000)

  Select @v_Line = 0
  Select @v_SettleNo = Max(No) from MONTHSETTLE
  Select @v_UserGid = UserGid, @v_ZbGid = ZbGid From System(Nolock)
  If @PiGenType = 0
  begin
    Select @v_TableNameM = 'Stkout'
    Select @v_TableNameD = 'StkoutDtl'
  end else
  begin
    Select @v_TableNameM = 'StkoutBck'
    Select @v_TableNameD = 'StkoutBckDtl'
  end
  --取得用户GID
  Select @v_Filler = ISNULL(GID, 1) FROM EMPLOYEE(NOLOCK)
    WHERE RTRIM(NAME) + '[' + RTRIM(CODE) + ']' = @PiOper
  --抢占单号
  Select @v_Num = Isnull(Max(Num), '0000000001') From Stkout(Nolock) Where Cls = '批发'
  Exec NEXTBN @v_Num, @v_Num Output
  --写主表
  Select @v_Note = '由商品缺省供应商调整单(' + @PiNum + ')生成'
  Select @v_GenSql =
    'Insert Into ' + @v_TableNameM + '(Cls, Num, Settleno, Wrh, Client, Billto, Ocrdate, Total, Tax,
      Fildate, Filler, Stat, Reccnt, Src, Note)
    Values( ''批发'' ,''' + @v_Num + ''',' + Str(@v_SettleNo) + ', 1, 1, 1, Getdate(),  0, 0,
      Getdate(), ' + Str(@v_Filler) + ', 0, 0, ' + Str(@v_UserGid) + ',''' + @v_Note + ''')'
  Exec(@v_GenSql)

  --定义缺省供应商调整单中商品游标(统配商品)
  Declare C_Gd Cursor For
    Select Gdgid, G.WRH, G.TaxRate, Isnull(Qpc, 1)
      From BILLTOADJDTL D, GOODS G(Nolock)
    Where NUM = @PiNum And D.GdGid = G.Gid
      and (SALE = 1) and (ALC = '统配')
    Order By GdGid
  Open C_Gd
  Fetch Next From C_Gd into @v_GdGid, @v_Wrh, @v_TaxRate, @v_Qpc
  While @@fetch_status = 0
  Begin
    select @v_Line = @v_Line + 1
    --取得库存表中对应门店和仓位中商品的数量作为进/退货的数量
    Select @v_GdQty = Qty From INV
      Where Store = @v_UserGid and WRH = 1 and GdGid = @v_GdGid
    --若门店不存在该商品的库存,那么跳到下一个商品
    If (@v_GdQty Is Null) Or (@v_GdQty <= 0)
    Begin
      Fetch Next From C_Gd into @v_GdGid, @v_Wrh, @v_TaxRate, @v_Qpc

      Continue
    End
    --取得门店配货价
    exec GetStoreOutPrc @v_UserGid, @v_GdGid, @v_Wrh, @v_OutPrc output
    Select @v_InvQty = Isnull(AVLQTY, 0)
      from V_ALCINV(nolock)
    Where Gdgid = @v_GdGid and Wrh = @v_Wrh and Store = @v_UserGid
    if @v_InvQty is null
      Set @v_InvQty = 0
    If @v_Qpc = 0
      Set @v_Qpc = 1

    --插入一条明细
    Select @v_GenSql =
      'Insert Into ' + @v_TableNameD + '(Cls, Num, Line, Settleno, Gdgid, Cases, Qty, Price,
        Wsprc, Inprc, Rtlprc, Total, Tax, Wrh'
    If @PiGenType = 0
      Select @v_GenSql = @v_GenSql + ', Invqty'
    Select @v_GenSql = @v_GenSql +
      ') Values(''批发'', ''' + @v_Num + ''',' + Str(@v_Line) + ',' + Str(@v_SettleNo) + ',' + Str(@v_GdGid) + ','
        + Convert( Char, Convert(Decimal(20, 4), @v_GdQty / @v_Qpc) ) + ',' + Convert( Char, Convert(Decimal(20, 4), @v_GdQty) ) + ','
        + Convert( Char, Convert(Decimal(20, 4), @v_OutPrc) ) + ', 0, 0, 0, ' + Convert(Char, Convert(Decimal(20, 2), @v_GdQty * @v_OutPrc) )+ ','
        + Convert( Char, Convert(Decimal(20, 2), (@v_GdQty * @v_OutPrc * @v_TaxRate) / (100 + @v_TaxRate)) ) + ',' + Str(@v_Wrh)
    If @PiGenType = 0
      Select @v_GenSql = @v_GenSql + ','
        + Convert( Char, Convert(Decimal(20, 4), @v_InvQty) )
    Select @v_GenSql = @v_GenSql + ')'
    Exec(@v_GenSql)
    -- 更新 Stkoutdtl 中的Inprc,Rtlprc,Wsprc
    Exec(' UPDATE ' + @v_TableNameD
      + ' SET INPRC = B.Inprc, Rtlprc = B.Rtlprc, Wsprc = B.Whsprc
    FROM Stkoutdtl A, Goods B
    WHERE A.Gdgid = B.Gid And A.Num = ''' + @v_Num + ''' and A.Cls = ''批发'' ')

    --回写 缺省供应商调整单反馈明细
    If @PiGenType = 0
      Select @v_Note = '生成批发单号:' + @v_Num
    else
      Select @v_Note = '生成批发退单号:' + @v_Num
    UPDATE BILLTOADJFEEDBCKDTL
      SET STAT = 1, RTNNOTE = @v_Note
    WHERE Num = @PiNum and StoreGid = @v_UserGid and GdGid = @v_GdGid

    Fetch Next From C_Gd into @v_GdGid, @v_Wrh, @v_TaxRate, @v_Qpc
  End
  Close c_Gd
  Deallocate c_Gd

  --更新汇总表的Total Tax Reccnt字段
  If @PiGenType = 0
    select
      @v_Total = Isnull(Sum(Total), 0),
      @v_Tax = Isnull(Sum(Tax), 0),
      @v_Reccnt = Count(1)
    From Stkoutdtl(Nolock)
    Where Num = @v_Num And Cls = '批发'
  else
    select
      @v_Total = Isnull(Sum(Total), 0),
      @v_Tax = Isnull(Sum(Tax), 0),
      @v_Reccnt = Count(1)
    From StkoutBckdtl(Nolock)
    Where Num = @v_Num And Cls = '批发'
  if @v_Reccnt = 0
  begin
    Exec(' Delete From ' + @v_TableNameM + ' Where Num = ''' + @v_Num + ''' And Cls = ''批发'' ')
    Exec(' Delete From ' + @v_TableNameD + ' Where Num = ''' + @v_Num + ''' And Cls = ''批发'' ')

    Return 0
  end else
  begin
    Select @v_GenSql =
      ' Update Stkout Set
      Total = ' + Convert( Char, Convert(Decimal(20, 2), @v_Total) ) + ','
      + ' Tax = ' + Convert( Char, Convert(Decimal(20, 4), @v_Tax) ) + ','
      + ' Reccnt = ' + Str(@v_Reccnt)
      + ' Where Num = ''' + @v_Num + ''' And Cls = ''批发'' '
    Exec(@v_GenSql)
  end

  --审核生成的 直配/退 单据
  Declare @v_Ret SmallInt
  If @PiGenType = 0
  Begin
    Exec @v_Ret = STKOUTCHK '批发', @v_Num
    If @v_Ret <> 0
    Begin
      Select @v_Msg = '审核生成的批发单(' + @v_Num + ')出错'
      --更新缺省供应商调整单反馈明细状态为接收失败,并记录错误信息
      UPDATE BILLTOADJFEEDBCKDTL
        SET STAT = 3, RTNNOTE = @v_Msg
      WHERE Num = @PiNum and StoreGid = @v_UserGid
        and Exists(Select D.GdGid from StkoutDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = '批发' and Num = @v_Num)

      Return 1
    End
    --更新缺省供应商调整单反馈明细状态为已生效
    UPDATE BILLTOADJFEEDBCKDTL
      SET STAT = 2
    WHERE Num = @PiNum and StoreGid = @v_UserGid
      and Exists(Select D.GdGid from StkoutDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = '批发' and Num = @v_Num)
  End Else
  Begin
    Exec @v_Ret = STKOUTBCKCHK '批发', @v_Num
    If @v_Ret <> 0
    Begin
      Select @v_Msg = '审核生成的批发退单(' + @v_Num + ')出错'
      --更新缺省供应商调整单反馈明细状态为接收失败,并记录错误信息
      UPDATE BILLTOADJFEEDBCKDTL
        SET STAT = 3, RTNNOTE = @v_Msg
      WHERE Num = @PiNum and StoreGid = @v_UserGid
        and Exists(Select D.GdGid from StkoutBckDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = '批发' and Num = @v_Num)

      Return 1
    End
    --更新缺省供应商调整单反馈明细状态为已生效
    UPDATE BILLTOADJFEEDBCKDTL
      SET STAT = 2
    WHERE Num = @PiNum and StoreGid = @v_UserGid
      and Exists(Select D.GdGid from StkoutBckDtl D Where BILLTOADJFEEDBCKDTL.GdGid = D.GdGid and D.Cls = '批发' and Num = @v_Num)
  End

  Return 0
end
GO
