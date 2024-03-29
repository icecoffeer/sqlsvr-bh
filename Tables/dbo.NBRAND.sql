CREATE TABLE [dbo].[NBRAND]
(
[SRC] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[AREA] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NBRAND__AREA__381F0BD2] DEFAULT (1),
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NBRAND__CREATOR__2E367A3C] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__NBRAND__CREATETI__2F2A9E75] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NBRAND__LSTUPDOP__301EC2AE] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NBRAND__LSTUPDTI__3112E6E7] DEFAULT (getdate()),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TEMPLATEGID] [int] NULL,
[ID] [int] NOT NULL CONSTRAINT [DF__NBRAND__ID__37AAD5DD] DEFAULT (0),
[INTRODUCETIME] [datetime] NULL,
[INTRODUCEOPER] [int] NULL,
[BUSINESSSTAT] [smallint] NOT NULL CONSTRAINT [DF__NBRAND__BUSINESS__7FA73F33] DEFAULT (1),
[ELIMINATETIME] [datetime] NULL,
[BRANDCLASS] [int] NULL,
[FLAG] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NBRAND] ADD CONSTRAINT [PK__NBRAND__389EFA16] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
