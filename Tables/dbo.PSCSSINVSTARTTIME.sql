CREATE TABLE [dbo].[PSCSSINVSTARTTIME]
(
[NO] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BEGINDATE] [datetime] NULL,
[ENDDATE] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCSSINVSTARTTIME] ADD CONSTRAINT [PK__PSCSSINVSTARTTIM__16F32231] PRIMARY KEY CLUSTERED  ([NO], [STOREGID], [CLS]) ON [PRIMARY]
GO
