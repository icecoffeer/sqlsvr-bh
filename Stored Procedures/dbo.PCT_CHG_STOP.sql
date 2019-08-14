SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHG_STOP] (
  @piChgCode varchar(10),         --帐款项目代码
  @piOperGid integer,             --操作人
  @poErrMsg varchar(255) output   --出错信息
) as
begin
  update CTCHGDEF set STOPPED = 1 where CODE = @piChgCode
  return(0)
end
GO
