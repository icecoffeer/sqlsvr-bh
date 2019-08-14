CREATE TABLE [dbo].[CARD]
(
[GID] [int] NOT NULL,
[CODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PCODE] [char] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__NEW_CARD__CREATE__351F763A] DEFAULT (getdate()),
[VALIDDATE] [datetime] NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NEW_CARD__LSTUPD__36139A73] DEFAULT (getdate()),
[BALANCE] [money] NULL,
[CSTGID] [int] NOT NULL CONSTRAINT [DF__NEW_CARD__CSTGID__3707BEAC] DEFAULT (1),
[SRC] [int] NOT NULL CONSTRAINT [DF__NEW_CARD__SRC__37FBE2E5] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[CARDTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SALEDATE] [datetime] NOT NULL CONSTRAINT [DF__NEW_CARD__SALEDA__38F0071E] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__NEW_CARD__FILLER__39E42B57] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__NEW_CARD__MODIFI__3AD84F90] DEFAULT (1),
[STATE] [smallint] NOT NULL CONSTRAINT [DF__NEW_CARD__STATE__3BCC73C9] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create trigger [dbo].[CARD_DLT] on [dbo].[CARD] for delete as
begin
  if exists ( select * from deleted D, CARDTYPE T
    where D.CARDTYPE = T.NAME and D.balance <> 0 and T.CARDTYPE = '储值卡' )
  begin
    raiserror( '不能删除余额<>0的储值卡.', 16, 1)
    return
  end
end

GO
ALTER TABLE [dbo].[CARD] ADD CONSTRAINT [PK__CARD__2022C2A6] PRIMARY KEY CLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CARD] ADD CONSTRAINT [UQ__CARD__03DB89B3] UNIQUE NONCLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CARD] ADD CONSTRAINT [UQ__CARD__04CFADEC] UNIQUE NONCLUSTERED  ([PCODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
