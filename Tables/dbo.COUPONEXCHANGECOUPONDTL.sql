CREATE TABLE [dbo].[COUPONEXCHANGECOUPONDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[COUPONCODE] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COUPONEXCHANGECOUPONDTL] ADD CONSTRAINT [PK__COUPONEX__91DB7AAD086B6670] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
