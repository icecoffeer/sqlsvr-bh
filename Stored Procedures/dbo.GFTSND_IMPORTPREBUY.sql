SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_IMPORTPREBUY]
(
  @piPosNo varchar(10),         --转销售前收银机号
  @piFlowNo varchar(14),        --转销售前流水号
  @poErrMsg varchar(255) output --错误消息
)
as
begin
  --删除临时表中指定交易的记录（避免在下一步中插入重复记录）
  delete from TMPGFTSNDSALE where SPID = @@spid and POSNO = @piPosNo and FLOWNO = @piFlowNo

  --向临时表中插入指定交易的商品明细信息
  insert into TMPGFTSNDSALE(SPID, CLS, POSNO, FLOWNO, GDGID, QTY, AMT, SALETIME, TAG, DEDUCTAMT, PRMTAG)
    select @@spid, '预售收银条', @piPosNo, @piFlowNo, b2.GID, sum(b2.QTY), sum(b2.REALAMT), b1.FILDATE, 0, 0, b2.PRMTAG
    from PREBUY1 b1(nolock), PREBUY2 b2(nolock)
    where 1 = 1
    and b1.POSNO = b2.POSNO
    and b1.FLOWNO = b2.FLOWNO
    and b1.POSNO = @piPosNo
    and b1.FLOWNO = @piFlowNo
    group by b1.FILDATE, b2.GID, b2.PRMTAG

  return(0)
end
GO
