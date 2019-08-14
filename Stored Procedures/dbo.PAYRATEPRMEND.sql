SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYRATEPRMEND]
(
  @p_num char(14),
  @p_Oper VARCHAR(30),
  @poErrMsg varchar(255) output
) as
begin
	declare
    @stat smallint
  select @stat = stat from PAYRATEPRM where num = @p_num
  select @poErrMsg = ''
  if (@stat <> 800)
  begin
    select @poErrMsg = '要终止的单据不是已生效状态，不能终止。'
    return(1)
  end	
  --写联销率促销当前值表
  delete from PAYRATEPRICE where SRCNUM = @p_num
  update PAYRATEPRM set stat = 1400,LASTMODIFIER = @p_Oper,
  LSTUPDTIME = getdate() 
  where num = @p_num
  return(0)
end
GO
