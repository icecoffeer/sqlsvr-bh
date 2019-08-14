CREATE TABLE [dbo].[各店销售汇总]
(
[来源] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[日期] [datetime] NOT NULL,
[销售数量] [money] NULL,
[销售额2] [money] NULL,
[销售额] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[各店销售汇总] ADD CONSTRAINT [PK__各店销售汇总__037F8FB3] PRIMARY KEY CLUSTERED  ([来源], [日期]) ON [PRIMARY]
GO
