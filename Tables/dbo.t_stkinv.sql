CREATE TABLE [dbo].[t_stkinv]
(
[DATEID] [int] NOT NULL IDENTITY(1, 1),
[gdgid] [int] NOT NULL,
[OcrDate] [datetime] NULL,
[qty] [money] NULL,
[price] [money] NULL,
[Cls] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Num] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_stkinv] ADD CONSTRAINT [PK__t_stkinv__70D46D8E] PRIMARY KEY CLUSTERED  ([gdgid], [DATEID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
