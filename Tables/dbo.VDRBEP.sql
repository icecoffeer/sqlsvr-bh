CREATE TABLE [dbo].[VDRBEP]
(
[VDRGID] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRBEP] ADD CONSTRAINT [PK__VDRBEP__22921F6B] PRIMARY KEY CLUSTERED  ([STOREGID], [VDRGID], [BILLNUM], [DEPT]) ON [PRIMARY]
GO