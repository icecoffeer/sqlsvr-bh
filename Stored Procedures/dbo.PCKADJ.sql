SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKADJ](
  @p_num char(10)
) as
begin
  update PCK set STAT = 1 where
    STAT = 0 and not exists
    (select * from PCKDTL where PCKDTL.STAT = 0 and PCKDTL.NUM = PCK.NUM)
end
GO
