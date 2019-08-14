CREATE TABLE [dbo].[ALCPOOLHTEMP]
(
[STOREGID] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[LINE] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__ALCPOOLHTEM__QTY__3C623BFD] DEFAULT (0),
[SRCQTY] [money] NULL,
[DMDDATE] [datetime] NOT NULL,
[SRCGRP] [smallint] NOT NULL,
[SRCBILL] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SRCCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SRCLINE] [int] NULL,
[GENTIME] [datetime] NULL,
[GENNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__ALCPOOLHT__GENNU__3D566036] DEFAULT ('-'),
[GENCLS] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[ISUSED] [int] NULL,
[APARTER] [int] NULL,
[ALCER] [int] NULL
) ON [PRIMARY]
GO