CREATE TABLE [dbo].[pckdtltmp]
(
[line] [int] NOT NULL IDENTITY(1, 1),
[astore] [int] NULL,
[gdgid] [int] NULL,
[qty] [money] NULL CONSTRAINT [DF__pckdtltmp__qty__53B2E305] DEFAULT (0),
[total] [money] NULL CONSTRAINT [DF__pckdtltmp__total__54A7073E] DEFAULT (0)
) ON [PRIMARY]
GO
