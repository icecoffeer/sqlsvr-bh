SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_To800_Eon1_ChkGdPrcAdj]
(
  @p_cls varchar(10),
  @p_num varchar(14),
  @d_gdgid int,
  @d_line int,
  @launch datetime,
  @fildate datetime,
  @msg varchar(255) output
) with encryption as
begin
  declare @lastadjtime datetime,
          @lastadjnum varchar(14),
          @lastfildate datetime,
          @ret int

  set @ret = 0
  if exists(select 1 from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @p_cls)
    begin
      select
        @lastadjtime = lstadjtime, @lastadjnum = prcadjnum, @lastfildate = prcadjfildate
      from gdprcadj(nolock) where gdgid = @d_gdgid and cls = @p_cls
      if @launch is not null
      begin
        if @launch < @lastadjtime
        begin
          set @msg = '调价单' + @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
          set @ret = 1
        end
      end
      else
      begin
        if @lastfildate is not null and (@fildate <  @lastfildate)
        begin
          set @msg = '调价单' + @lastadjnum + '上同种商品已生效并在本调价单生效日期之后'
          set @ret = 1
        end
      end
    end
  return @ret
end
GO
