SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_SDSWDTL](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @s_adjincost money, @s_adjinvcost money, @s_adjoutcost money,
    @s_adjalcamt money
  
  select @s_adjincost = isnull(sum(ADJINCOST), 0),
    @s_adjinvcost = isnull(sum(ADJINVCOST), 0),
    @s_adjoutcost = isnull(sum(ADJOUTCOST), 0),
    @s_adjalcamt = isnull(sum(ADJALCAMT), 0)
    from IPA2LACDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
  update IPA2SWDTL set
    ADJINCOST = @s_adjincost,
    ADJINVCOST = @s_adjinvcost,
    ADJOUTCOST = @s_adjoutcost,
    ADJALCAMT = @s_adjalcamt 
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
/*
  update IPA2SWDTL set
     COST = NEWPRC * QTY - ADJCOST
      where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
*/
  return(0)
end
GO
