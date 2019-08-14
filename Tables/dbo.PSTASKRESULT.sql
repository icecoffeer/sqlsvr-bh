CREATE TABLE [dbo].[PSTASKRESULT]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[ITEMNO] [int] NOT NULL,
[EXESTAT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PSTASKRES__EXEST__67F83C26] DEFAULT (0),
[LSTUPDTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSTASKRESULT] ADD CONSTRAINT [PK__PSTASKRESULT__68EC605F] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID], [ITEMNO]) ON [PRIMARY]
GO
