SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyPrcPrm_Receive](
  @Src int,
  @ID int,
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @NetBillStat int,
    @LocalBillStat int,
    @Num char(14),
    @UserGid int,
    @Rcv int
  select @UserGid = USERGID from SYSTEM(nolock)
  select @Num = NUM, @NetBillStat = STAT, @Rcv = RCV from NPOLYPRCPRM(nolock) where SRC = @Src and ID = @ID
  if @Rcv <> @UserGid
  begin
    set @Msg = '接收单位非本单位，不能接收。'
    return 1
  end
  if exists(select NUM from POLYPRCPRM(nolock) where NUM = @Num)
  begin
    select @LocalBillStat = STAT from POLYPRCPRM(nolock) where NUM = @Num
    if @LocalBillStat in (100, 800) and @NetBillStat in (110, 1400)
    begin
      exec PolyPrcPrm_RemoveNetBill @Src, @ID
      exec @return_status = PolyPrcPrm_On_Modify @Num, @NetBillStat, '接收过程', @Msg output
      return @return_status
    end
    else begin
      exec PolyPrcPrm_RemoveNetBill @Src, @ID
      return 0
    end
  end
  insert into POLYPRCPRM(NUM, SETTLENO, STAT, RECCNT, FILLER, FILDATE,
    LSTUPDOPER, LSTUPDTIME, CHECKER, CHKDATE, SNDTIME, PRNTIME, NOTE,
    TOPIC, PSETTLENO, OCRTYPE, OCRTIME, EXGDRECCNT, POLYPRIOR, PRIORITY)
  select NUM, SETTLENO, 0, RECCNT, FILLER, FILDATE,
    LSTUPDOPER, LSTUPDTIME, CHECKER, CHKDATE, SNDTIME, PRNTIME, NOTE,
    TOPIC, PSETTLENO, OCRTYPE, OCRTIME, EXGDRECCNT, POLYPRIOR, PRIORITY
  from NPOLYPRCPRM(nolock) where SRC = @Src and ID = @ID
  insert into POLYPRCPRMDTL(NUM, LINE, DEPT, VENDOR, BRAND, NOTE)
  select NUM, LINE, DEPT, VENDOR, BRAND, NOTE
    from NPOLYPRCPRMDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPRCPRMDTLDTL(NUM, LINE, ITEM, START, FINISH,
    RTLPRCDISCNT, MBRPRCDISCNT, PREC, ROUNDTYPE)
  select NUM, LINE, ITEM, START, FINISH,
    RTLPRCDISCNT, MBRPRCDISCNT, PREC, ROUNDTYPE
  from NPOLYPRCPRMDTLDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPRCPRMEXGDDTL(NUM, LINE, GDGID, NOTE)
  select NUM, LINE, GDGID, NOTE
    from NPOLYPRCPRMEXGDDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPRCPRMLACDTL(NUM, STOREGID)
  select @Num, @UserGid
  exec @return_status = PolyPrcPrm_On_Modify @Num, 100, '接收过程', @Msg output
  if @return_status <> 0 return @return_status
  exec PolyPrcPrm_RemoveNetBill @Src, @ID

  return 0
end
GO
