CREATE TABLE [dbo].[POSGRPLAC]
(
[NO] [int] NOT NULL,
[POSNO] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POSGRPLAC] ADD CONSTRAINT [PK__POSGRPLAC__3B4263E4] PRIMARY KEY CLUSTERED  ([POSNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
