CREATE TABLE [dbo].[FAQUERYFILERSERVER]
(
[MODULENO] [smallint] NOT NULL,
[SERVER] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAQUERYFILERSERVER] ADD CONSTRAINT [PK__FAQUERYFILERSERV__264B3FB1] PRIMARY KEY CLUSTERED  ([MODULENO]) ON [PRIMARY]
GO