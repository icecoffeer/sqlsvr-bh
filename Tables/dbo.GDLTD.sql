CREATE TABLE [dbo].[GDLTD]
(
[GDGID] [int] NOT NULL,
[OLDVALUE] [int] NOT NULL,
[NEWVALUE] [int] NOT NULL,
[NEWVALUENUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[FINISHDATE] [datetime] NOT NULL CONSTRAINT [DF__GDLTD__FINISHDAT__7B6A37F6] DEFAULT ('9999.12.31 23:59:59')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDLTD] ADD CONSTRAINT [PK__GDLTD__7C5E5C2F] PRIMARY KEY CLUSTERED  ([GDGID], [FINISHDATE]) ON [PRIMARY]
GO
