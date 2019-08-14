SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_To800_Eon1_ChkPrc]
(
 @p_cls int,
 @p_num varchar(14),
 @d_line int,
 @d_gdgid int,
 @d_QpcStr varchar(15),
 @msg varchar(255) output
)
With Encryption
As
Begin
  declare
    @rtlprc money,
    @lwtprc money,
    @topprc money,
    @tmp1 varchar(10),
    @tmp2 varchar(10),
    @tmp3 varchar(10),
    @ret int

  set @ret = 0
  --最高售价
  if @p_cls & 4 = 4
  begin
    set @tmp1 = '新最高售价'
    select @topprc = newtopprc from rtlprcadjdtl(nolock)
      where num = @p_num and line = @d_line and gdgid = @d_gdgid
  end
  else
  begin
    set @tmp1 = '最高售价'
    select @topprc = isnull(Qpctoprtlprc,900000000000000) from V_QPCGOODS(nolock)
      where gid = @d_gdgid and QpcQpcStr = @d_QpcStr
  end
  --最低售价
  if @p_cls & 2 = 2
  begin
    set @tmp2 = '新最低售价'
    select @lwtprc = newlwtprc from rtlprcadjdtl(nolock)
      where num = @p_num and line = @d_line and gdgid = @d_gdgid
  end
  else
  begin
    set @tmp2 = '最低售价'
    select @lwtprc = isnull(Qpclwtrtlprc,-900000000000000) from V_QPCGOODS(nolock)
      where gid = @d_gdgid and QpcQpcStr = @d_QpcStr
  end
  --核算售价
  if @p_cls & 1 = 1
  begin
    set @tmp3 = '新核算售价'
    select @rtlprc = newrtlprc from rtlprcadjdtl(nolock)
      where num = @p_num and line = @d_line and gdgid = @d_gdgid
  end
  else
  begin
    set @tmp3 = '核算售价'
    select @rtlprc = Qpcrtlprc from V_QPCGOODS(nolock) where gid = @d_gdgid and QpcQpcStr = @d_QpcStr
  end
  if @lwtprc > @rtlprc
  begin
    set @ret = 1
    set @msg = @tmp3 + '不能低于' + @tmp2
    return @ret
  end
  if @topprc < @rtlprc
  begin
    set @ret = 1
    set @msg = @tmp3 + '不能高于' + @tmp1
  end
  return @ret
End
GO
