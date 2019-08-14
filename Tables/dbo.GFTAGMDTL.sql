CREATE TABLE [dbo].[GFTAGMDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[START] [datetime] NOT NULL CONSTRAINT [DF__GFTAGMDTL__START__013FDF81] DEFAULT ('1899.12.30 00:00:00'),
[FINISH] [datetime] NOT NULL CONSTRAINT [DF__GFTAGMDTL__FINIS__023403BA] DEFAULT ('9999.12.31 23:59:59'),
[GDGID] [int] NOT NULL,
[INQTY] [money] NOT NULL,
[GFTGID] [int] NOT NULL,
[GFTQTY] [money] NOT NULL,
[GFTLINE] [smallint] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__GFTAGMDTL__STAT__032827F3] DEFAULT (0),
[LSTID] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[GFTWRH] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GFTAGMDTL] ADD CONSTRAINT [PK__GFTAGMDTL__7F57970F] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [GFTLINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [gftagm_gdgid] ON [dbo].[GFTAGMDTL] ([GDGID], [GFTGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GFTAGMDTL] ADD CONSTRAINT [在赠品协议里中商品赠品不能重复] UNIQUE NONCLUSTERED  ([NUM], [START], [FINISH], [GDGID], [GFTGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
