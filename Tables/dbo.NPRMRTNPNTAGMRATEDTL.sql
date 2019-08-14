CREATE TABLE [dbo].[NPRMRTNPNTAGMRATEDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[LOWAMT] [money] NOT NULL CONSTRAINT [DF__NPRMRTNPN__LOWAM__277604C2] DEFAULT (0),
[HIGHAMT] [money] NOT NULL CONSTRAINT [DF__NPRMRTNPN__HIGHA__286A28FB] DEFAULT (99999999),
[RATE] [money] NOT NULL CONSTRAINT [DF__NPRMRTNPNT__RATE__295E4D34] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPRMRTNPNTAGMRATEDTL] ADD CONSTRAINT [PK__NPRMRTNPNTAGMRAT__2A52716D] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO