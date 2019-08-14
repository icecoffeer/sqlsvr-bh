CREATE TABLE [dbo].[SubDeptByCode]
(
[spid] [int] NOT NULL,
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SubDeptByCode_spid] ON [dbo].[SubDeptByCode] ([spid]) ON [PRIMARY]
GO
