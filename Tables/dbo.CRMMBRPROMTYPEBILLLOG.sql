CREATE TABLE [dbo].[CRMMBRPROMTYPEBILLLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[FROMSTAT] [smallint] NULL,
[TOSTAT] [smallint] NOT NULL,
[OPER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__CRMMBRPRO__OPERT__1CA50742] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMMBRPROMTYPEBILLLOG] ADD CONSTRAINT [PK__CRMMBRPROMTYPEBI__1D992B7B] PRIMARY KEY CLUSTERED  ([NUM], [ITEMNO]) ON [PRIMARY]
GO
