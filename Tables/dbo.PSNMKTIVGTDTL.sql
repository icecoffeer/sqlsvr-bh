CREATE TABLE [dbo].[PSNMKTIVGTDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[FLAG] [smallint] NULL CONSTRAINT [DF__PSNMKTIVGT__FLAG__70ACB261] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[OBJCODE] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OBJNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPECCODE] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPENAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ID] [int] NOT NULL,
[RCV] [int] NULL,
[SRC] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSNMKTIVGTDTL] ADD CONSTRAINT [PK__PSNMktIvgtDtl__71A0D69A] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [ID], [SRC]) ON [PRIMARY]
GO
