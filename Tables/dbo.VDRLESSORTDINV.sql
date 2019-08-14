CREATE TABLE [dbo].[VDRLESSORTDINV]
(
[VDRGID] [int] NOT NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PAYRATE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRLESSOR__PAYRA__792DB520] DEFAULT (0),
[SHOPNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRLESSORTDINV] ADD CONSTRAINT [PK__VDRLESSORTDINV__7A21D959] PRIMARY KEY CLUSTERED  ([VDRGID], [SORT]) ON [PRIMARY]
GO