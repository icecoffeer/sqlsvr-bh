SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_Send](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  declare
    @UserGid int,
    @StoreGid int,
    @ID int,
    @StoreCount int
  select @UserGid = USERGID from SYSTEM(nolock)
  select @StoreCount = Count(*) from POLYPRCPRMLACDTL(nolock)
    where NUM = @Num and STOREGID <> @UserGid
  if @StoreCount = 0
  begin
    set @Msg = '没有除本单位以外的生效单位，不能发送。'
    return 1
  end

  update POLYPRCPRM set SNDTIME = GetDate() where NUM = @Num

  declare c_PolyPrcPrmLacDtl cursor for
    select STOREGID from POLYPRCPRMLACDTL(nolock)
      where NUM = @Num and STOREGID <> @UserGid
  open c_PolyPrcPrmLacDtl
  fetch next from c_PolyPrcPrmLacDtl into @StoreGid
  while @@fetch_status = 0
  begin
    exec GetNetBillID @ID output
    insert into NPOLYPRCPRM(SRC, ID, RCV, RCVTIME, TYPE, NSTAT, NNOTE,
      NUM, SETTLENO, STAT, RECCNT, FILLER, FILDATE, LSTUPDOPER, LSTUPDTIME,
      CHECKER, CHKDATE, SNDTIME, PRNTIME, NOTE, TOPIC, PSETTLENO, OCRTYPE,
      OCRTIME, EXGDRECCNT, POLYPRIOR, PRIORITY)
    select @UserGid, @ID, @StoreGid, null, 0, 0, null,
      NUM, SETTLENO, STAT, RECCNT, FILLER, FILDATE, LSTUPDOPER, LSTUPDTIME,
      CHECKER, CHKDATE, SNDTIME, PRNTIME, NOTE, TOPIC, PSETTLENO, OCRTYPE,
      OCRTIME, EXGDRECCNT, POLYPRIOR, PRIORITY
    from POLYPRCPRM(nolock) where NUM = @Num
    insert into NPOLYPRCPRMDTL(SRC, ID, NUM, LINE, DEPT, VENDOR, BRAND, NOTE)
    select @UserGid, @ID, NUM, LINE, DEPT, VENDOR, BRAND, NOTE
      from POLYPRCPRMDTL(nolock) where NUM = @Num
    insert into NPOLYPRCPRMDTLDTL(SRC, ID, NUM, LINE, ITEM, START, FINISH,
      RTLPRCDISCNT, MBRPRCDISCNT, PREC, ROUNDTYPE)
    select @UserGid, @ID, NUM, LINE, ITEM, START, FINISH,
      RTLPRCDISCNT, MBRPRCDISCNT, PREC, ROUNDTYPE
    from POLYPRCPRMDTLDTL(nolock) where NUM = @Num
    insert into NPOLYPRCPRMEXGDDTL(SRC, ID, NUM, LINE, GDGID, NOTE)
    select @UserGid, @ID, NUM, LINE, GDGID, NOTE
      from POLYPRCPRMEXGDDTL(nolock) where NUM = @Num

    fetch next from c_PolyPrcPrmLacDtl into @StoreGid
  end
  close c_PolyPrcPrmLacDtl
  deallocate c_PolyPrcPrmLacDtl
  return 0
end
GO
