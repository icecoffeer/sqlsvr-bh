CREATE TABLE [dbo].[evendor]
(
[gid] [int] NOT NULL,
[flag] [int] NOT NULL CONSTRAINT [DF__evendor__flag__35DF5BA0] DEFAULT (0),
[lstupdtime] [datetime] NULL,
[addtime] [datetime] NULL,
[ISPAID] [smallint] NOT NULL CONSTRAINT [DF__EVENDOR__ISPAID__027CB799] DEFAULT (0)
) ON [PRIMARY]
GO
