CREATE TABLE [dbo].[PRCADJLOG]
(
[Cls] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL,
[ACT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCADJLOG] ADD CONSTRAINT [PK__PrcAdjLOG__49D2DC62] PRIMARY KEY CLUSTERED  ([Cls], [NUM], [TIME], [ACT]) ON [PRIMARY]
GO
