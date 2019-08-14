CREATE TABLE [dbo].[DCWKSUM]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPTIME] [datetime] NOT NULL CONSTRAINT [DF__DCWKSUM__OPTIME__03BF86D5] DEFAULT (getdate()),
[OCRDATE] [datetime] NOT NULL CONSTRAINT [DF__DCWKSUM__OCRDATE__04B3AB0E] DEFAULT (getdate()),
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DCWKSUM] ADD CONSTRAINT [PK__DCWKSUM__02CB629C] PRIMARY KEY CLUSTERED  ([CLS], [NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DCWKSUM_OPTIME] ON [dbo].[DCWKSUM] ([OCRDATE]) ON [PRIMARY]
GO