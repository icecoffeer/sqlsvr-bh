CREATE TABLE [dbo].[NPSBRANDSORTSTORE]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[BRANDCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SORTCODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[STATUS] [int] NOT NULL CONSTRAINT [DF__NPSBRANDS__STATU__34CE6932] DEFAULT (0),
[STARTDATE] [datetime] NULL,
[SUSPENDDATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPSBRANDSORTSTORE] ADD CONSTRAINT [PK__NPSBRANDSORTSTOR__35C28D6B] PRIMARY KEY CLUSTERED  ([SRC], [ID], [BRANDCODE], [SORTCODE], [STOREGID]) ON [PRIMARY]
GO
