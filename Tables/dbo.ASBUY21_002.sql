CREATE TABLE [dbo].[ASBUY21_002]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[FAVTYPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FAVAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__ASBUY21_0__FAVAM__4077880D] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__ASBUY21_002__TAG__416BAC46] DEFAULT (0),
[PROMNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[PROMCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PROMLVL] [int] NULL,
[PROMGDCNT] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASBUY21_002] ADD CONSTRAINT [PK__ASBUY21_002__425FD07F] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO], [ITEMNO], [FAVTYPE]) ON [PRIMARY]
GO
