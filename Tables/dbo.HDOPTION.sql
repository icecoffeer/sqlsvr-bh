CREATE TABLE [dbo].[HDOPTION]
(
[MODULENO] [int] NOT NULL,
[OPTIONCAPTION] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPTIONVALUE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[OPTIONDEFAULT] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HDOPTION] ADD CONSTRAINT [PK__HDOPTION__0B686839] PRIMARY KEY CLUSTERED  ([MODULENO], [OPTIONCAPTION]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
