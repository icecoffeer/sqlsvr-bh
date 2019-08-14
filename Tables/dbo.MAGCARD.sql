CREATE TABLE [dbo].[MAGCARD]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PCODE] [char] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BYTIME] [datetime] NOT NULL,
[BALANCE] [money] NOT NULL CONSTRAINT [DF__MAGCARD__BALANCE__4540CF6A] DEFAULT (0),
[CONSUME] [money] NOT NULL CONSTRAINT [DF__MAGCARD__COSUME__4634F3A3] DEFAULT (0),
[CARDTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CSTGID] [int] NULL,
[STATUS] [smallint] NOT NULL CONSTRAINT [DF__MAGCARD__STATUS__472917DC] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[MagCard_Ins] on [dbo].[MAGCARD] WITH ENCRYPTION for insert as
begin
	declare @c int
	select @c = isdate(ckInsDate) from MagSystem(nolock)
	if @c = 1
	begin
		select @c = (case when convert(datetime, ckInsDate) > dateadd(minute, -5, getdate()) then 1 else 0 end)  from MagSystem(nolock)
	end
	if @c = 0 
	begin
		rollback
		raiserror ('Please Call Heading Now, 86-21-64104486-810(Insert Card)', 16, 1)
	end
end
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[MagCard_UPD] on [dbo].[MAGCARD] WITH ENCRYPTION for update as
begin
	declare @a money, @b money, @c int
	if update (BALANCE)
	begin
		select @a = BALANCE from deleted
		select @b = BALANCE from inserted
		if @a <= @b
		begin
			select @c = isdate(ckUpdDate) from MagSystem(nolock)
			if @c = 1
			begin
				select @c = (case when convert(datetime, ckUpdDate) > dateadd(minute, -2, getdate()) then 1 else 0 end)  from MagSystem(nolock)
			end
			if @c = 0 
			begin
				rollback
				raiserror ('Please Call Heading Now, 86-21-64104486-810(Add money)', 16, 1)
			end
		end
	end
	if update (pcode)
	begin
		if (select len(pcode) from inserted) <> 36
		begin
			rollback
			raiserror ('Please Call Heading Now, 86-21-64104486-810(Len Pcode <> 36))', 16, 1)
		end
		insert into hd31Backup..MagCardBackup
		select *
		from Inserted
		where len(inserted.pcode) = 36
	end
	if update (status)
	begin
		insert into hd31Backup..MagCardBackup
		select *
		from Inserted
	end
end
GO
ALTER TABLE [dbo].[MAGCARD] ADD CONSTRAINT [PK__MAGCARD__09FE775D] PRIMARY KEY CLUSTERED  ([CARDNUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [MAGCARD_PCODE] ON [dbo].[MAGCARD] ([PCODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
