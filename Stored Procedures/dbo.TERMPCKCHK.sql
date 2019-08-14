SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[TERMPCKCHK](
  @p_firstnum char(13),
  @maxcount int
)as
begin
  declare @fetch int, @idno int, @wrhgid int, @gdgid int, @inputergid int, @count int, @settleno int, @twrh int, @store int,
          @line int, @last_idno int, @egid int, @return_status int, @nline int, @nId int
  declare @termno char(13), @wrhcode char(13), @gcode varchar(40), @inputer char(13),@num char(13),@subwrhcode char(20),
          @last_wrhcode  char(13), @last_inputer char(13),@last_termno char(13), @last_subwrhcode char(20)
  declare @gdrtlprc money, @rtlprc  money, @inprc  money, @total money, @qty money , @linkqty money

  declare @filldate datetime, @keptdate datetime

  select @count=0
  select @filldate = getdate()
  select @settleno = max(no) from monthsettle

  delete from termpool
  delete from termpool2 where gcode not in (select code from gdinput) --add by qyx 2003.7.10

  --重新设置termpool2的行号
  select @nline = 1
  declare Cur_Dotermpool2 cursor for
    select id from termpool2
  open Cur_Dotermpool2
  fetch next from Cur_Dotermpool2 into @nid
  while @@Fetch_Status = 0
  begin
    update termpool2 Set Line = @nline
      Where current of Cur_Dotermpool2

    select @nline = @nline + 1
  fetch next from Cur_Dotermpool2 into @nid
  end
  close Cur_Dotermpool2
  deallocate Cur_Dotermpool2
  --将重新序列化过的数据写入termpool
  insert termpool(ID, TERMNO, LINE, WRHCODE, INPUTER, GCODE, FILDATE, QTY, PRICE, AMOUNT, SUBWRHCODE)
  Select id, termno, Line, wrhcode, inputer, gcode, fildate, qty, price ,amount, subwrhcode
    From termpool2

  if @p_firstnum is null
  begin
    select @num = max(num) from PCK
    if (@num is null)
      select @num = '0000000001'
    else
      execute NEXTBN @num, @num output
  end
  else
  begin
    select @num = @p_firstnum
    if exists(select 1 from PCK where NUM = @num)
    begin
      select @num = max(NUM) from PCK
      execute NEXTBN @num, @num output
    end
  end

  declare goodscursor cursor for
    select  id, termno, line, wrhcode, inputer, gcode, price ,qty, amount, subwrhcode  --ShenMin
      from termpool
    order by id,termno, wrhcode ,inputer, subwrhcode --ShenMin
  open goodscursor
  fetch next from goodscursor
   into @idno, @termno, @line, @wrhcode, @inputer, @gcode, @rtlprc, @qty, @total, @subwrhcode
  if @@fetch_status <> 0
  begin
    close GoodsCursor
    deallocate GoodsCursor
    raiserror( 'Termpool is null !' ,16,-1)
    return 1
  end
  select @last_wrhcode = @wrhcode, @last_inputer = @inputer
  select @last_subwrhcode = @subwrhcode --ShenMin
  select @last_idno=@idno , @last_termno =@termno
  select @wrhgid = gid  from warehouse where code = @wrhcode
  select @inputergid = gid from employee where code = @inputer

  insert into PCK( Num, SettleNo, FilDate, Filler, Wrh, Stat, RecCnt, Note)
  values(@num, @settleno, @filldate, @inputergid, @wrhgid, 0, 0, ' abcd' )
  if @@error <> 0
  begin
    close GoodsCursor
    deallocate GoodsCursor

    raiserror( 'usp inportPCK: insert into PCK failed!' ,16,-1 )
    return 1
  end
  select @fetch= @@fetch_status
  while @fetch = 0
  begin
    --old code //select @gdgid=gid, @gdrtlprc = RTLPRC from goods where code= @gcode
    --new code 2001-8-22
    select @gdgid=goods.gid, @gdrtlprc = goods.RTLPRC
      from goods,gdinput
    where goods.gid = gdinput.gid and gdinput.code = @gcode
    if @total = 0
      select @total = @qty * @gdrtlprc

    --判断goods.idpkg和pkg是否匹配  2000.6.2
    if (select ispkg from goods where gid = @gdgid) = 1
    begin
      exec @return_status = GETPKG @gdgid, @egid output, @linkqty output
      if @return_status = 1
      begin
     --2003-04-15 added by wangxin
        select @qty = @qty * @linkqty
        select @gdgid=goods.gid, @gdrtlprc = goods.RTLPRC from goods where goods.gid = @egid
        if @total = 0
          select @total = @qty * @gdrtlprc
      end
      else
      begin
        fetch next from goodscursor
          into @idno, @termno, @line, @wrhcode, @inputer, @gcode, @rtlprc, @qty, @total, @subwrhcode
        select @fetch= @@fetch_status
        continue
      end
    end

    if not exists (select * from pckdtl where num=@num and gdgid=@gdgid )
    begin
      if exists (select * from ckinv where wrh = @wrhgid and gdgid=@gdgid )
      begin
        select @count = @count + 1
        insert into PCKDTL( NUM, LINE, SETTLENO, STAT,
          GDGID, QTY, TOTAL )
        values( @num, @count, @settleno, 0,
          @gdgid, @qty, @total )
        delete from termpool where id=@idno and termno=@termno and line=@line
      end
      else
      begin
        select @twrh = @wrhgid
        select @store = null
        select @store = gid from store where gid = @wrhgid
        if @store is null
          select @store = usergid from system
        else
          select @twrh = 1
        if not exists (select * from inv where wrh=@twrh and gdgid=@gdgid  and store = @store)
        begin
          select @keptdate = getdate()
          execute snapinv @wrhgid, @gdgid, 0, 0, @keptdate, 0, 1, 0, 0
          if @@error<>0
          begin
            close GoodsCursor
            deallocate GoodsCursor
            raiserror( ' snapinv error ' ,16,-1 )
            return 1
          end
          select @count = @count + 1
          insert into pckdtl( num, line, settleno, stat, gdgid, qty,  total)
          values(@num,@count,@settleno, 0, @gdgid, @qty, @total)
          if @@error<>0
          begin
            close GoodsCursor
            deallocate GoodsCursor
            raiserror(' inert into pckdtl failed! ', 16,-1)
            return 1
          end
          delete from termpool where id=@idno and termno=@termno and line=@line
        end else
        begin
          close GoodsCursor
          deallocate GoodsCursor

          raiserror(' 请先作库存记录再导入数据!',16,-1)
          return 1
        end
      end
    end
    else
    begin
      update pckdtl
       set qty = qty+ @qty, total = total+@total
      where num=@num and gdgid=@gdgid
      delete from termpool where id=@idno and termno=@termno and line=@line
    end
    select @last_wrhcode = @wrhcode, @last_inputer = @inputer
    select @last_idno=@idno , @last_termno =@termno
    fetch next from goodscursor
      into @idno, @termno, @line, @wrhcode, @inputer, @gcode, @rtlprc, @qty, @total, @subwrhcode  --ShenMin
    select @fetch = @@fetch_status
    if ( @maxcount > 0 and @count >= @maxcount )
      or @last_wrhcode<>@wrhcode
      or @last_inputer<>@inputer
      or @last_termno<>@termno
      or @last_idno<>@idno
      or @last_subwrhcode<>@subwrhcode  --ShenMin
    begin
      select @inputergid=gid from employee where code=@inputer
      select @wrhgid= gid from warehouse where code=@wrhcode
      update pck
        set reccnt = @count ,
        note=' 本盘点单由 : '+ @last_termno +' 号盘点机 ' + '盘点员'  + @last_inputer + '生成 ！'
      where num=@num
      execute PCKCHK  @num

      execute NEXTBN @num, @num output
      if exists(select * from PCK where NUM = @num)
      begin
        select @num = max(num) from PCK
        execute NEXTBN @num, @num output
        --select @num
      end
      select @count=0

      insert into PCK( Num, SettleNo, FilDate, Filler,
        Wrh, Stat, RecCnt, Note )
      values(@num , @settleno, @filldate, @inputergid, @wrhgid, 0, 0, 'aa' )
    end
  end
  close GoodsCursor
  deallocate GoodsCursor

  if @count <> 0
  begin
    update pck
      set reccnt = @count , note=' 本盘点单由 : '+ @last_termno +' 号盘点机 ' + '盘点员'  + @last_inputer + '生成 ！'
    where num = @num
    execute pckchk @num
  end else
    delete from pck where num=@num

  return 0
end
GO
