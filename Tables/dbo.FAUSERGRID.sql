CREATE TABLE [dbo].[FAUSERGRID]
(
[USERGID] [int] NOT NULL,
[FRMNAME] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GRIDNAME] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETINFO] [text] COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAUSERGRID] ADD CONSTRAINT [PK__FAUSERGRID__5A35C362] PRIMARY KEY CLUSTERED  ([USERGID], [FRMNAME], [GRIDNAME]) ON [PRIMARY]
GO