CREATE TABLE [dbo].[MYJTOBACCO]
(
[STCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[YCCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LICENSE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MYJTOBACCO] ADD CONSTRAINT [PK__MYJTOBACCO__32EDE05C] PRIMARY KEY CLUSTERED  ([YCCODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MYJTOBACCO] ADD CONSTRAINT [UQ__MYJTOBACCO__33E20495] UNIQUE NONCLUSTERED  ([STCODE]) ON [PRIMARY]
GO
