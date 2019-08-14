CREATE TABLE [dbo].[AddrInfoDtl]
(
[Code] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Line] [int] NOT NULL,
[PROVINCE] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTY] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[ROAD] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[ZIPCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Note] [varchar] (127) COLLATE Chinese_PRC_CI_AS NULL,
[Mansion] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[UUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AddrInfoDtl] ADD CONSTRAINT [PK__AddrInfoDtl__3FA7264E] PRIMARY KEY CLUSTERED  ([Code], [Line]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
