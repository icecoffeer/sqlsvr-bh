CREATE TABLE [dbo].[RFBILLLOG]
(
[RFNUM] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[TIME] [datetime] NOT NULL CONSTRAINT [DF__RFBILLLOG__TIME__46EC4E16] DEFAULT (getdate()),
[OPER] [int] NOT NULL,
[STAT] [int] NOT NULL CONSTRAINT [DF__RFBILLLOG__STAT__47E0724F] DEFAULT (0),
[NOTE] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFBILLLOG] ADD CONSTRAINT [PK__RFBILLLOG__48D49688] PRIMARY KEY CLUSTERED  ([RFNUM], [ITEMNO]) ON [PRIMARY]
GO
