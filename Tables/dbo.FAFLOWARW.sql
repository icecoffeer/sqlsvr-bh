CREATE TABLE [dbo].[FAFLOWARW]
(
[UUID] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[POSID] [int] NOT NULL,
[FATYPE] [int] NOT NULL,
[FWIDTH] [int] NOT NULL,
[FHEIGHT] [int] NOT NULL,
[FCOLOR] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAFLOWARW] ADD CONSTRAINT [PK__FAFLOWARW__3127F580] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO], [POSID]) ON [PRIMARY]
GO
