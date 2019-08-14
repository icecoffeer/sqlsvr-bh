CREATE TABLE [dbo].[INVOICEREV]
(
[UUID] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[REVER] [int] NOT NULL,
[REVDATE] [datetime] NOT NULL,
[REVSTORE] [int] NOT NULL,
[SETTLENO] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NULL,
[LSTMODIFIER] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__INVOICERE__LSTMO__6942FCC8] DEFAULT ('未知[-]'),
[LSTMODIDATE] [datetime] NOT NULL CONSTRAINT [DF__INVOICERE__LSTMO__6A372101] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INVOICEREV] ADD CONSTRAINT [PK__INVOICEREV__5C1E0BD4] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_INVOICEREV] ON [dbo].[INVOICEREV] ([REVER], [REVSTORE]) ON [PRIMARY]
GO