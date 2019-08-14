CREATE TABLE [dbo].[VDRLESSEE]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VDRGID] [int] NOT NULL,
[BUYER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRLESSEE__BUYER__670F04E5] DEFAULT ('未知[-]'),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__VDRLESSEE__FILDA__6803291E] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRLESSEE__FILLE__68F74D57] DEFAULT ('未知[-]'),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__VDRLESSEE__STAT__69EB7190] DEFAULT (0),
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRLESSEE__CHECK__6ADF95C9] DEFAULT ('未知[-]'),
[CHECKDATE] [datetime] NOT NULL CONSTRAINT [DF__VDRLESSEE__CHECK__6BD3BA02] DEFAULT (getdate()),
[MEMO] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[ORGVISER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[PAYRATE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRLESSEE__PAYRA__6CC7DE3B] DEFAULT (0),
[SHOPNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRLESSEE] ADD CONSTRAINT [PK__VDRLESSEE__6DBC0274] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO