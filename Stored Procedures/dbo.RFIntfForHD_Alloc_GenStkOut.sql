SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alloc_GenStkOut](
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @return_status int,
    @fetch_status int,
    @d_ClientCode char(10),
    @d_WrhCode char(10)

  /*声明游标。
  1.获取分单条件（配往单位+仓位）；
  2.包含不合法的数据（配往单位、仓位）的记录不要取出。
  */
  declare c_RFAlloc_0 cursor for
    select distinct d.CLIENTCODE, d.WRHCODE
    from RFALLOC d(nolock)
    inner join STORE s(nolock) on d.CLIENTCODE = s.CODE
    inner join WAREHOUSE w(nolock) on d.WRHCODE = w.CODE
    where d.OPERATORCODE = @piEmpCode
    and d.GENBILLNAME is null
    and d.GENBILLNUM is null
    and d.GENTIME is null
    order by d.CLIENTCODE, d.WRHCODE
  open c_RFAlloc_0

  /*返回值。
  1.当该值不为0时，存储过程须立刻返回；
  2.返回前须确保 @poErrMsg 不为空；
  3.返回前须确保游标已被释放。
  */
  set @return_status = 0

  --一条游标记录生成一张单据（除非记录中包含不合法的数据）。
  fetch next from c_RFAlloc_0 into @d_ClientCode, @d_WrhCode
  set @fetch_status = @@fetch_status
  while @fetch_status = 0
  begin
    exec @return_status = RFIntfForHD_Alloc_GenOneStkOut @piEmpCode,
      @d_ClientCode, @d_WrhCode, @poErrMsg output
    if @return_status <> 0
      goto LABEL_BEFORE_EXIT

    fetch next from c_RFAlloc_0 into @d_ClientCode, @d_WrhCode
    set @fetch_status = @@fetch_status
  end

LABEL_BEFORE_EXIT:
  close c_RFAlloc_0
  deallocate c_RFAlloc_0
  return @return_status
end
GO
