CREATE TABLE [dbo].[VOUCHERACTIVITY]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TOPIC] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERTYPE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRNTFILENAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BEGINNUM] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ENDNUM] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[GIVECOSTDIVIDEVENDOR] [decimal] (24, 4) NOT NULL,
[GIVECOSTDIVIDELESSEE] [decimal] (24, 4) NOT NULL,
[GIVECOSTDIVIDESTORE] [decimal] (24, 4) NOT NULL,
[USECOSTDIVIDEVENDOR] [decimal] (24, 4) NOT NULL,
[USECOSTDIVIDELESSEE] [decimal] (24, 4) NOT NULL,
[USECOSTDIVIDESTORE] [decimal] (24, 4) NOT NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LSTMODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__VOUCHERAC__LSTUP__2DC70851] DEFAULT (getdate()),
[ISVOUCHERGENED] [smallint] NOT NULL CONSTRAINT [DF__VOUCHERAC__ISVOU__2EBB2C8A] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERACTIVITY] ADD CONSTRAINT [PK__VOUCHERACTIVITY__2FAF50C3] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
