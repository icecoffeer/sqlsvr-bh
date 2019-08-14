SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[INPRCADJINVDTLCHK](
  @p_cls char(10),
  @p_num char(10),
  @p_line smallint,
  @p_gdgid int,
  @p_newprc money,
  @cur_date datetime,
  @cur_settleno int,
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @d_wrh int,
    @d_subwrh int,
    @d_qty money,
    @d_adjcost money

  select @d_wrh = WRH, @d_subwrh = SUBWRH,
    @d_qty = QTY, @d_adjcost = ADJCOST
    from INPRCADJINVDTL
    where CLS = @p_cls and NUM = @p_num and LINE = @p_line
  update SUBWRHINV set LSTINPRC = @p_newprc, COST = @d_qty * @p_newprc
    where WRH = @d_wrh and SUBWRH = @d_subwrh
      and GDGID = @p_gdgid
  insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
    values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_qty, @d_adjcost)
  update INPRCADJINVDTL set LACTIME = getdate()
    where CLS = @p_cls and NUM = @p_num and LINE = @p_line

  return(0)
end

GO
