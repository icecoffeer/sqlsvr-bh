CREATE TABLE [dbo].[PS3DISNOTDISCOUNTSORT]
(
[SORT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3DISNOTDISCOUNTSORT] ADD CONSTRAINT [PK__PS3DISNOTDISCOUN__31F065D9] PRIMARY KEY CLUSTERED  ([SORT]) ON [PRIMARY]
GO
