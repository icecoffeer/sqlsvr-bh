CREATE TABLE [dbo].[PRMOFFSETDEBIT]
(
[GDGID] [int] NOT NULL,
[STORE] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[DATE] [datetime] NOT NULL,
[SAMT] [decimal] (24, 2) NOT NULL,
[SQTY] [decimal] (24, 4) NOT NULL,
[RECAL] [int] NOT NULL CONSTRAINT [DF__PRMOFFSET__RECAL__549DB0F4] DEFAULT (0),
[SNDFLAG] [int] NOT NULL CONSTRAINT [DF__PRMOFFSET__SNDFL__5591D52D] DEFAULT (0),
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMOFFSETDE__CLS__5685F966] DEFAULT ('零售')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRMOFFSETDEBIT] ADD CONSTRAINT [PK__PRMOFFSETDEBIT__577A1D9F] PRIMARY KEY CLUSTERED  ([GDGID], [STORE], [DATE]) ON [PRIMARY]
GO
