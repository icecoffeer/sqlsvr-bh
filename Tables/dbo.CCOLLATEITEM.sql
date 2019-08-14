CREATE TABLE [dbo].[CCOLLATEITEM]
(
[COLLATENO] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[FIELDNAME] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[FIELDLABEL] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [int] NULL,
[LENGTH] [int] NULL,
[SCALE] [int] NULL,
[CONTROLTYPE] [int] NOT NULL,
[CWIDTH] [int] NOT NULL CONSTRAINT [DF__CCOLLATEI__CWIDT__4FCA162C] DEFAULT (70)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCOLLATEITEM] ADD CONSTRAINT [PK__CCOLLATEITEM__34D55D77] PRIMARY KEY CLUSTERED  ([COLLATENO], [ITEMNO]) ON [PRIMARY]
GO