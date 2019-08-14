CREATE TABLE [dbo].[vdrbrand]
(
[vdrgid] [int] NOT NULL,
[brand] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__vdrbrand__brand__2F8763CC] DEFAULT (''),
[nlineno] [int] NOT NULL,
[drawrate] [money] NOT NULL CONSTRAINT [DF__vdrbrand__drawra__307B8805] DEFAULT (0),
[bonusrate] [money] NOT NULL CONSTRAINT [DF__vdrbrand__bonusr__316FAC3E] DEFAULT (0),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__vdrbrand__NUM__2201B4CE] DEFAULT (''),
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__vdrbrand__DEPT__22F5D907] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vdrbrand] ADD CONSTRAINT [PK__vdrbrand__23E9FD40] PRIMARY KEY CLUSTERED  ([vdrgid], [DEPT], [NUM], [brand]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
