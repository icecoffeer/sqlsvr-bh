CREATE TABLE [dbo].[fifo_stkinv]
(
[gdgid] [int] NOT NULL,
[OcrDate] [datetime] NOT NULL,
[DATEID] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[qty] [money] NOT NULL,
[price] [money] NOT NULL,
[Cls] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fifo_stkinv] ADD CONSTRAINT [PK__fifo_stkinv__595B4002] PRIMARY KEY CLUSTERED  ([gdgid], [DATEID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fifo_stkinv_inx] ON [dbo].[fifo_stkinv] ([gdgid], [OcrDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
