CREATE TABLE [dbo].[TK_ALOG]
(
[ATIME] [datetime] NOT NULL CONSTRAINT [DF__TK_ALOG__ATIME__3826CB6E] DEFAULT (getdate()),
[CATEGORY] [int] NOT NULL CONSTRAINT [DF__TK_ALOG__CATEGOR__391AEFA7] DEFAULT (0),
[SERIALNO] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CPYID] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__TK_ALOG__CPYID__3A0F13E0] DEFAULT ('0'),
[IP] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[ACONTENT] [varchar] (2048) COLLATE Chinese_PRC_CI_AS NULL,
[ARESULT] [int] NULL,
[ID] [int] NOT NULL CONSTRAINT [DF__TK_ALOG__ID__3B033819] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[TK_ALOG_INS]
ON [dbo].[TK_ALOG] FOR INSERT AS
BEGIN
	DECLARE @I INT
	SELECT @I = ID FROM INSERTED
	IF @I = 0
	BEGIN
		EXEC @I = SEQNEXTVALUE 'TK_SQALOGID'
		UPDATE TK_ALOG SET ID = @I WHERE ID = 0
	END
END
GO
ALTER TABLE [dbo].[TK_ALOG] ADD CONSTRAINT [PK__TK_ALOG__3732A735] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INDEX_TK_ALOG] ON [dbo].[TK_ALOG] ([SERIALNO], [CPYID], [ATIME]) ON [PRIMARY]
GO
