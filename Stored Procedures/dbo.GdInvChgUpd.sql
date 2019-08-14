SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdInvChgUpd]
  @num char(10),
  @errmsg varchar(200) = '' output
with encryption as
begin
  declare
    @m_modnum char(10),   @m_oper int,     @m_stat smallint,
    @max_num char(10),    @neg_num char(10),
    @return_status int,      @conflict smallint

  select
    @m_modnum = MODNUM,    @m_oper = CHECKER
  from GDINVCHG where NUM = @num
  select @m_stat = STAT from GDINVCHG where NUM = @m_modnum

  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from GDINVCHG where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

    execute @return_status = GdInvChgDLTNum @m_modnum, @m_oper, @neg_num, @errmsg output
    if @return_status <> 0 return @return_status
    update GDINVCHG set STAT = 3 where NUM = @neg_num

    update GDINVCHG set STAT = 0 where NUM = @num
    execute @return_status = GdInvChgCHK @num, 0
    if @return_status <> 0 return @return_status

end
GO
