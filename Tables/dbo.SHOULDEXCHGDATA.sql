CREATE TABLE [dbo].[SHOULDEXCHGDATA]
(
[SENDDATE] [datetime] NOT NULL,
[SRC] [int] NOT NULL,
[TGT] [int] NOT NULL,
[RECCNT] [int] NOT NULL,
[LSTSNDTIME] [datetime] NULL,
[FINISHED] [int] NOT NULL CONSTRAINT [DF__SHOULDEXC__FINIS__75C40B34] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SHOULDEXCHGDATA] ADD CONSTRAINT [PK__SHOULDEXCHGDATA__74CFE6FB] PRIMARY KEY CLUSTERED  ([SENDDATE], [SRC], [TGT]) ON [PRIMARY]
GO
