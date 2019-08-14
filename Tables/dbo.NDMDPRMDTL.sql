CREATE TABLE [dbo].[NDMDPRMDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[PRMTYPE] [smallint] NOT NULL CONSTRAINT [DF__NDMDPRMDT__PRMTY__42652E16] DEFAULT (0),
[CANGFT] [smallint] NOT NULL CONSTRAINT [DF__NDMDPRMDT__CANGF__4359524F] DEFAULT (0),
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NDMDPRMDTL__QPC__3F803678] DEFAULT (1),
[QPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NDMDPRMDT__QPCST__40745AB1] DEFAULT ('1*1')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NDMDPRMDTL] ADD CONSTRAINT [PK__NDMDPRMDTL__20E1DCB5] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
