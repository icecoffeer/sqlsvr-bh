SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2CHK_0TO1_SW_INV](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @p_line smallint,
  @p_gdgid int,
  @usergid int,
  @cur_settleno int,
  @cur_date datetime,
  @err_msg varchar(200) = '' output
) as
begin
  declare @d_wrh int, @d_qty money, @d_adjcost money
  
  select @d_wrh = WRH, @d_qty = QTY, @d_adjcost = ADJCOST
    from IPA2INVDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
      and LINE = @p_line
  if not exists (select 1 from SUBWRHINV
    where WRH = @d_wrh and GDGID = @p_gdgid and SUBWRH = @p_subwrh)
  begin
    select @err_msg = '审核库存明细的时候意外发现批次库存中没有对应记录。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  update SUBWRHINV set 
    COST = COST + @d_adjcost,
    LSTINPRC = (COST + @d_adjcost) / QTY
    where WRH = @d_wrh and GDGID = @p_gdgid and SUBWRH = @p_subwrh
  insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I)
    values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_qty, @d_adjcost)
  update IPA2INVDTL set
    LACTIME = getdate()
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh 
      and LINE = @p_line
  
  return(0)
end
GO
