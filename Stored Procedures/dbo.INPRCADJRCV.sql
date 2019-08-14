SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[INPRCADJRCV](
  @p_src int,
  @p_id int,
  @p_checker int,
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @cur_settleno int,
    @n_cls char(10),
    @n_num char(10),
    @n_type smallint,
    @n_vendor int,
    @n_gdgid int,
    @n_checker int,
    @n_oldsrc int,
    @n_psr int,
    @n_frcflag smallint,
    @l_vendor int,
    @l_gdgid int,
    @l_filler int,
    @l_psr int

  select @cur_settleno = max(NO)
    from MONTHSETTLE
  select @n_cls = CLS, @n_num = NUM,
    @n_type = TYPE, @n_vendor = VENDOR, @n_gdgid = GDGID,
    @n_checker = CHECKER, @n_psr = PSR,
    @n_oldsrc = OLDSRC, @n_frcflag = FRCFLAG
    from NINPRCADJ
    where SRC = @p_src and ID = @p_id
  if @@rowcount = 0
  begin
    select @err_msg = '指定的网络单据不存在(SRC = ' + rtrim(convert(char, @p_src)) + ', ID = ' + rtrim(convert(char, @p_id)) + ')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  if @n_type <> 1
  begin
    select @err_msg = '不是可接收单据。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end

  select @l_vendor = LGID from VDRXLATE where NGID = @n_vendor
  if @@rowcount = 0
  begin
    select @err_msg = '本地未包含供应商资料(GID = ' + rtrim(convert(char, @n_vendor)) + ')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  select @l_gdgid = LGID from GDXLATE where NGID = @n_gdgid
  if @@rowcount = 0
  begin
    select @err_msg = '本地未包含商品资料(GID = ' + rtrim(convert(char, @n_gdgid)) + ')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  select @l_filler = LGID from EMPXLATE where NGID = @n_checker
  if @@rowcount = 0
  begin
    select @err_msg = '本地未包含审核人资料(GID = ' + rtrim(convert(char, @n_checker)) + ')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  select @l_psr = LGID from EMPXLATE where NGID = @n_psr
  if @@rowcount = 0
  begin
    select @err_msg = '本地未包含采购员资料(GID = ' + rtrim(convert(char, @n_psr)) + ')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end

  exec @ret_status = INPRCADJRCVGO @p_src, @p_id, @n_cls, @n_num, @n_oldsrc, @p_checker,
    @l_vendor, @l_gdgid, @l_filler, @l_psr, @n_frcflag, @err_msg output
  if @ret_status <> 0
  begin
    raiserror(@err_msg, 16, 1)
    return(@ret_status)
  end

  delete from NINPRCADJAINVDTL where SRC = @p_src and ID = @p_id
  delete from NINPRCADJINVDTL where SRC = @p_src and ID = @p_id
  delete from NINPRCADJDTL where SRC = @p_src and ID = @p_id
  delete from NINPRCADJ where SRC = @p_src and ID = @p_id
  
  select @ret_status = 0

  return (@ret_status)
end

GO
