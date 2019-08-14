CREATE TABLE [dbo].[CNTRDPTOUTSRCDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SRCCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRCTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRDPTOU__SRCTO__0278BEE6] DEFAULT (0),
[PAYEDAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRDPTOU__PAYED__036CE31F] DEFAULT (0),
[CANPAYAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRDPTOU__CANPA__04610758] DEFAULT (0),
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRDPTOU__TOTAL__05552B91] DEFAULT (0),
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CNTRDPTOUTSRCDTL] ADD CONSTRAINT [PK__CNTRDPTOUTSRCDTL__06494FCA] PRIMARY KEY CLUSTERED  ([NUM], [SRCCLS], [SRCNUM]) ON [PRIMARY]
GO