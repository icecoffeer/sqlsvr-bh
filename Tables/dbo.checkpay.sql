CREATE TABLE [dbo].[checkpay]
(
[adate] [datetime] NOT NULL,
[gid] [int] NOT NULL,
[outqty] [money] NULL,
[outintotal] [money] NULL,
[outtotal] [money] NULL,
[vdrgid] [int] NOT NULL,
[adjinamt] [money] NOT NULL CONSTRAINT [DF__checkpay__adjina__6FD6F30B] DEFAULT (0),
[adjamt] [money] NOT NULL CONSTRAINT [DF__checkpay__adjamt__70CB1744] DEFAULT (0),
[xsintotal] [money] NULL,
[xstotal] [money] NULL,
[dq4] [money] NULL,
[dt4] [money] NULL,
[dt6] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[checkpay] ADD CONSTRAINT [PK__checkpay__6A276FFF] PRIMARY KEY CLUSTERED  ([adate], [gid], [vdrgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_checkpay] ON [dbo].[checkpay] ([adate], [vdrgid], [gid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
