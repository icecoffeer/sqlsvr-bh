CREATE TABLE [dbo].[GDSALEADJDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[SETTLENO] [int] NULL,
[GDGID] [int] NULL,
[OLDGDSALE] [smallint] NOT NULL,
[NEWGDSALE] [smallint] NULL,
[NEWPAYRATE] [decimal] (24, 2) NULL,
[CHGFLAG] [smallint] NOT NULL CONSTRAINT [DF__GDSALEADJ__CHGFL__49BC371B] DEFAULT (0),
[CHGFROMDATE] [datetime] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDSALEADJDTL] ADD CONSTRAINT [PK__GDSALEADJDTL__48C812E2] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO