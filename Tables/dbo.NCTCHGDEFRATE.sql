CREATE TABLE [dbo].[NCTCHGDEFRATE]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DATASRCCLS] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FEEUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[FEECYCLE] [smallint] NULL,
[FEEDAYOFFSET] [smallint] NULL,
[FIXCOST] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCHGDEF__FIXCO__09B9EDFB] DEFAULT (0),
[RATEMODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCHGDEF__RATEM__0AAE1234] DEFAULT ('数值分段'),
[CALCMODE] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCHGDEF__CALCM__0BA2366D] DEFAULT ('合计'),
[FEEPREC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCHGDEF__FEEPR__0C965AA6] DEFAULT (0.01),
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCHGDEF__ROUND__0D8A7EDF] DEFAULT ('四舍五入'),
[AHEADDAYS] [int] NOT NULL CONSTRAINT [DF__NCTCHGDEF__AHEAD__0E7EA318] DEFAULT (0),
[DISCOUNTRATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCHGDEF__DISCO__0F72C751] DEFAULT (0),
[FEETOSTORE] [smallint] NOT NULL CONSTRAINT [DF__NCTCHGDEF__FEETO__1066EB8A] DEFAULT (0),
[GUARDMODE] [smallint] NOT NULL CONSTRAINT [DF__NCTCHGDEF__GUARD__115B0FC3] DEFAULT (0),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCHGDEFRATE] ADD CONSTRAINT [PK__NCTCHGDEFRATE__124F33FC] PRIMARY KEY CLUSTERED  ([SRC], [ID], [CODE]) ON [PRIMARY]
GO