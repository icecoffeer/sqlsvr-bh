CREATE TABLE [dbo].[FAOPTIONVALUES]
(
[OPTUSER] [int] NOT NULL,
[OPTIONS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPTKEY] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__FAOPTIONV__OPTKE__105BFE92] DEFAULT ('\'),
[OPTCAPTION] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPTVALUE] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL,
[OPTNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAOPTIONVALUES] ADD CONSTRAINT [PK__FAOPTIONVALUES__115022CB] PRIMARY KEY CLUSTERED  ([OPTUSER], [OPTIONS], [OPTKEY], [OPTCAPTION]) ON [PRIMARY]
GO
