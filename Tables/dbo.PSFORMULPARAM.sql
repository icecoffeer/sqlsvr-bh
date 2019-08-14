CREATE TABLE [dbo].[PSFORMULPARAM]
(
[CODE] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[PARAMNAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PARAMCNNAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[PARAMTYPE] [smallint] NOT NULL CONSTRAINT [DF__PSFORMULP__PARAM__6530DE14] DEFAULT (0),
[PARAMVALTAG] [smallint] NOT NULL CONSTRAINT [DF__PSFORMULP__PARAM__6625024D] DEFAULT (0),
[PARAMDESC] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSFORMULPARAM] ADD CONSTRAINT [PK__PSFORMULPARAM__67192686] PRIMARY KEY CLUSTERED  ([CODE], [ITEMNO]) ON [PRIMARY]
GO