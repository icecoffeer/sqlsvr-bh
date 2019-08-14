CREATE TABLE [dbo].[CRMCARDAPPLYDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BALANCE] [decimal] (24, 2) NOT NULL,
[CHECKABORT] [smallint] NOT NULL CONSTRAINT [DF__CRMCARDAP__CHECK__60EA808D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMCARDAPPLYDTL] ADD CONSTRAINT [PK__CRMCARDAPPLYDTL__61DEA4C6] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO