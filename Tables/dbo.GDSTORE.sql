CREATE TABLE [dbo].[GDSTORE]
(
[STOREGID] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[BILLTO] [int] NULL,
[SALE] [smallint] NULL,
[RTLPRC] [money] NULL,
[INPRC] [money] NULL,
[LOWINV] [money] NULL,
[HIGHINV] [money] NULL,
[PROMOTE] [smallint] NULL CONSTRAINT [DF__GDSTORE__PROMOTE__3BABACE1] DEFAULT ((-1)),
[GFT] [smallint] NULL CONSTRAINT [DF__GDSTORE__GFT__3C9FD11A] DEFAULT (0),
[LWTRTLPRC] [money] NULL CONSTRAINT [DF__GDSTORE__LWTRTLP__3D93F553] DEFAULT (0),
[MBRPRC] [money] NULL CONSTRAINT [DF__GDSTORE__MBRPRC__3E88198C] DEFAULT (0),
[DXPRC] [money] NULL CONSTRAINT [DF__GDSTORE__DXPRC__3F7C3DC5] DEFAULT (0),
[PAYRATE] [money] NULL CONSTRAINT [DF__GDSTORE__PAYRATE__407061FE] DEFAULT (0),
[ISLTD] [smallint] NULL CONSTRAINT [DF__GDSTORE__ISLTD__41648637] DEFAULT (0),
[CNTINPRC] [money] NULL,
[BQtyPrc] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[ALC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TopRtlPrc] [money] NULL,
[ALCQTY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GDSTORE__ALCQTY__3B84BD0B] DEFAULT (1),
[INVLOWBOUND] [money] NULL,
[INVHIGHBOUND] [money] NULL,
[SUGGESTEDQTYLOWBOUND] [money] NULL,
[SUGGESTEDQTYHIGHBOUND] [money] NULL,
[SUGGESTEDQTY] [money] NOT NULL CONSTRAINT [DF__GDSTORE__SUGGEST__6EEF5278] DEFAULT (0),
[ORDQTYMIN] [money] NULL,
[ALCCTR] [int] NULL,
[SALCQTY] [int] NULL,
[SALCQSTART] [int] NULL,
[TAXSORT] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[GDSTORE_DEL] on [dbo].[GDSTORE] for delete as
begin
  delete from PRICE from deleted
    where PRICE.STOREGID = deleted.STOREGID
    and PRICE.GDGID = deleted.GDGID
    
  if (select singlevdr from system) = 2
  	and exists(select 1 from HDOPTION (nolock)
    	where MODULENO = 97 and OPTIONCAPTION = '关心店' and OPTIONVALUE = 1)--Add By Wang xin 2002-05-15
    delete from VDRGD2 
    from deleted 
    where VDRGD2.STOREGID = deleted.STOREGID 
    and VDRGD2.GDGID = deleted.GDGID
    
  if exists(select 1 from deleted where Alc = '直配')
    if exists(select 1 from HDOPTION (nolock)
    	where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1) 
    begin
      delete ECGDVDRSEND from deleted
        where ECGDVDRSEND.GDGID = deleted.GDGID 
          and ECGDVDRSEND.STOREGID = deleted.STOREGID
      --insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
        --select a.STOREGID, a.BILLTO, a.GDGID, 1 from deleted a
      insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
        select a.STOREGID, g.BILLTO, a.GDGID, 0 
        from deleted a, goods g(nolock) where a.gdgid = g.gid
        and a.ALC = '直配'
  	end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[GDSTORE_INS] on [dbo].[GDSTORE] for insert as
begin
  declare @usergid int, @newstore int, @gdgid int, @promote smallint
  declare @alc varchar(20)
  
  select @usergid = USERGID from SYSTEM

  declare cursor1 cursor for
  select STOREGID, GDGID, PROMOTE from inserted
  for read only
  open cursor1
  fetch next from cursor1 into @newstore, @gdgid, @promote
  while @@FETCH_STATUS = 0
  begin
    if @promote <> -1
    begin
      if (select count(1) from PRICE
        where STOREGID = @usergid and GDGID = @gdgid
        and FINISH > getdate()) <> 0
        update GDSTORE set PROMOTE = -1
          where STOREGID = @usergid and GDGID = @gdgid
      else
        insert into PRICE (STOREGID, GDGID, START, FINISH, CYCLE,
          CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT,
          GFTGID, GFTQTY, GFTPER, GFTTYPE, INPRC, MBRPRC)
          select @newstore, GDGID, START, FINISH, CYCLE,
            CSTART, CFINISH, CSPEC, QTYLO, QTYHI, PRICE, DISCOUNT,
            GFTGID, GFTQTY, GFTPER, GFTTYPE, INPRC, MBRPRC
            from PRICE
            where STOREGID = @usergid and GDGID = @gdgid
            and FINISH > getdate()
    end
    fetch next from cursor1 into @newstore, @gdgid, @promote
  end
  close cursor1
  deallocate cursor1
--Added By Wang Xin 2002-05-12 
  if (select singlevdr from system) = 2
  begin
    if exists(select 1 from HDOPTION (nolock)
    	where MODULENO = 97 and OPTIONCAPTION = '关心店' and OPTIONVALUE = 1)--Add By Wang xin 2002-05-15
    begin
      insert into VDRGD2 (STOREGID, VDRGID, GDGID)
      select STOREGID, BILLTO, GDGID from inserted
      where not exists (select 1 from VDRGD2 
        where GDGID = inserted.GDGID 
        and STOREGID = inserted.STOREGID 
        and VDRGID = inserted.BILLTO)
        and exists (select 1 from VDRGD2
        where GDGID = inserted.GDGID 
        and STOREGID = inserted.STOREGID)
    end
  end
  --2005.12.19 增加发送到EC内容
  if exists(select 1 from inserted where Alc = '直配')
    if exists(select 1 from HDOPTION (nolock)
    	where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1) 
    begin
      delete ECGDVDRSEND from inserted
        where ECGDVDRSEND.GDGID = inserted.GDGID 
          and ECGDVDRSEND.STOREGID = inserted.STOREGID
      insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
        select a.STOREGID, a.BILLTO, a.GDGID, 0 from inserted a
        where a.ALC = '直配'
  	end
  --added by zz 07.12.28  
      if exists (select 1 from inserted where SAlcQty = '') return
      if exists (select 1 from inserted where (floor(SAlcQty / AlcQty) * AlcQty <> SAlcQty) or (SAlcQty <= AlcQty))
      begin
  	    rollback transaction
  	    raiserror('第二配货单位必须大于配货单位，且是配货单位的整数倍', 16, 1)
  	    return
      end
    
      if exists (select 1 from inserted where SAlcQStart = '') return
      if exists (select 1 from inserted where SAlcQStart < AlcQty)
      begin
  	    rollback transaction
    	  raiserror('取整起始数必须大于等于配货单位', 16, 1)
    	  return
      end
  --added end
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[GDSTORE_UPD] on [dbo].[GDSTORE] for update as
begin
  if update(BILLTO)
  	and (select SINGLEVDR from SYSTEM) = 2
  begin
    if exists(select 1 from HDOPTION (nolock)
    	where MODULENO = 97 and OPTIONCAPTION = '关心店' and OPTIONVALUE = 1)    --Add By Wang xin 2002-05-15
    begin
      insert into VDRGD2 (STOREGID, VDRGID, GDGID)
      select STOREGID, BILLTO, GDGID from inserted
      where not exists (select 1 from VDRGD2 
        where GDGID = inserted.GDGID 
        and STOREGID = inserted.STOREGID 
        and VDRGID = inserted.BILLTO) 
        and exists (select 1 from VDRGD2
        where GDGID = inserted.GDGID 
        and STOREGID = inserted.STOREGID)
    end
  end
  if update(BILLTO)
  begin
    if exists(select 1 from inserted where Alc = '直配')
    begin
      if exists(select 1 from HDOPTION (nolock)
      	where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1) 
	    begin
        delete ECGDVDRSEND from inserted
          where ECGDVDRSEND.GDGID = inserted.GDGID 
            and ECGDVDRSEND.STOREGID = inserted.STOREGID
            --and a.ALC = '直配'
        insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
          select a.STOREGID, a.BILLTO, a.GDGID, 0 from inserted a
          where a.ALC = '直配'
			end
		end
  end
  if update(ALC)
  begin
    if exists(select 1 from deleted where Alc = '直配') 
      and exists(select 1 from inserted where Alc <> '直配')
    begin
      if exists(select 1 from HDOPTION (nolock)
      	where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1) 
	    begin
        delete ECGDVDRSEND from deleted a
          where ECGDVDRSEND.GDGID = a.GDGID 
            and ECGDVDRSEND.STOREGID = a.STOREGID
            --and a.ALC = '直配'
        insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
          select a.STOREGID, a.BILLTO, a.GDGID, 1 from deleted a
          where a.ALC = '直配'
			end
		end
    else if exists(select 1 from deleted where Alc <> '直配') 
        and exists(select 1 from inserted where Alc = '直配')
    begin
      if exists(select 1 from HDOPTION (nolock)
      	where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1) 
	    begin
        delete ECGDVDRSEND from inserted a
          where ECGDVDRSEND.GDGID = a.GDGID 
            and ECGDVDRSEND.STOREGID = a.STOREGID
            --and a.ALC = '直配'
        insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
          select a.STOREGID, a.BILLTO, a.GDGID, 0 from inserted a
          where a.ALC = '直配'
			end
		end
  end
  
  --added by zz 07.12.28  
    if update(SAlcQty)
    begin
      if exists (select 1 from inserted where SAlcQty = '') return
      if exists (select 1 from inserted where (floor(SAlcQty / AlcQty) * AlcQty <> SAlcQty) or (SAlcQty <= AlcQty))
      begin
  	    rollback transaction
  	    raiserror('第二配货单位必须大于配货单位，且是配货单位的整数倍', 16, 1)
  	    return
      end
    end
    
    if update(SAlcQStart)
    begin
      if exists (select 1 from inserted where SAlcQStart = '') return
      if exists (select 1 from inserted where SAlcQStart < AlcQty)
      begin
  	    rollback transaction
    	  raiserror('取整起始数必须大于等于配货单位', 16, 1)
    	  return
      end
    end
  --added end
  
end
GO
ALTER TABLE [dbo].[GDSTORE] ADD CONSTRAINT [PK__GDSTORE__63D8CE75] PRIMARY KEY CLUSTERED  ([GDGID], [STOREGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
