CREATE TABLE [dbo].[CNTR_GENVDRLSEDEPTBRAND]
(
[CNTRNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[CHGCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VDRGID] [int] NOT NULL,
[DEPT] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CNTR_GENV__BRAND__2E1A775E] DEFAULT ('-'),
[PAYRATE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CNTR_GENV__PAYRA__2F0E9B97] DEFAULT (0),
[SORTCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CNTR_GENVDRLSEDEPTBRAND] ADD CONSTRAINT [PK__CNTR_GENVDRLSEDE__3002BFD0] PRIMARY KEY CLUSTERED  ([CNTRNUM], [VERSION], [CHGCODE], [VDRGID], [DEPT], [BRAND]) ON [PRIMARY]
GO
