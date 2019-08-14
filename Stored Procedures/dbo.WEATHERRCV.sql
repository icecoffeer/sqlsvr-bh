SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[WEATHERRCV](
  @p_src int,
  @p_id int
)
as
begin
  declare
    @date datetime
  select @date = ADATE from NSENDWEATHER where SRC = @p_src and ID = @p_id
  delete from STOREWEATHER where ADATE = @date and SRC = @p_src
  insert into STOREWEATHER(ADATE, SRC, RCV, WEATHER, SPECCOND, LOWTMPER, HIGHTMPER, SNDTIME, RCVTIME) 
    select ADATE, SRC, RCV, WEATHER, SPECCOND, LOWTMPER, HIGHTMPER, SNDTIME, RCVTIME from NSENDWEATHER(nolock) where SRC = @p_src and ID = @p_id
  delete from NSENDWEATHER where SRC = @p_src and ID = @p_id
  return(0);                       
end                              
GO
