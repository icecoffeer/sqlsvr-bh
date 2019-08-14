CREATE TABLE [dbo].[NCLNSTYLE]
(
[SRC] [int] NOT NULL CONSTRAINT [DF__NCLNSTYLE__SRC__1360266A] DEFAULT (1),
[ID] [int] NOT NULL IDENTITY(1, 1),
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SNDTIME] [datetime] NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[FRCUPD] [smallint] NOT NULL CONSTRAINT [DF__NCLNSTYLE__FRCUP__14544AA3] DEFAULT (0),
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [char] (60) COLLATE Chinese_PRC_CI_AS NULL,
[OUTPRC] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATETIME] [datetime] NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCLNSTYLE] ADD CONSTRAINT [PK__NCLNSTYLE__126C0231] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
