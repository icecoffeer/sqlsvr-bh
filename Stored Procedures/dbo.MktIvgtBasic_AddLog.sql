SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MktIvgtBasic_AddLog]
(
  @piNum	char(14),
  @piStat	int,
	@Act    VarChar(50),
  @piOper varchar(30),
  @piOperGid int = -1
)
as
begin
  if @piOperGid > 0 and @piOper = ''
    select @piOper = rtrim(e.name) + '[' + rtrim(e.code) + ']'
      from Employee e where e.gid = @piOperGid
	If Rtrim(@piOper) = '' 
	Begin
		Declare @FillerCode Varchar(20), 		  
		        @Filler Int, 
		        @Fillername Varchar(50)
		Set @FillerCode = Rtrim(Substring(Suser_Sname(), Charindex('_', Suser_Sname()) + 1, 20))
		Select @Filler = Gid, @Fillername = Name From Employee(Nolock) Where Code Like @FillerCode
		If @Fillername Is Null 
		Begin
			Set @Fillercode = '-'
			Set @Fillername = '未知'
		End
		Set @piOper = Rtrim(Isnull(SubString(@Fillername, 0, 28 - DataLength(RTrim(@Fillercode))),'')) 
		  + '['+Rtrim(Isnull(@Fillercode,''))+']'
	End
	If @Act = '' 
		Select @Act = ActName From ModuleStat Where No = @piStat

  insert into PSMktIvgtBasicLog(Num, Stat, Act, Modifier, Time) 
  select @piNum, @piStat, @Act, @piOper, getdate()
  return(0)
end
GO
