SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_SDLAC](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @d_store int, @usergid int
  declare @o_adjcost money, @o_adjincost money, @o_adjinvcost money, @o_adjoutcost money,
    @o_adjalcamt money

  select @usergid = USERGID from SYSTEM

  declare c2 cursor for
    select STORE
    from IPA2LACDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
    for update
  open c2
  fetch next from c2 into @d_store
  while @@fetch_status = 0
  begin
    select @o_adjincost = isnull(sum(ADJINCOST), 0),
      @o_adjoutcost = isnull(sum(ADJOUTCOST), 0),
      @o_adjalcamt = isnull(sum(ADJALCAMT), 0)
      from IPA2DTL
      where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh and STORE = @d_store
    select @o_adjinvcost = isnull(sum(ADJCOST), 0)
      from IPA2INVDTL
      where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh and STORE = @d_store
    update IPA2LACDTL set
      ADJINCOST = @o_adjincost,
      ADJOUTCOST = @o_adjoutcost,
      ADJALCAMT = @o_adjalcamt,
      ADJINVCOST = @o_adjinvcost
      where current of c2
    fetch next from c2 into @d_store
  end
  close c2
  deallocate c2

  select @o_adjcost = isnull(sum(ADJCOST), 0)
    from IPA2SWDTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh

  update IPA2LACDTL set ADJCOST = @o_adjcost 
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh and STORE = @usergid
end
GO
