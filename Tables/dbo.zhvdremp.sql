CREATE TABLE [dbo].[zhvdremp]
(
[vdrgid] [int] NOT NULL,
[cntrnum] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[empgid] [int] NOT NULL,
[drawrate] [money] NOT NULL,
[manfee] [money] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[zhvdremp] ADD CONSTRAINT [PK__zhvdremp__5C6F18DC] PRIMARY KEY CLUSTERED  ([vdrgid], [cntrnum], [DEPT], [empgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
