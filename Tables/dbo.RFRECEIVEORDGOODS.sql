CREATE TABLE [dbo].[RFRECEIVEORDGOODS]
(
[ORDNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SPID] [int] NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDCODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDINPUT] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ARVQTY] [decimal] (24, 4) NOT NULL,
[NOTARVQTY] [decimal] (24, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFRECEIVEORDGOODS] ADD CONSTRAINT [PK__RFRECEIVEORDGOOD__24B1D40C] PRIMARY KEY CLUSTERED  ([ORDNUM], [LINE]) ON [PRIMARY]
GO
