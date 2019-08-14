CREATE TABLE [dbo].[VOUCHERUSERULERANGEINDTLOCR]
(
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[SORTCODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[VDRGID] [int] NULL,
[BRANDCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[DEPTCODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERUSERULERANGEINDTLOCR] ADD CONSTRAINT [PK__VOUCHERUSERULERA__42C22537] PRIMARY KEY CLUSTERED  ([BILLNUM], [BILLLINE]) ON [PRIMARY]
GO
