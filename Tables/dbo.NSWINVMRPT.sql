CREATE TABLE [dbo].[NSWINVMRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BSUBWRH] [int] NOT NULL,
[CQ] [money] NOT NULL CONSTRAINT [DF__NSWINVMRPT__CQ__34605C2B] DEFAULT (0),
[CT] [money] NOT NULL CONSTRAINT [DF__NSWINVMRPT__CT__35548064] DEFAULT (0),
[FQ] [money] NOT NULL CONSTRAINT [DF__NSWINVMRPT__FQ__3648A49D] DEFAULT (0),
[FT] [money] NOT NULL CONSTRAINT [DF__NSWINVMRPT__FT__373CC8D6] DEFAULT (0),
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSWINVMRPT] ADD CONSTRAINT [PK__NSWINVMRPT__536D5C82] PRIMARY KEY CLUSTERED  ([ASETTLENO], [BGDGID], [BWRH], [BSUBWRH], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
