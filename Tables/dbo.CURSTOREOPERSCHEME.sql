CREATE TABLE [dbo].[CURSTOREOPERSCHEME]
(
[STOREGID] [int] NOT NULL,
[SORTCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[ISOPER] [int] NOT NULL,
[ISNECESSARY] [int] NOT NULL,
[ISZB] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CURSTOREOPERSCHEME] ON [dbo].[CURSTOREOPERSCHEME] ([STOREGID], [GDGID]) ON [PRIMARY]
GO
