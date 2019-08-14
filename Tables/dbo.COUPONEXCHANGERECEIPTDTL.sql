CREATE TABLE [dbo].[COUPONEXCHANGERECEIPTDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[COUPONEXCHANGERECEIPTDTL] ADD CONSTRAINT [PK__COUPONEX__91DB7AAD049AD58C] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
