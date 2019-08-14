CREATE TABLE [dbo].[TA_BOKEFACE]
(
[OPERATCODE] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRODUCEDATE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AddNum] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__TA_BOKEFA__AddNu__589E87F8] DEFAULT (''),
[FLBH] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ZFLBH] [varchar] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BRIEF] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ACCOUNT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ACCOUNTNAME] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ProjectCode] [varchar] (15) COLLATE Chinese_PRC_CI_AS NULL,
[ProjectName] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[FirmCode] [varchar] (15) COLLATE Chinese_PRC_CI_AS NULL,
[FirmName] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[OperatorCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OperatorName] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OperateDate] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__TA_BOKEFA__SETTL__5992AC31] DEFAULT ('000000'),
[CorCode] [varchar] (15) COLLATE Chinese_PRC_CI_AS NULL,
[BBJF] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[BBDF] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CashCode] [varchar] (5) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__TA_BOKEFA__CashC__5A86D06A] DEFAULT ('RMB'),
[Rate] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WBJF] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WBDF] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[Price] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SLJF] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SLDF] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
