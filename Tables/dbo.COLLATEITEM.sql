CREATE TABLE [dbo].[COLLATEITEM]
(
[COLLATENO] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[FIELDNAME] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[FIELDLABEL] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [int] NULL,
[CWIDTH] [int] NOT NULL CONSTRAINT [DF__COLLATEIT__CWIDT__4ED5F1F3] DEFAULT (70)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COLLATEITEM] ADD CONSTRAINT [PK__COLLATEITEM__3335971A] PRIMARY KEY CLUSTERED  ([COLLATENO], [ITEMNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
