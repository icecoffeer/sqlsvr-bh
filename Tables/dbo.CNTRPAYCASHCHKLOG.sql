CREATE TABLE [dbo].[CNTRPAYCASHCHKLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKFLAG] [int] NOT NULL,
[OPER] [int] NOT NULL,
[ATIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CNTRPAYCASHCHKLOG] ADD CONSTRAINT [PK__CNTRPAYCASHCHKLO__3284975F] PRIMARY KEY CLUSTERED  ([ATIME], [NUM], [CHKFLAG]) ON [PRIMARY]
GO
