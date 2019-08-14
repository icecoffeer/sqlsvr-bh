CREATE TABLE [dbo].[DCCORPDEFINE]
(
[Code] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Name] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FTPServer] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DCCORPDEF__FTPSe__072E8E58] DEFAULT (''),
[FTPUser] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DCCORPDEF__FTPUs__0822B291] DEFAULT (''),
[FTPPWD] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DCCORPDEF__FTPPW__0916D6CA] DEFAULT (''),
[FTPPortNO] [int] NOT NULL CONSTRAINT [DF__DCCORPDEF__FTPPo__0A0AFB03] DEFAULT (21),
[FTPDir] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DCCORPDEF__FTPDi__0AFF1F3C] DEFAULT ('/')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DCCORPDEFINE] ADD CONSTRAINT [PK__DCCORPDEFINE__063A6A1F] PRIMARY KEY CLUSTERED  ([Code]) ON [PRIMARY]
GO
