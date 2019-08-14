CREATE TABLE [dbo].[priceUploadTaobaoRecord]
(
[uuid] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[activityId] [numeric] (19, 0) NULL,
[date] [datetime] NULL,
[storeCode] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[priceUploadTaobaoRecord] ADD CONSTRAINT [PK__priceUpl__7F4279305634EC5E] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
