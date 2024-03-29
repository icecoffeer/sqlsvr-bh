CREATE TABLE [dbo].[PS3SPECSCOPESCOREINVSPECDIS]
(
[UUID] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPECODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPENAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECSC__DISCO__76003B6D] DEFAULT (0),
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3SPECSC__SRCNU__76F45FA6] DEFAULT ('-'),
[SRCCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3SPECSC__SRCCL__77E883DF] DEFAULT ('-')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SPECSCOPESCOREINVSPECDIS] ADD CONSTRAINT [PK__PS3SPECSCOPESCOR__78DCA818] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
