CREATE TABLE [dbo].[DCWKSUMDTL]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[SLOTGRP] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[EMPCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DCWKSUMDTL] ADD CONSTRAINT [PK__DCWKSUMDTL__069BF380] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [LINE]) ON [PRIMARY]
GO