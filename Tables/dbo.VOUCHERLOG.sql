CREATE TABLE [dbo].[VOUCHERLOG]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FROMSTATE] [int] NULL,
[TOSTATE] [int] NOT NULL,
[CREATOR] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CREATETIME] [datetime] NOT NULL,
[STOREGID] [int] NOT NULL,
[NOTE] [varchar] (256) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERLOG] ADD CONSTRAINT [PK__VOUCHERLOG__6F8F3C4D] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
