CREATE TABLE [dbo].[NREALEXCHGDATADTL]
(
[RECVDATE] [datetime] NOT NULL,
[RCV] [int] NOT NULL,
[SRC] [int] NOT NULL,
[TGT] [int] NOT NULL,
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHECKINT1] [int] NOT NULL CONSTRAINT [DF__NREALEXCH__CHECK__1724FEFF] DEFAULT (0),
[CHECKINT2] [int] NOT NULL CONSTRAINT [DF__NREALEXCH__CHECK__18192338] DEFAULT (0),
[CHECKINT3] [int] NOT NULL CONSTRAINT [DF__NREALEXCH__CHECK__190D4771] DEFAULT (0),
[CHECKDATA1] [decimal] (20, 2) NOT NULL CONSTRAINT [DF__NREALEXCH__CHECK__1A016BAA] DEFAULT (0),
[CHECKDATA2] [decimal] (20, 2) NOT NULL CONSTRAINT [DF__NREALEXCH__CHECK__1AF58FE3] DEFAULT (0),
[CHECKDATA3] [decimal] (20, 2) NOT NULL CONSTRAINT [DF__NREALEXCH__CHECK__1BE9B41C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NREALEXCHGDATADTL] ADD CONSTRAINT [PK__NREALEXCHGDATADT__1630DAC6] PRIMARY KEY CLUSTERED  ([RECVDATE], [SRC], [TGT], [CLS], [NUM]) ON [PRIMARY]
GO