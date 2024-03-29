CREATE TABLE [dbo].[NETOBJSEQ]
(
[SEQID] [int] NOT NULL IDENTITY(1, 1),
[DATATYPE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SENDTIME] [datetime] NOT NULL,
[DATASOURCETABLE] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NOID] [int] NOT NULL,
[GRPIDFLAG] [smallint] NOT NULL CONSTRAINT [DF__NETOBJSEQ__GRPID__7439853A] DEFAULT (0),
[RCVGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NETOBJSEQ] ADD CONSTRAINT [PK__NETOBJSEQ__752DA973] PRIMARY KEY CLUSTERED  ([SEQID]) ON [PRIMARY]
GO
