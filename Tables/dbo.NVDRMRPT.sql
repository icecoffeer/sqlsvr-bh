CREATE TABLE [dbo].[NVDRMRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[BVDRGID] [int] NULL,
[BWRH] [int] NULL,
[BGDGID] [int] NULL,
[CQ1] [money] NULL CONSTRAINT [DF__NVDRMRPT__CQ1__27E4AB56] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__NVDRMRPT__CQ2__28D8CF8F] DEFAULT (0),
[CQ3] [money] NULL CONSTRAINT [DF__NVDRMRPT__CQ3__29CCF3C8] DEFAULT (0),
[CQ4] [money] NULL CONSTRAINT [DF__NVDRMRPT__CQ4__2AC11801] DEFAULT (0),
[CQ5] [money] NULL CONSTRAINT [DF__NVDRMRPT__CQ5__2BB53C3A] DEFAULT (0),
[CQ6] [money] NULL CONSTRAINT [DF__NVDRMRPT__CQ6__2CA96073] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT1__2D9D84AC] DEFAULT (0),
[CT2] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT2__2E91A8E5] DEFAULT (0),
[CT3] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT3__2F85CD1E] DEFAULT (0),
[CT4] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT4__3079F157] DEFAULT (0),
[CT5] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT5__316E1590] DEFAULT (0),
[CT6] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT6__326239C9] DEFAULT (0),
[CT7] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT7__33565E02] DEFAULT (0),
[CT8] [money] NULL CONSTRAINT [DF__NVDRMRPT__CT8__344A823B] DEFAULT (0),
[DQ1] [money] NULL CONSTRAINT [DF__NVDRMRPT__DQ1__353EA674] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__NVDRMRPT__DQ2__3632CAAD] DEFAULT (0),
[DQ3] [money] NULL CONSTRAINT [DF__NVDRMRPT__DQ3__3726EEE6] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__NVDRMRPT__DQ4__381B131F] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__NVDRMRPT__DQ5__390F3758] DEFAULT (0),
[DQ6] [money] NULL CONSTRAINT [DF__NVDRMRPT__DQ6__3A035B91] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT1__3AF77FCA] DEFAULT (0),
[DT2] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT2__3BEBA403] DEFAULT (0),
[DT3] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT3__3CDFC83C] DEFAULT (0),
[DT4] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT4__3DD3EC75] DEFAULT (0),
[DT5] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT5__3EC810AE] DEFAULT (0),
[DT6] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT6__3FBC34E7] DEFAULT (0),
[DT7] [money] NULL CONSTRAINT [DF__NVDRMRPT__DT7__40B05920] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL,
[ci2] [money] NULL CONSTRAINT [DF__nvdrmrpt__ci2__25D245B2] DEFAULT (0),
[di2] [money] NULL CONSTRAINT [DF__nvdrmrpt__di2__26C669EB] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NVDRMRPT] ADD CONSTRAINT [PK__NVDRMRPT__5555A4F4] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
