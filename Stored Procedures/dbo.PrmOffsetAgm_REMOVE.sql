SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PrmOffsetAgm_REMOVE]
(
    @Num varchar(14),                    --协议号
    @Msg varchar(256) output          --出错信息
) as
begin

  return 0
end
GO
