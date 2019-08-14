CREATE TABLE [dbo].[POLYPRCPRMEXGDDTLOCR]
(
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[GDGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYPRCPRMEXGDDTLOCR] ADD CONSTRAINT [PK__POLYPRCPRMEXGDDT__4A9523CD] PRIMARY KEY CLUSTERED  ([BILLNUM], [BILLLINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_POLYPRCPRMEXGDDTLOCR_GDGID] ON [dbo].[POLYPRCPRMEXGDDTLOCR] ([BILLNUM], [GDGID]) ON [PRIMARY]
GO
