CREATE TABLE [dbo].[DA_BANK]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ENGNAME] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[CHNNAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GFACODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LMODDATE] [datetime] NOT NULL CONSTRAINT [DF__DA_BANK__LMODDAT__18AE2015] DEFAULT (getdate()),
[LMODOPID] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DA_BANK__LMODOPI__19A2444E] DEFAULT ('未知[-]'),
[ACCOUNT] [varchar] (25) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DA_BANK] ADD CONSTRAINT [PK__DA_BANK__17B9FBDC] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
