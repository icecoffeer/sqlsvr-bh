CREATE TABLE [dbo].[TMPGFTSNDRULEGOODS]
(
[spid] [int] NOT NULL,
[GDGID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMPGFTSNDRULEGOODS_spid] ON [dbo].[TMPGFTSNDRULEGOODS] ([spid]) ON [PRIMARY]
GO
