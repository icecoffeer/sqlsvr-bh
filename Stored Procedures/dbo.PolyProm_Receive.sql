SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PolyProm_Receive](
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
    @Cls char(10),
    @UserGid int,
    @Rcv int

  /*常用变量*/
  select @UserGid = USERGID from SYSTEM(nolock)

  /*检查*/
  select @Num = NUM, @Cls = CLS, @NetBillStat = STAT, @Rcv = RCV from NPOLYPROM(nolock) where SRC = @Src and ID = @ID
  if @Rcv <> @UserGid
  begin
    set @Msg = '接收单位非本单位，不能接收。'
    return 1
  end

  /*本地已存在相同单号，根据不同状态分别进行操作*/
  if exists(select NUM from POLYPROM(nolock) where NUM = @Num and CLS = @Cls)
  begin
    select @LocalBillStat = STAT from PolyProm(nolock) where NUM = @Num and CLS = @Cls
    if @LocalBillStat in (100, 800) and @NetBillStat in (1400)
    begin
      exec PolyProm_RemoveNetBill @Src, @ID
      exec @return_status = PolyProm_On_Modify @Num, @Cls, @NetBillStat, '接收过程', @Msg output
      return @return_status
    end
    else begin
      exec PolyProm_RemoveNetBill @Src, @ID
      return 0
    end
  end
  else if @NetBillStat not in (100, 800)
  begin
    exec PolyProm_RemoveNetBill @Src, @ID
    return 0
  end

  /*接收*/
  insert into POLYPROM(NUM, CLS, SETTLENO, STAT, FILDATE, FILLER, LSTUPDTIME, LSTUPDOPER,
    CHKDATE, CHECKER, SNDTIME, PRNTIME, NOTE, RECCNT, EXGDRECCNT, SCHMRECCNT, DLTPRICEPROM,
    CALBYRTLPRC, TOPIC, PSETTLENO, PRIORITY)
  select NUM, CLS, SETTLENO, 0, FILDATE, FILLER, LSTUPDTIME, LSTUPDOPER,
    CHKDATE, CHECKER, SNDTIME, PRNTIME, NOTE, RECCNT, EXGDRECCNT, SCHMRECCNT, DLTPRICEPROM,
    CALBYRTLPRC, TOPIC, PSETTLENO, PRIORITY
  from NPOLYPROM(nolock) where SRC = @Src and ID = @ID
  insert into POLYPROMRANGEDTL(NUM, CLS, LINE, DEPT, VENDOR, BRAND, ASTART, AFINISH, NOTE, PREC, ROUNDTYPE)
    select NUM, CLS, LINE, DEPT, VENDOR, BRAND, ASTART, AFINISH, NOTE, PREC, ROUNDTYPE
      from NPOLYPROMRANGEDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPROMEXGDDTL(NUM, CLS, LINE, GDGID, NOTE)
    select NUM, CLS, LINE, GDGID, NOTE
      from NPOLYPROMEXGDDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPROMTOTALSCHMDTL(NUM, CLS, LINE, LOWAMT, HIGHAMT, DISCOUNT, FAVAMT, NOTE)
    select NUM, CLS, LINE, LOWAMT, HIGHAMT, DISCOUNT, FAVAMT, NOTE
      from NPOLYPROMTOTALSCHMDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPROMQTYSCHMDTL(NUM, CLS, LINE, LOWQTY, HIGHQTY, DISCOUNT, FAVAMT, NOTE)
    select NUM, CLS, LINE, LOWQTY, HIGHQTY, DISCOUNT, FAVAMT, NOTE
      from NPOLYPROMQTYSCHMDTL(nolock) where SRC = @Src and ID = @ID
  insert into POLYPROMLACDTL(NUM, CLS, STOREGID)
    select @Num, @Cls, @UserGid

  /*审核*/
  exec @return_status = PolyProm_On_Modify @Num, @Cls, 100, '接收过程', @Msg output
  if @return_status <> 0 return @return_status

  /*删除网络表数据*/
  exec PolyProm_RemoveNetBill @Src, @ID

  return 0
end

GO
