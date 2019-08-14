CREATE TABLE [dbo].[T_ZBParamValue]
(
[spid] [int] NOT NULL,
[ParamName] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[ParamValue] [varchar] (120) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_T_ZBParamValue_spid] ON [dbo].[T_ZBParamValue] ([spid]) ON [PRIMARY]
GO
