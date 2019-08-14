CREATE TABLE [dbo].[CKSWI]
(
[WRH] [int] NOT NULL,
[SUBWRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__CKSWI__QTY__5848B6E6] DEFAULT (0),
[TOTAL] [money] NOT NULL CONSTRAINT [DF__CKSWI__TOTAL__593CDB1F] DEFAULT (0),
[KEPTDATE] [datetime] NOT NULL CONSTRAINT [DF__CKSWI__KEPTDATE__5A30FF58] DEFAULT (getdate()),
[INPRC] [money] NOT NULL CONSTRAINT [DF__CKSWI__INPRC__5B252391] DEFAULT (0),
[RTLPRC] [money] NOT NULL CONSTRAINT [DF__CKSWI__RTLPRC__5C1947CA] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CKSWI] ADD CONSTRAINT [PK__CKSWI__2B947552] PRIMARY KEY CLUSTERED  ([GDGID], [SUBWRH]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO