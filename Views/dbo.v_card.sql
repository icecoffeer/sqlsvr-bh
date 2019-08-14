SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_card] as
  select * from card where validdate >= getdate()
GO
