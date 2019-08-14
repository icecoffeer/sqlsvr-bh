CREATE TABLE [dbo].[PSIVMTYPE]
(
[CODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (200) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PSIVMTYPE_CODE] ON [dbo].[PSIVMTYPE] ([CODE]) ON [PRIMARY]
GO
