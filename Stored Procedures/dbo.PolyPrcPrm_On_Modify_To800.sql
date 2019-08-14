SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_On_Modify_To800](
  @Num char(14),
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

  set @Present = GetDate()
  select @Stat = STAT from POLYPRCPRM(nolock) where NUM = @Num
  if @Stat <> 100
  begin
    set @Msg = '不是已审核的单据，不能生效。'
    return 1
  end
  update POLYPRCPRM
    set STAT = @ToStat, LSTUPDOPER = @Oper, LSTUPDTIME = @Present
    where NUM = @Num

  declare c_PolyPrcPrmLacDtl cursor for
    select STOREGID from POLYPRCPRMLACDTL(nolock)
      where NUM = @Num
  open c_PolyPrcPrmLacDtl
  fetch next from c_PolyPrcPrmLacDtl into @StoreGid
  while @@fetch_status = 0
  begin
    insert into POLYPRCPRMOCR(STOREGID, BILLNUM, BILLLINE, BILLITEM, TOPIC, PRI, OCRTIME,
      DEPT, VENDOR, BRAND, START, FINISH, RTLPRCDISCNT, MBRPRCDISCNT, PREC, ROUNDTYPE,
      POLYPRIOR, PRIORITY)
    select @StoreGid, c.NUM, c.LINE, c.ITEM, a.TOPIC, d.PRI, @Present,
      b.DEPT, b.VENDOR, b.BRAND, c.START, c.FINISH, c.RTLPRCDISCNT, c.MBRPRCDISCNT, c.PREC, c.ROUNDTYPE,
      a.POLYPRIOR, a.PRIORITY
    from POLYPRCPRM a(nolock), POLYPRCPRMDTL b(nolock), POLYPRCPRMDTLDTL c(nolock), PRMTOPIC d(nolock)
      where a.NUM = b.NUM and b.NUM = c.NUM and b.LINE = c.LINE and a.TOPIC = d.CODE
        and a.NUM = @Num

    fetch next from c_PolyPrcPrmLacDtl into @StoreGid
  end
  close c_PolyPrcPrmLacDtl
  deallocate c_PolyPrcPrmLacDtl

  insert into POLYPRCPRMEXGDDTLOCR(BILLNUM, BILLLINE, GDGID)
  select NUM, LINE, GDGID from POLYPRCPRMEXGDDTL(nolock) where NUM = @Num
  --更新促销单优先级数据
  Exec @return_status = PS3_UpdPromPir 'POLYPRCPRM', '', @Num, 'POLYPRCPRMOCR', '单品'
  if @return_status <> 0
    return @return_status

  exec PolyPrcPrm_AddLog @Num, @ToStat, '生效', @Oper
  return 0
end
GO
