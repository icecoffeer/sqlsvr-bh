CREATE TABLE [dbo].[PREORDPOOL]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PREORDPOO__FILDA__49FDC4EB] DEFAULT (getdate()),
[CASHIER] [int] NOT NULL CONSTRAINT [DF__PREORDPOO__CASHI__4AF1E924] DEFAULT (1),
[ASSISTANT] [int] NULL,
[TOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOO__TOTAL__4BE60D5D] DEFAULT (0),
[GUEST] [int] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__PREORDPOO__RECCN__4CDA3196] DEFAULT (0),
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOOL__QTY__4DCE55CF] DEFAULT (0),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CARDCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PREORDPOOL] ADD CONSTRAINT [PK__PREORDPOOL__4EC27A08] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[PREORDPOOL] ([FILDATE]) ON [PRIMARY]
GO