CREATE TABLE [dbo].[CTCNTRBRAND]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPE] [smallint] NOT NULL,
[STATUS] [smallint] NOT NULL,
[BEGINDATE] [datetime] NULL,
[ENDDATE] [datetime] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRBRAND] ADD CONSTRAINT [PK__CTCNTRBRAND__05601889] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [ITEMNO]) ON [PRIMARY]
GO
