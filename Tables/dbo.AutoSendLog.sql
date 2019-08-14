CREATE TABLE [dbo].[AutoSendLog]
(
[Subject] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Receiver] [int] NOT NULL,
[OcrTime] [datetime] NOT NULL CONSTRAINT [DF__AutoSendL__OcrTi__6371E77D] DEFAULT (getdate()),
[SendDate] [datetime] NOT NULL,
[SendRows] [int] NOT NULL CONSTRAINT [DF__AutoSendL__SendR__64660BB6] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoSendLog] ADD CONSTRAINT [PK__AutoSendLog__627DC344] PRIMARY KEY CLUSTERED  ([Subject], [Receiver], [SendDate]) ON [PRIMARY]
GO
