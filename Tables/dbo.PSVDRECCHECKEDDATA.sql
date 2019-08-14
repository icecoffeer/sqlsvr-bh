CREATE TABLE [dbo].[PSVDRECCHECKEDDATA]
(
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PSVDRECCH__TOTAL__7A37B349] DEFAULT (0),
[SRCGID] [int] NOT NULL CONSTRAINT [DF__PSVDRECCH__SRCGI__7B2BD782] DEFAULT (0),
[SRCCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSVDRECCH__SRCCO__7C1FFBBB] DEFAULT ('-'),
[SRCNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSVDRECCH__SRCNA__7D141FF4] DEFAULT ('-'),
[VDRGID] [int] NOT NULL CONSTRAINT [DF__PSVDRECCH__VDRGI__7E08442D] DEFAULT (0),
[VDRCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSVDRECCH__VDRCO__7EFC6866] DEFAULT ('-'),
[VDRNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSVDRECCH__VDRNA__7FF08C9F] DEFAULT ('-'),
[STAT] [int] NOT NULL CONSTRAINT [DF__PSVDRECCHE__STAT__00E4B0D8] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSVDRECCHECKEDDATA] ADD CONSTRAINT [PK__PSVDRECCHECKEDDA__01D8D511] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [SRCGID], [TOTAL]) ON [PRIMARY]
GO
