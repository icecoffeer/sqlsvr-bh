SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_GenPck](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vCmd varchar(8000),
    @vUserGid int,
    @vEmpGid int,
    @vNum char(10),
    @vLine int,
    @vSettleNo int,
    @vFilDate datetime,
    @vNote varchar(100),
    @vUUID varchar(32),
    @vWrh int,
    @vSubWrh varchar(64),
    @vLastWrh int,
    @vLastSubWrh varchar(64),
    @vGdGid int,
    @vGdCode varchar(13),
    @vGdName varchar(50),
    @vQty decimal(24,4),
    @vRtlPrc decimal(24,4),
    @vTotal decimal(24,4),
    @vInvPrc decimal(24,4),
    @vIsPkg int,
    @vEGid int,
    @vMultiple decimal(24,4),
    @vDtlGid int, --插入PCKDTL的商品内码
    @vDtlQty decimal(24,4), --插入PCKDTL的商品数量
    @vAutoSnapInv int, --选项，是否自动做盘点库存记录
    @vAllowNegQty int --选项，门店实盘数是否允许为负

  --公共变量初始化
  select @vUserGid = USERGID from SYSTEM(nolock)
  select @vEmpGid = GID from EMPLOYEE(nolock) where CODE = @piEmpCode
  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vFilDate = GetDate()

  --读取选项
  exec OptReadInt 8146, 'Inv_Ck_Auto_Snap_Inv', 0, @vAutoSnapInv output
  exec OptReadInt 17, 'AllowNegQty', 1, @vAllowNegQty output

  --缓存没有数据则返回
  if not exists(select * from RFPCK(nolock) where FILLER = @vEmpGid)
  begin
    set @poErrMsg = '缓存中没有数据。'
    return 1
  end

  --清空生成单据表
  delete from RFPCKGENBILLS where SPID = @@spid

  --声明游标
  if exists(select * from master..syscursors where cursor_name = 'c_RFPCk')
    deallocate c_RFPCk
  set @vCmd = 'declare c_RFPCk cursor for' +
    ' select UUID, WRH, SUBWRH, GDGID, QTY' +
    ' from RFPCK(nolock)' +
    ' where FILLER = ' + convert(varchar, @vEmpGid)
  if @vAllowNegQty = 1
    set @vCmd = @vCmd + ' and QTY <> 0'
  else
    set @vCmd = @vCmd + ' and QTY > 0'
  set @vCmd = @vCmd + ' order by WRH, SUBWRH, GDGID'
  execute(@vCmd)

  --生成单据
  set @return_status = 0
  set @vLastWrh = -1
  set @vLastSubWrh = '-1';
  set @vNum = ''
  open c_RFPCk
  fetch next from c_RFPCk into @vUUID, @vWrh, @vSubWrh, @vGdGid, @vQty
  while @@fetch_status = 0
  begin
    set @vDtlGid = @vGdGid
    set @vDtlQty = @vQty
    --大小包装转换
    select @vIsPkg = ISPKG from GOODS(nolock) where GID = @vGdGid
    if @vIsPkg = 1
    begin
      exec @return_status = GetPkg @vGdGid, @vEGid output, @vMultiple output
      if @return_status = 1
      begin
        update RFPCK set NOTE = '基本商品内码：' + convert(varchar, @vEGid) +
          '，关联数量：' + convert(varchar, @vMultiple)
          where UUID = @vUUID
        set @vDtlGid = @vEGid
        set @vDtlQty = @vQty * @vMultiple
        /*过程GetPkg的返回值为1时，表示执行成功。对当前过程来说，返回值为0表示
        执行成功。因此此处须将@return_status改回为0，以免当前过程在执行成功时将
        1作为正确的返回值返回，而使得客户端误解。*/
        set @return_status = 0
      end
    end
    --检查合法性，包括没有做快照、没有进销存记录
    if not exists(select * from CKINV(nolock) where WRH = @vWrh and GDGID = @vDtlGid)
    begin
      select @vGdCode = CODE, @vGdName = NAME from GOODS(nolock) where GID = @vDtlGid
      if @vAutoSnapInv = 1 or not exists(select * from INV(nolock)
        where STORE = @vUserGid and WRH = @vWrh and GDGID = @vDtlGid)
      begin
        execute @return_status = SnapInv @vWrh, @vDtlGid, 0, 0, @vFilDate, 0, 0, 0, 0
        if @return_status <> 0
        begin
          set @poErrMsg = '商品' + rtrim(@vGdName) + '[' + rtrim(@vGdCode) + ']'
          + '未发生过进销存记录。在执行过程SnapInv时发生错误。'
          goto LABEL_AFTER_LOOP
        end
      end
      else begin
        set @poErrMsg = '商品' + rtrim(@vGdName) + '[' + rtrim(@vGdCode) + ']'
          + '库存记录未做。请做完库存记录。'
        set @return_status = 1
        goto LABEL_AFTER_LOOP
      end
    end
    --判断是否需要分单
    if @vLastWrh <> @vWrh or @vLastSubWrh <> @vSubWrh
    begin
      --抢占单号
      exec PCKGetNextFlowNo @vNum output
      --备注
      set @vNote = '由RF盘点生成。货架位：' + case when isnull(@vSubWrh, '') = '' then '空' else @vSubWrh end + '。'
      --插入新单
      insert into PCK(NUM, SETTLENO, FILDATE, FILLER, WRH,
        STAT, RECCNT, NOTE)
        values(@vNum, @vSettleNo, @vFilDate, @vEmpGid, @vWrh,
          0, 0, @vNote)
      set @vLine = 0
      set @vLastWrh = @vWrh
      set @vLastSubWrh = @vSubWrh
      --插入生成单据表
      insert into RFPCKGENBILLS(SPID, BILLNAME, NUM)
        values(@@spid, '盘点单', @vNum)
    end
    --取单号失败则跳出
    if @vNum = ''
    begin
      set @poErrMsg = '取单号失败。'
      set @return_status = 1
      goto LABEL_AFTER_LOOP
    end
    --插入明细
    set @vLine = @vLine + 1
    select @vRtlPrc = RTLPRC from GOODS(nolock)
      where GID = @vDtlGid
    set @vTotal = round(@vRtlPrc * @vDtlQty, 2)
    exec GetGoodsInvPrc @vDtlGid, @vWrh, @vInvPrc output
    insert into PCKDTL(NUM, LINE, SETTLENO, STAT, GDGID,
      QTY, TOTAL, CKNUM, CKLINE, SUBWRH, INPRC)
      values(@vNum, @vLine, @vSettleNo, 0, @vDtlGid,
        @vDtlQty, @vTotal, null, null, null, @vInvPrc)
    --更新GENNUM,GENCLS
    update RFPCK set GENNUM = @vNum, GENCLS = '盘点单'
      where UUID = @vUUID

    fetch next from c_RFPCk into @vUUID, @vWrh, @vSubWrh, @vGdGid, @vQty
  end
LABEL_AFTER_LOOP:
  close c_RFPCk
  deallocate c_RFPCk
  if @return_status is null or @return_status <> 0
    return @return_status

  return 0
end
GO
