CREATE TABLE [dbo].[NSTORESTAT]
(
[RCV] [int] NOT NULL,
[ID] [int] NOT NULL,
[UUID] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[STATTYPENAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOPDAYS] [smallint] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [smallint] NOT NULL,
[SRC] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTORESTAT] ADD CONSTRAINT [PK__NSTORESTAT__193DBF5B] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NSTORESTATSTORE] ON [dbo].[NSTORESTAT] ([RCV]) ON [PRIMARY]
GO