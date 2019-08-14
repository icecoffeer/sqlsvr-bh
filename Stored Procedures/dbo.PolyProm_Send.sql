SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_Send](
  @Num char(14),
  @Cls char(10),
  @Msg varchar(255) output
)
as
begin
  declare
    @UserGid int,
    @StoreGid int,
    @ID int,
    @StoreCount int

  /*常用变量*/
  select @UserGid = USERGID from SYSTEM(nolock)

  /*检查*/
  select @StoreCount = Count(*) from POLYPROMLACDTL(nolock)
    where NUM = @Num and CLS = @Cls and STOREGID <> @UserGid
  if @StoreCount = 0
  begin
    set @Msg = '没有除本单位以外的生效单位，不能发送。'
    return 1
  end

  /*更新汇总信息*/
  update PolyProm set SNDTIME = GetDate() where NUM = @Num and CLS = @Cls

  /*更新网络表*/
  declare c_PolyPromLacDtl cursor for
    select STOREGID from POLYPROMLACDTL(nolock)
      where NUM = @Num and CLS = @Cls and STOREGID <> @UserGid
  open c_PolyPromLacDtl
  fetch next from c_PolyPromLacDtl into @StoreGid
  while @@fetch_status = 0
  begin
    exec GetNetBillID @ID output
    insert into NPOLYPROM(SRC, ID, RCV, RCVTIME, TYPE, NSTAT, NNOTE,
      NUM, CLS, SETTLENO, STAT, FILDATE, FILLER, LSTUPDTIME, LSTUPDOPER,
      CHKDATE, CHECKER, SNDTIME, PRNTIME, NOTE, RECCNT, EXGDRECCNT,
      SCHMRECCNT, DLTPRICEPROM, CALBYRTLPRC, TOPIC, PSETTLENO, PRIORITY)
    select @UserGid, @ID, @StoreGid, null, 0, 0, null,
      NUM, CLS, SETTLENO, STAT, FILDATE, FILLER, LSTUPDTIME, LSTUPDOPER,
      CHKDATE, CHECKER, SNDTIME, PRNTIME, NOTE, RECCNT, EXGDRECCNT,
      SCHMRECCNT, DLTPRICEPROM, CALBYRTLPRC, TOPIC, PSETTLENO, PRIORITY
    from POLYPROM(nolock) where NUM = @Num and CLS = @Cls
    insert into NPOLYPROMRANGEDTL(SRC, ID, NUM, CLS, LINE, DEPT, VENDOR, BRAND, ASTART, AFINISH, NOTE, PREC, ROUNDTYPE)
      select @UserGid, @ID, NUM, CLS, LINE, DEPT, VENDOR, BRAND, ASTART, AFINISH, NOTE, PREC, ROUNDTYPE
        from POLYPROMRANGEDTL(nolock) where NUM = @Num and CLS = @Cls
    insert into NPOLYPROMEXGDDTL(SRC, ID, NUM, CLS, LINE, GDGID, NOTE)
      select @UserGid, @ID, NUM, CLS, LINE, GDGID, NOTE
        from POLYPROMEXGDDTL(nolock) where NUM = @Num and CLS = @Cls
    insert into NPOLYPROMTOTALSCHMDTL(SRC, ID, NUM, CLS, LINE, LOWAMT, HIGHAMT, DISCOUNT, FAVAMT, NOTE)
      select @UserGid, @ID, NUM, CLS, LINE, LOWAMT, HIGHAMT, DISCOUNT, FAVAMT, NOTE
        from POLYPROMTOTALSCHMDTL(nolock) where NUM = @Num and CLS = @Cls
    insert into NPOLYPROMQTYSCHMDTL(SRC, ID, NUM, CLS, LINE, LOWQTY, HIGHQTY, DISCOUNT, FAVAMT, NOTE)
      select @UserGid, @ID, NUM, CLS, LINE, LOWQTY, HIGHQTY, DISCOUNT, FAVAMT, NOTE
        from POLYPROMQTYSCHMDTL(nolock) where NUM = @Num and CLS = @Cls
    fetch next from c_PolyPromLacDtl into @StoreGid
  end
  close c_PolyPromLacDtl
  deallocate c_PolyPromLacDtl

  return 0
end

GO
