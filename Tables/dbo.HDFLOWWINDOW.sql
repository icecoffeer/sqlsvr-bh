CREATE TABLE [dbo].[HDFLOWWINDOW]
(
[MODULENO] [int] NOT NULL,
[OPTIONCAPTION] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPTIONVALUE] [text] COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HDFLOWWINDOW] ADD CONSTRAINT [PK__HDFLOWWINDOW__0946835D] PRIMARY KEY CLUSTERED  ([MODULENO], [OPTIONCAPTION]) ON [PRIMARY]
GO