CREATE TABLE [dbo].[PSCSSWEBADDRESS]
(
[UUID] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[NAME] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ADDRESS] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CreateTime] [datetime] NOT NULL,
[CreateOper] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[LastModifyTime] [datetime] NULL,
[LastModifyOper] [char] (32) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCSSWEBADDRESS] ADD CONSTRAINT [PK__PSCSSWebAddress__60971180] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
