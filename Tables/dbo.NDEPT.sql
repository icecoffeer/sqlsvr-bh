CREATE TABLE [dbo].[NDEPT]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[Note] [varchar] (256) COLLATE Chinese_PRC_CI_AS NULL,
[ParentCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Depth] [int] NOT NULL CONSTRAINT [DF__NDept__Depth__0C9EE599] DEFAULT (0),
[Layer] [varchar] (5) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NDEPT] ADD CONSTRAINT [PK__NDEPT__1D114BD1] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
