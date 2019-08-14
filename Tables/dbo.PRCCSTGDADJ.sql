CREATE TABLE [dbo].[PRCCSTGDADJ]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PRCCSTGDA__FILDA__4F8BB5B8] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__PRCCSTGDA__FILLE__507FD9F1] DEFAULT (1),
[CHKDATE] [datetime] NULL,
[CHECKER] [int] NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PRCCSTGDAD__STAT__5173FE2A] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__PRCCSTGDA__RECCN__52682263] DEFAULT (0),
[SRC] [int] NOT NULL CONSTRAINT [DF__PRCCSTGDADJ__SRC__535C469C] DEFAULT (1),
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PRCCSTGDA__LSTUP__54506AD5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCCSTGDADJ] ADD CONSTRAINT [PK__PRCCSTGDADJ__55448F0E] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[PRCCSTGDADJ] ([FILDATE]) ON [PRIMARY]
GO
