CREATE TABLE [dbo].[CURRENCYTYPE]
(
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CNAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ENAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[CURCODE] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CURRENCYTYPE] ADD CONSTRAINT [PK__CURRENCYTYPE__1F3E4F6F] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
