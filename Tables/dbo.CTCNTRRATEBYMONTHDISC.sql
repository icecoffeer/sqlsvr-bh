CREATE TABLE [dbo].[CTCNTRRATEBYMONTHDISC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[RATE] [decimal] (24, 2) NOT NULL,
[LOWDATE] [datetime] NOT NULL,
[HIGHDATE] [datetime] NOT NULL,
[GAMT] [decimal] (24, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRRATEBYMONTHDISC] ADD CONSTRAINT [PK__CTCNTRRATEBYMONT__450FBDF3] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE], [ITEMNO]) ON [PRIMARY]
GO
