SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRBEPADJ_MODIFYTO800] (
  @num varchar(14),
  @oper varchar(30),
  @msg varchar(255) output
) as
begin
  declare @vdrgid int
  declare @strgid int
  declare @total money
  update VDRBEPADJ
    set LSTUPDTIME = GETDATE(), LSTUPDOPER = @oper
    where NUM = @num;
  --影响其他单据
  insert into VDRBEP(VDRGID, STOREGID, BILLNUM, BILLLINE, BEGINDATE, ENDDATE, TOTAL, DEPT)
    select V.VDRGID, VL.STOREGID, VL.NUM, VL.LINE, V.BEGINDATE, V.ENDDATE, VL.TOTAL, V.DEPT  
    from VDRBEPADJ V, VDRBEPADJDTL VL
    where V.NUM = @num and VL.NUM = @num 
  --exec VDRBEPADJ_ADD_LOG @Num, 800, '生效', @Oper; 
  return 0
end
GO
