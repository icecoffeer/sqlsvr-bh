CREATE TABLE [dbo].[PRMTOPIC]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMTOPIC__CREATO__2C40E2CD] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__PRMTOPIC__CREATE__2D350706] DEFAULT (getdate()),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRMTOPIC__MODIFI__2E292B3F] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PRMTOPIC__LSTUPD__2F1D4F78] DEFAULT (getdate()),
[PRI] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PRMTOPIC__PRI__7DF26A3D] DEFAULT (0),
[PSETTLENO] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRMTOPIC] ADD CONSTRAINT [PK__PRMTOPIC__2B4CBE94] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO