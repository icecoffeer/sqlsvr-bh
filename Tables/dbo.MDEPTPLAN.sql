CREATE TABLE [dbo].[MDEPTPLAN]
(
[YEAR] [decimal] (4, 0) NOT NULL,
[MONTH] [decimal] (2, 0) NOT NULL,
[DEPT] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TOTAL] [money] NOT NULL,
[GP] [money] NOT NULL,
[GPRATE] [money] NOT NULL,
[STORE] [int] NOT NULL CONSTRAINT [DF__MDEPTPLAN__STORE__63BF2D9C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MDEPTPLAN] ADD CONSTRAINT [PK__MDEPTPLAN__69933E79] PRIMARY KEY CLUSTERED  ([YEAR], [MONTH], [DEPT]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[Curdflt]', N'[dbo].[MDEPTPLAN].[GP]'
GO
EXEC sp_bindefault N'[dbo].[Curdflt]', N'[dbo].[MDEPTPLAN].[GPRATE]'
GO