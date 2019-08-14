CREATE TABLE [dbo].[INVOICEUSE]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[INVOPERTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[INVOICECODE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[USER] [int] NOT NULL,
[USEDATE] [datetime] NOT NULL,
[USESTORE] [int] NOT NULL,
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL CONSTRAINT [DF__INVOICEUS__SETTL__6E07B1E5] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[INVOICEUSE_INS] on [dbo].[INVOICEUSE] for insert as      
begin    
  
 update a set a.settleno = c.no  
 from INVOICEUSE a,inserted ,monthsettle c  
 where a.flowno = inserted.flowno and a.posno = inserted.posno  
 and a.invoicecode = inserted.invoicecode  
 and convert(datetime,convert(varchar(6),substring(inserted.flowno,3,6)),102) >= c.begindate  
 and convert(datetime,convert(varchar(6),substring(inserted.flowno,3,6)),102) <= c.enddate  
 and a.settleno = 0  
  
end

GO
ALTER TABLE [dbo].[INVOICEUSE] ADD CONSTRAINT [PK__INVOICEUSE__5EFA787F] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO], [INVOICECODE]) ON [PRIMARY]
GO
