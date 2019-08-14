SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoPrcRcv]
	@SRC int,
	@ID int,
	@ErrMsg varchar(200) output
as
begin
  declare @Result int, @CurPrc int, @RcvDef int
  select @CurPrc = 
  	case cls
	when '核算售价' then 1
	when '核算价' 	then 2
	when '最低售价' then 4
	when '批发价' 	then 8
	when '代销价' 	then 16
	when '联销率' 	then 32
	when '会员价' 	then 64
	when '合同进价' then 128
	when '量贩价' 	then 256
	when '积分'	then 512
	else 0
	end
  from nprcadj(nolock) where src = @src and ID = @ID

	select @RcvDef = convert(int,isnull(optionvalue,'0')) from 
		hdoption(nolock) where moduleno = 0 and optioncaption = 'FTPPRCRCVCTRL'
	
	if @RcvDef & @CurPrc <> 0
	  	execute @Result = PRCADJRCV @src, @id, 1

  return @Result 
end
GO
