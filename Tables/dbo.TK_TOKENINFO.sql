CREATE TABLE [dbo].[TK_TOKENINFO]
(
[ID] [int] NOT NULL CONSTRAINT [DF__TK_TOKENINFO__ID__1D72D532] DEFAULT (0),
[SERIALNO] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPE] [int] NOT NULL CONSTRAINT [DF__TK_TOKENIN__TYPE__1E66F96B] DEFAULT (0),
[SECUREKEY] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[INITTIME] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__INITT__1F5B1DA4] DEFAULT (0),
[DIFFERENCE] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__DIFFE__204F41DD] DEFAULT (0),
[INITTOKENTIME] [int] NULL CONSTRAINT [DF__TK_TOKENI__INITT__21436616] DEFAULT (0),
[STATE] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__STATE__22378A4F] DEFAULT (1),
[LASTTIME] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__LASTT__232BAE88] DEFAULT (0),
[ADTIME] [datetime] NOT NULL CONSTRAINT [DF__TK_TOKENI__ADTIM__241FD2C1] DEFAULT (getdate()),
[HDDIFF] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__HDDIF__2513F6FA] DEFAULT (0),
[ERRTIMES] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__ERRTI__26081B33] DEFAULT (0),
[LASTAUTHTIME] [datetime] NOT NULL CONSTRAINT [DF__TK_TOKENI__LASTA__26FC3F6C] DEFAULT (getdate()),
[TOTALAUTH] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__TOTAL__27F063A5] DEFAULT (0),
[TOTALSUCC] [int] NOT NULL CONSTRAINT [DF__TK_TOKENI__TOTAL__28E487DE] DEFAULT (0),
[SUCCTOKEN] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[TK_TOKENINFO_INS]
ON [dbo].[TK_TOKENINFO] FOR INSERT AS
BEGIN
	DECLARE @I INT
	SELECT @I = ID FROM INSERTED
	IF @I = 0
	BEGIN
		EXEC @I = SEQNEXTVALUE 'TK_SQTOKENID'
		UPDATE TK_TOKENINFO SET ID = @I WHERE ID = 0
	END
END
GO
ALTER TABLE [dbo].[TK_TOKENINFO] ADD CONSTRAINT [PK__TK_TOKENINFO__1C7EB0F9] PRIMARY KEY CLUSTERED  ([SERIALNO]) ON [PRIMARY]
GO
