CREATE TABLE [dbo].[PSCTDISEFFECT]
(
[UUID] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCTDISEFFECT] ADD CONSTRAINT [PK__PSCTDISEFFECT__030A8E67] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO