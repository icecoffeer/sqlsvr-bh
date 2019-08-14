CREATE TABLE [dbo].[NGROUPCNTR]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [int] NOT NULL,
[CNTRNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CNTRVERSION] [int] NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NGROUPCNTR] ADD CONSTRAINT [PK__NGROUPCNTR__4C7BD591] PRIMARY KEY CLUSTERED  ([SRC], [ID], [NUM], [VERSION], [CNTRNUM], [CNTRVERSION]) ON [PRIMARY]
GO