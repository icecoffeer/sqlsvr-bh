CREATE TABLE [dbo].[SORTTALLYTYPE]
(
[SORT] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TALLYTYPE] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SORTTALLYTYPE] ADD CONSTRAINT [PK__SORTTALLYTYPE__3D0DDE21] PRIMARY KEY CLUSTERED  ([SORT], [TALLYTYPE]) ON [PRIMARY]
GO