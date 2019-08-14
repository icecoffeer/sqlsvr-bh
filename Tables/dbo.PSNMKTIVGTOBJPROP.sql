CREATE TABLE [dbo].[PSNMKTIVGTOBJPROP]
(
[PROPCODE] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PROPNAME] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OBJCODE] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OBJNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VALUE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ID] [int] NOT NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NOT NULL,
[NTYPE] [int] NULL,
[NSTAT] [int] NULL,
[NNOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[RCVTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSNMKTIVGTOBJPROP] ADD CONSTRAINT [PK__PSNMKTIVGTOBJPRO__2AD953F6] PRIMARY KEY CLUSTERED  ([OBJCODE], [PROPCODE], [ID], [SRC]) ON [PRIMARY]
GO