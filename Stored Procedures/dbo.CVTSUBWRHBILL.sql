SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CVTSUBWRHBILL](
  @p_subwrh int,
  @p_bill char(10) output,
  @p_cls char(10) output,
  @p_num char(10) output,
  @p_line smallint output
) with encryption as
begin
  declare
    @err_msg varchar(200)

  select @p_bill = 'STKIN', @p_cls = m.CLS, @p_num = m.NUM, @p_line = LINE
    from STKIN m inner join STKINDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.STAT in (1, 4, 6)
      and d.SUBWRH = @p_subwrh
    order by m.FILDATE desc
  if @@rowcount > 0 return(0)

  select @p_bill = 'STKOUTBCK', @p_cls = m.CLS, @p_num = m.NUM, @p_line = LINE
    from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.STAT in (1, 4)
      and d.SUBWRH = @p_subwrh
    order by m.FILDATE desc
  if @@rowcount > 0 return(0)

  select @p_bill = 'RTLBCK', @p_cls = '', @p_num = m.NUM, @p_line = LINE
    from RTLBCK m inner join RTLBCKDTL d on m.NUM = d.NUM
    where m.STAT in (1, 4)
      and d.SUBWRH = @p_subwrh
    order by m.FILDATE desc
  if @@rowcount > 0 return(0)

  select @p_bill = 'DIRALC', @p_cls = m.CLS, @p_num = m.NUM, @p_line = LINE
    from DIRALC m inner join DIRALCDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.STAT in (1, 4) and m.CLS = '直配进'
      and d.SUBWRH = @p_subwrh
    order by m.FILDATE desc
  if @@rowcount > 0 return(0)

  select @err_msg = '找不到货位(GID=' + convert(char, @p_subwrh) + ')对应的进货单据。'
  raiserror(@err_msg, 16, 1)
  return(1)
end
GO
