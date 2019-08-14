CREATE TABLE [dbo].[YEARSETTLE]
(
[NO] [int] NOT NULL,
[BEGINDATE] [datetime] NULL,
[ENDDATE] [datetime] NULL CONSTRAINT [DF__YEARSETTL__ENDDA__79BDEDF3] DEFAULT ('12/31/2099'),
[EMPLOYEECODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[EMPLOYEENAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[NANO] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[YEARSETTLE] WITH NOCHECK ADD CONSTRAINT [年终止时间不能小于开始时间] CHECK (([BEGINDATE]<=[ENDDATE]))
GO
ALTER TABLE [dbo].[YEARSETTLE] ADD CONSTRAINT [PK__YEARSETTLE__46D27B73] PRIMARY KEY CLUSTERED  ([NO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO