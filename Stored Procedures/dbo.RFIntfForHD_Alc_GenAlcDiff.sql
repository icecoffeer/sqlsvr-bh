SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alc_GenAlcDiff]
(
  @strFiller int,
  @strErrMsg varchar(255) output    --返回错误信息，当返回值不等于0时有效
)
as
begin
  declare
    @num varchar(14),
    @alcNum varchar(14),
    @alcqty money,
    @recqty money,
    @diffQty money,
    @cases money,
    @line int,
    @settleno int,
    @rcnt int,
    @qpc money,
    @usergid int,
    @zbgid int,
    @gdgid int,
    @dtlwrh int

  /*在调用该过程之前，必须保证所有的RF设备都已经完成收货。此时，RF_RECGOODS 表中没有记录。*/

  if exists(select 1 from RF_RECGOODS(nolock))
  begin
    set @strErrMsg = '还有RF设备未结束收货。'
    return(1)
  end

  /*生成配货差异单汇总。*/

  select @settleno = max(NO) from MONTHSETTLE
  select @usergid = USERGID, @zbgid = ZBGID from SYSTEM
  exec GENNEXTBILLNUM '', 'ALCDIFF', @num output

  insert into ALCDIFF(NUM, SETTLENO, CLIENT, BILLTO, WRH,
    FILLER, FILDATE, REQOPER, REQDATE, CHECKER,
    CHKDATE, CANCELER, CACLDATE, LSTUPDTIME, STAT,
    NOTE, RECCNT, SNDTIME, PRNTIME, CAUSE,
    ATTITUDE, ALCFROM, GENNOTE, GENSTAT)
    select @num, @settleno, @usergid, @usergid, 1,
    @strFiller, getdate(), null, null, null,
    null, null, null, getdate(), 0,
    '由RF统配收货生成。', 0, null, null, '不明',
    0, @zbgid, null, 1

  if @@error <> 0
  begin
    set @strErrMsg = '插入配货差异单汇总时出错。'
    return(1)
  end

  /*生成配货差异单明细。*/

  set @line = 1
  declare c_AlcDiff cursor for
    select ra.ALCNUM, ra.GDGID, ra.ALCQTY, ra.RECQTY, g.QPC, g.WRH
    from RF_ALCGOODS ra(nolock), GOODS g(nolock)
    where ra.GDGID = g.GID
    and ra.ALCQTY <> ra.RECQTY
    order by ra.ALCNUM, ra.GDGID
  open c_AlcDiff
  fetch next from c_AlcDiff into
    @alcNum, @gdgid, @alcQty, @recqty, @qpc, @dtlwrh
  while @@fetch_status = 0
  begin
    set @diffQty = @recqty - @alcqty
    if @qpc is null or @qpc <= 0
      set @qpc = 1
    set @cases = round(@diffQty / @qpc, 3)

    insert into ALCDIFFDTL(NUM, LINE, GDGID, SRCNUM, CASES, QTY, WRH, NOTE)
      select @num, @line, @gdgid, @alcNum, @cases, @diffQty, @dtlwrh, null

    if @@error <> 0
    begin
      close c_AlcDiff
      deallocate c_AlcDiff
      set @strErrMsg = '插入配货差异单明细时出错。'
      return(1)
    end

    set @line = @line + 1
    fetch next from c_AlcDiff into
      @alcNum, @gdgid, @alcQty, @recqty, @qpc, @dtlwrh
  end
  close c_AlcDiff
  deallocate c_AlcDiff

  /*如果配货差异单明细（NUM=@NUM）没有记录，则删掉汇总。*/

  if exists(select 1 from ALCDIFFDTL(nolock) where NUM = @num)
  begin
    select @rcnt = count(1) from ALCDIFFDTL(nolock) where NUM = @num
    update ALCDIFF set
      RECCNT = @rcnt
      where NUM = @num
  end
  else begin
    delete from ALCDIFF where NUM = @num
  end

  /*清空RF配货收货表。*/

  delete from RF_ALCGOODS
  delete from RF_RECGOODS

  /*返回。*/

  if exists (select 1 from ALCDIFF(nolock) where NUM = @num)
  begin
    /*有配货差异单生成。*/

    return(0)
  end
  else begin
    /*没有配货差异单生成。*/

    return(2)
  end
end
GO
