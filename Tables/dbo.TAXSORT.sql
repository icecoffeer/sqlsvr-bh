CREATE TABLE [dbo].[TAXSORT]
(
[GID] [int] NOT NULL,
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PROVINCE] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[freeTaxType] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[useSalePolicy] [int] NULL,
[vatSpecialMag] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TAXSORT_INS] on [dbo].[TAXSORT] for insert as
begin
   insert into TAXSORTH
       select * from INSERTED
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[TAXSORT_UPD] on [dbo].[TAXSORT] for update as
begin
  delete from TAXSORTH
      from DELETED
      where TAXSORTH.GID = DELETED.GID
  insert into TAXSORTH
      select * from INSERTED
end
GO
ALTER TABLE [dbo].[TAXSORT] ADD CONSTRAINT [PK__TAXSORT__C51F0F3E52C382D6] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TAXSORT_TYPE] ON [dbo].[TAXSORT] ([CODE]) ON [PRIMARY]
GO
