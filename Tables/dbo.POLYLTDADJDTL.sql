CREATE TABLE [dbo].[POLYLTDADJDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NULL,
[BRAND] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LTDVALUE] [int] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYLTDADJDTL] ADD CONSTRAINT [PK__POLYLTDADJDTL__724E0F6C] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
