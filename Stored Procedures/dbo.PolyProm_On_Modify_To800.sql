SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_On_Modify_To800](
  @Num char(14),
  @Cls char(10),
  @ToStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @Present datetime,
    @Stat int,
    @StoreGid int

  /*常用变量*/
  set @Present = GetDate()

  /*检查*/
  select @Stat = STAT from POLYPROM(nolock) where NUM = @Num and CLS = @Cls
  if @Stat <> 100
  begin
    set @Msg = '不是已审核的单据，不能生效。'
    return 1
  end

  /*更新汇总信息*/
  update POLYPROM
    set STAT = @ToStat, LSTUPDOPER = @Oper, LSTUPDTIME = @Present
    where NUM = @Num and CLS = @Cls

  /*更新当前值表*/
  declare c_PolyPromLacDtl cursor for
    select STOREGID from POLYPROMLACDTL(nolock)
      where NUM = @Num and CLS = @Cls
  open c_PolyPromLacDtl
  fetch next from c_PolyPromLacDtl into @StoreGid
  while @@fetch_status = 0
  begin
    insert into POLYPROMOCR(STORE, CLS, BILLNUM, BILLLINE, DEPT, VENDOR, BRAND,
      ASTART, AFINISH, OCRTIME, DLTPRICEPROM, CALBYRTLPRC, PRIORITY, PREC, ROUNDTYPE)
    select @StoreGid, a.CLS, a.NUM, a.LINE, a.DEPT, a.VENDOR, a.BRAND,
      a.ASTART, a.AFINISH, @Present, b.DLTPRICEPROM, b.CALBYRTLPRC, b.PRIORITY, a.PREC, a.ROUNDTYPE
    from POLYPROMRANGEDTL a(nolock), POLYPROM b(nolock)
      where a.CLS = b.CLS and a.NUM = b.NUM
        and b.NUM = @Num and b.CLS = @Cls
    fetch next from c_PolyPromLacDtl into @StoreGid
  end
  close c_PolyPromLacDtl
  deallocate c_PolyPromLacDtl

  insert into POLYPROMEXGDDTLOCR(CLS, BILLNUM, BILLLINE, GDGID)
    select CLS, NUM, LINE, GDGID
    from POLYPROMEXGDDTL(nolock) where NUM = @Num and CLS = @Cls

  insert into POLYPROMTOTALSCHMDTLOCR(CLS, BILLNUM, BILLLINE, LOWAMT, HIGHAMT, DISCOUNT, FAVAMT)
    select CLS, NUM, LINE, LOWAMT, HIGHAMT, DISCOUNT, FAVAMT
    from POLYPROMTOTALSCHMDTL(nolock) where NUM = @Num and CLS = @Cls

  insert into POLYPROMQTYSCHMDTLOCR(CLS, BILLNUM, BILLLINE, LOWQTY, HIGHQTY, DISCOUNT, FAVAMT)
    select CLS, NUM, LINE, LOWQTY, HIGHQTY, DISCOUNT, FAVAMT
    from POLYPROMQTYSCHMDTL(nolock) where NUM = @Num and CLS = @Cls

  --更新促销单优先级数据
  Exec @return_status = PS3_UpdPromPir 'POLYPROM', @Cls, @Num, 'POLYPROMOCR', '组合'
  if @return_status <> 0
    return @return_status

  /*日志*/
  exec PolyProm_AddLog @Num, @Cls, @ToStat, '生效', @Oper

  return 0
end

GO
