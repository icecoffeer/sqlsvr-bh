CREATE TABLE [dbo].[STOREGFTWRH]
(
[STORE] [int] NOT NULL,
[WRH] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STOREGFTWRH] ADD CONSTRAINT [PK__STOREGFTWRH__48D561DF] PRIMARY KEY CLUSTERED  ([STORE], [WRH]) ON [PRIMARY]
GO
