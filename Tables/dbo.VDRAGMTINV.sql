CREATE TABLE [dbo].[VDRAGMTINV]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VDRGID] [int] NOT NULL,
[STARTDATE] [datetime] NOT NULL CONSTRAINT [DF__VDRAGMTIN__START__47AC337C] DEFAULT (getdate()),
[FINISHDATE] [datetime] NOT NULL CONSTRAINT [DF__VDRAGMTIN__FINIS__48A057B5] DEFAULT (getdate()),
[LMODDATE] [datetime] NOT NULL CONSTRAINT [DF__VDRAGMTIN__LMODD__49947BEE] DEFAULT (getdate()),
[LMODOPID] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRAGMTIN__LMODO__4A88A027] DEFAULT ('未知[-]'),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BUYER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRAGMTIN__BUYER__4B7CC460] DEFAULT ('未知[-]'),
[ORGVISER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__VDRAGMTIN__RECCN__4C70E899] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRAGMTINV] ADD CONSTRAINT [PK__VDRAGMTINV__4D650CD2] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
