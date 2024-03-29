CREATE TABLE [dbo].[t_contract]
(
[FLOWNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[VENDOR] [int] NOT NULL,
[VTM] [char] (60) COLLATE Chinese_PRC_CI_AS NULL,
[REGFUND] [money] NULL,
[RTLPRCSTYLE] [smallint] NOT NULL,
[Counter] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTERAREA] [money] NULL,
[VAREA] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[OUTERWRHAREA] [money] NULL,
[EQPUSEAMT] [money] NULL,
[ASSISTANTS] [int] NULL,
[ASTSALARY] [money] NULL,
[CREDITS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SIGNDATE] [datetime] NULL,
[hizjde] [money] NOT NULL,
[lowzjde] [money] NOT NULL,
[ATTORNEY] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[begindate] [datetime] NOT NULL,
[enddate] [datetime] NOT NULL,
[TGTSALEAMT] [money] NULL,
[LWTSALEAMT] [money] NULL,
[janamt] [money] NULL,
[febamt] [money] NULL,
[maramt] [money] NULL,
[apramt] [money] NULL,
[mayamt] [money] NULL,
[junamt] [money] NULL,
[julamt] [money] NULL,
[augamt] [money] NULL,
[sepamt] [money] NULL,
[octamt] [money] NULL,
[novamt] [money] NULL,
[decamt] [money] NULL,
[DRAWRATE] [money] NULL,
[proprate] [money] NULL,
[emprate] [money] NULL,
[FILLER] [int] NOT NULL,
[MODIFIER] [int] NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[sale] [smallint] NOT NULL,
[otherfee] [money] NULL,
[Qualitybail] [money] NULL,
[EXTASSISTANTS] [int] NULL,
[EXTASTSALARY] [money] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
