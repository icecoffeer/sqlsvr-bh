CREATE TABLE [dbo].[TangoProfile]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[email] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[phoneHome] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[phoneOffice] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[mobile] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[pager] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[msn] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[qq] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[postcode] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[birthday] [datetime] NULL,
[wedding] [datetime] NULL,
[favoriteColor] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[favoriteNumber] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[married] [tinyint] NULL,
[address1] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[address2] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[address3] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[contactor] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[phone] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[website] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[fax] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[position] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoProfile] ADD CONSTRAINT [PK__TangoProfile__00BA93A6] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
