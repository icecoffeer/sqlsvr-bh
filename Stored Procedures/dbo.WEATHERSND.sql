SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[WEATHERSND]
(
 @RCVGID int,
 @ADATE datetime,
 @WEATHER int,
 @SPECCOND varchar(100),
 @LOWTMPER decimal,
 @HIGHTMPER decimal
) as
begin
  declare
    @user_gid int,
    @n_billid int
  select @user_gid = UserGid from System(nolock)
  execute GetNetBillId @n_billid output
  insert into NSENDWEATHER(ADATE, ID, SRC, RCV, WEATHER, SPECCOND, LOWTMPER, HIGHTMPER, TYPE, SNDTIME)
    select @ADATE, @n_billid, @user_gid, @RCVGID, @WEATHER, @SPECCOND, @LOWTMPER, @HIGHTMPER, 0, getdate() 
  return(0);                       
end                              
GO
