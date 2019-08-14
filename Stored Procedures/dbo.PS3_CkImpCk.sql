SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PS3_CkImpCk] (
  @piPoolTable varchar(100), --Buypool中前台盘点数据表,形如:hd31buypool..CHECK_001
  @piPlatForm varchar(100), --数据来源,用于新的前台盘点支持
  @piPosNo varchar(10), --收银机号,用于新的前台盘点支持,可以为空
  @piToNum varchar(14), --导入后新生成的盘点单号
  @poMsg varchar(255) output --错误信息
)
As
Begin
  declare @PosNo char(10)
  declare @FlowNo char(13)
  declare @ItemNo smallint
  declare @inputer int
  declare @FilDate datetime
  declare @wrh int
  declare @gdgid int
  declare @qty money
  declare @total money
  declare @tag smallint
  --计算千帆等前台导入的盘点数据的金额
  declare @rtlprc money
  declare @vAmt money

  declare @counter int
  declare @errorCnt int
  declare @settleno int
  declare @note varchar(255)
  declare @vSql varchar(1000)

  declare @keptdate datetime
  declare @store int
  declare @twrh int

  declare @egid int
  declare @linkqty money
  declare @return_status int

  declare @deletesql varchar(1000)
  declare @updatesql varchar(1000)
  declare @posnocond varchar(100)
  declare @autochk int

  select @counter = 0, @errorCnt = 0
  select @settleno = Max(No) From MonthSettle
  --自动审核生成的盘点单选项
  Exec OptReadInt 196, 'PS3_AutoChk', 1, @autochk output

  Declare ACursorCheck Cursor Local for
    select POSNO, FLOWNO, ITEMNO, INPUTER, FILDATE, WRH, GDGID,
      QTY, AMOUNT, TAG
    from ##POSCHECK
      order by ITEMNO
  Open ACursorCheck
  Fetch Next From ACursorCheck into @PosNo, @FlowNo, @ItemNo, @Inputer,
    @FilDate, @wrh, @gdgid, @qty, @total, @tag
  If @@Fetch_Status = 0
  Begin
    if @piPlatForm = 'FG3'
      Set @note = '本盘点单由 ' + RTrim(@PosNo) + '号收银机' + RTrim(@FlowNo) + ' 生成'
    else
    begin
      Set @note = '本盘点单由 ' + RTrim(@piPlatForm)
      if @piPosNo <> '-1'
        Set @note = @note + ' 的 ' + RTrim(@PosNo) + '号收银机 '
      Set @note = @note + RTrim(@FlowNo) + ' 生成'
    end
    insert into PCK( Num, SettleNo, FilDate, Filler, Wrh, Stat, RecCnt, Note )
      values(@piToNum, @settleno, @FilDate, @inputer, @wrh, 0, 0, @note)
  End

  While ( @@Fetch_Status = 0 )
  Begin
    If (Select Ispkg From Goods Where Gid = @Gdgid) = 1
    begin
      exec @return_status = GETPKG @gdgid, @egid output, @linkqty output
      if @return_status <> 1 --未找到PKG
      begin
        fetch next from ACursorCheck into @PosNo, @FlowNo, @ItemNo, @Inputer,
          @FilDate, @wrh, @gdgid, @qty, @total, @tag
        continue
      end
    end
    if @piPlatForm <> 'FG3'
    begin
      --千帆等前台导入的盘点数据中,需要根据商品(核算售价*数量)计算下金额
      Select @rtlprc = RtlPrc From Goods(nolock) where gid = @gdgid
      Set @vAmt = @RtlPrc * @qty
      --删除语句及更新语句
      Set @posnocond = ' '
      if @piPosNo <> '-1'
        Set @posnocond = ' and PosNo = ''' + @piPosNo + ''''
        --修改标记为已导入
      set @deletesql = ' Update ' + @piPoolTable + ' set ImpStat = 1 where platform = ''' + @piPlatForm + ''' and itemno = ' + Str(@itemno)
        + @posnocond + ' and flowno = ''' + @FlowNo + ''''
        --修改标记为存在错误
      set @updatesql = ' update ' + @piPoolTable + ' set ImpStat = -1 where platform = ''' + @piPlatForm + ''' and itemno = ' + Str(@itemno)
        + @posnocond + ' and flowno = ''' + @FlowNo + ''''
    end else
    begin
      Set @vAmt = @total
      set @deletesql = ' delete from ' + @piPoolTable + ' where flowno = ''' + @FlowNo + ''' and itemno = ' + Str(@itemno)
      set @updatesql = ' update ' + @piPoolTable + ' set TAG = 1 where FlowNo = ''' + @FlowNo + ''' and itemno = ' + Str(@itemno)
    end

    if not exists( select * from PCKDTL where num = @piToNum and gdgid = @gdgid )
    begin
      if exists (select 1 from ckinv where wrh = @wrh and gdgid = @gdgid)
      begin
        select @counter = @counter + 1
        insert into PCKDTL( NUM, LINE, SETTLENO, STAT, GDGID, QTY, TOTAL )
          values( @piToNum, @counter, @settleno, 0, @gdgid, @qty, @vAmt )
        --删除BuyPool中的数据/或者标记PCKONLINE的数据为导入
        set @vSql = @deletesql
        Exec (@vSql)
      end else
      begin
        select @twrh = @wrh
        select @store = null
        select @store = gid from store where gid = @wrh
        if @store is null
          select @store = usergid from system
        else
          select @twrh = 1
        if not exists (select * from inv where wrh=@twrh and gdgid=@gdgid  and store = @store)
        begin --新品需要被盘入
          select @keptdate = getdate()
          Begin Try
            Exec @return_status = snapinv @wrh, @gdgid, 0, 0, @keptdate, 0,0,0,0
          End Try
          Begin Catch
            Select @poMsg = ERROR_MESSAGE(), @return_status = 1
          End Catch
          if @return_status <> 0
          begin
            --更新Pooltable的错误标记
            set @vSql = @updatesql
            Exec (@vSql)
            --错误计数
            Select @errorCnt = @errorCnt + 1
            fetch next from ACursorCheck into @PosNo, @FlowNo, @ItemNo, @Inputer,
              @FilDate, @wrh, @gdgid, @qty, @total, @tag
            continue
          end
          select @counter = @counter + 1
          insert into pckdtl( num, line, settleno, stat, gdgid, qty,  total)
            values(@piToNum, @counter, @settleno, 0, @gdgid, @qty, @vAmt)
          --删除BuyPool中的数据/或者标记PCKONLINE的数据为导入
          set @vSql = @deletesql
          Exec (@vSql)
        end --eles 情况下作为不盘点的情况
      end
    end else
    begin
      if @counter = 0
      begin
        set @poMsg = '记数器错误，应该是非零。'
        Return 1
      end
      update PCKDTL set
        QTY = QTY + @qty,
        TOTAL = TOTAL + @vAmt
      where NUM = @piToNum and GDGID = @gdgid
      --删除BuyPool中的数据/或者标记PCKONLINE的数据为导入
      set @vSql = @deletesql
      Exec (@vSql)
    end

    fetch next from ACursorCheck into @PosNo, @FlowNo, @ItemNo, @Inputer,
      @FilDate, @wrh, @gdgid, @qty, @total, @tag
  end
  close ACursorCheck
  deallocate ACursorCheck

  update PCK set RECCNT = @counter where NUM = @piToNum
  delete from PCK where num not in (select distinct num from PCKDTL)
  --当没有取到记录的时候，因为无法锁定单据pck，可能导致审核了别人的单据
  if (@counter > 0) and (@autochk = 1)
  begin
    Begin Try
      Exec @return_status = PCKCHK @piToNum
    End Try
    Begin Catch
      Select @poMsg = ERROR_MESSAGE(), @return_status = 1
    End Catch
    if @return_status <> 0
    begin
      set @poMsg = '调用审核盘点单过程(PCKCHK)失败:' + RTrim(@poMsg)
      return @return_status
    end
  end

  --clear the temp table ##POSCHECK
  delete from ##POSCHECK
  if @errorCnt > 0
  begin
    Set @poMsg = '存在新品盘入时库存快照失败.' + RTrim(@poMsg)
    Return 1
  end

  Return 0
end
GO
