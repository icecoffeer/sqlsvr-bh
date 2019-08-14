SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFCHKFIFO] (
  @num varchar(14),
  @line int,
  @wrh smallint,
  @subwrh smallint,
  @gdgid int,
  @qty money,
  @taxrate money,
  @saletax money,
  @storeflag smallint,
  @fromprice money output,
  @fromtotal money output,
  @fromtax money output,
  @fromcost money output,
  @toprice money output,
  @tototal money output,
  @totax money output,
  @tocost money output
) with encryption as
begin
  declare @return_status int
  declare @cost money,         @newsubwrh int,      @newcost money,
          @newtotal  money,    @newprice money,
          @newouttax money,    @newtax money,       @d_subwrh int,
          @d_qty money,        @d_cost money,       @d_newcost money,
          @newlstinprc money,  @modflag int,        @getlstinprcmode int

  select @return_status = 0
  select @subwrh = null

  if @qty < 0 return -1

  if @storeflag = 0
  begin
    exec cleartempsubwrh @gdgid, @wrh
    if exists (select 1 from MXFDTL2 where NUM = @num and LINE = @line)
       insert into TEMPSUBWRH(SPID,WRH,SUBWRH,GDGID,QTY,COST)
         select @@SPID,WRH,SUBWRH,GDGID,QTY,COST from MXFDTL2
         where NUM = @num and LINE = @line

    exec @return_status = unloadsubwrh_2 @gdgid, @wrh, @qty, @cost output
    if @return_status <> 0 return @return_status

    delete from MXFDTL2 where NUM = @num and LINE =@line
    insert into MXFDTL2 (NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST,FROMTO)
      select @num, @line, subwrh, wrh, gdgid ,qty, cost, -1 from TEMPSUBWRH
      where SPID = @@SPID AND GDGID = @gdgid AND WRH = @wrh

    select @newsubwrh = min(SUBWRH) from TEMPSUBWRH where SPID = @@SPID AND GDGID = @gdgid AND WRH = @wrh

    select @newtotal = @cost
    select @newprice = @newtotal / @qty
    select @newouttax = @newtotal - (@newtotal)/(1 + @saletax/100)
    select @newtax = @newtotal - (@newtotal)/(1 + @taxrate/100)

    update MXFDTL set SUBWRH = @newsubwrh,
                      FROMCOST = @cost, FROMTOTAL = @newtotal, FROMPRICE = @newprice, FROMTAX =@newouttax,
                      TOCOST = @cost, TOTOTAL = @newtotal, TOPRICE = @newprice, TOTAX =@newtax
      where NUM = @num and LINE = @line

    update MXF set FROMTOTAL = FROMTOTAL + (@cost - @fromtotal), FROMTAX = FROMTAX + (@newouttax - @fromtax),
                   TOTOTAL = TOTOTAL + (@cost - @tototal), TOTAX = TOTAX + (@newtax - @totax),
                   FROMCOST = FROMCOST + @cost,
		   TOCOST = TOCOST + @cost
      where NUM = @num

    select @fromprice = @newprice, @fromtotal = @newtotal, @fromtax =@newouttax , @fromcost = @cost,
           @toprice = @newprice, @tototal = @newtotal, @totax =@newtax , @tocost = @cost
  end
  else if @storeflag = 1
  begin
    select @modflag = 0

    declare c_mxfdtl2 cursor for
      select SUBWRH, QTY, COST
      from MXFDTL2 where NUM = @num and LINE = @line order by subwrh
    open c_mxfdtl2
    fetch next from c_mxfdtl2 into @d_subwrh, @d_qty, @d_cost
    while @@fetch_status = 0 begin
      exec @return_status = getsubwrh2lstinprc @gdgid, @d_subwrh, @newlstinprc output, @getlstinprcmode output
      if @return_status <> 0 return @return_status

      if @newlstinprc is not null
      begin
        select @d_newcost = round(@d_qty * @newlstinprc,2)

        if @d_cost <> @d_newcost
        begin
          update MXFDTL2 set COST = @d_newcost
            where NUM = @num and LINE = @line and GDGID = @gdgid and SUBWRH = @d_subwrh and FROMTO = -1

          select @modflag = 1
        end
      end

      fetch next from c_mxfdtl2 into  @d_subwrh, @d_qty, @d_cost
    end
    close c_mxfdtl2
    deallocate c_mxfdtl2

    if @modflag = 1
    begin
      select @newcost = sum(COST) from MXFDTL2 where NUM = @num and LINE = @line and FROMTO = -1

      select @newtotal = @newcost
      select @newprice = @newtotal / @qty
      select @newtax = @newtotal - (@newtotal)/(1 + @taxrate/100)

      update MXFDTL set FROMCOST = @newcost,
                        TOCOST = @newcost, TOTOTAL = @newtotal, TOPRICE = @newprice, TOTAX =@newtax
        where NUM = @num and LINE = @line

      update MXF set TOTOTAL = TOTOTAL + (@newcost - @tototal), TOTAX = TOTAX + (@newtax - @totax),
                     FROMCOST = FROMCOST + (@newcost - @fromcost), TOCOST = TOCOST + (@newcost - @tocost)
        where NUM = @num

      select @fromcost = @newcost,
             @toprice = @newprice, @tototal = @newtotal, @totax =@newtax , @tocost = @newcost
    end

    delete from MXFDTL2 where NUM = @num and LINE =@line and FROMTO = 1
    insert into MXFDTL2 (NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST,FROMTO)
      select NUM, LINE, SUBWRH, WRH, GDGID ,QTY, COST, 1 from MXFDTL2
      where NUM = @num and LINE = @line and FROMTO = -1
  end
  else if @storeflag = 2
  begin
    exec cleartempsubwrh @gdgid, @wrh
/*
    if exists (select 1 from MXFDTL2 where NUM = @num and LINE = @line)
       insert into TEMPSUBWRH(SPID,WRH,SUBWRH,GDGID,QTY,COST,BILL,CLS,NUM,LINE)
         select @@SPID,WRH,SUBWRH,GDGID,QTY,COST,'MXF','调入',@num,@line from MXFDTL2
         where NUM = @num and LINE = @line
*/

    if exists (select 1 from MXFDTL2 where NUM = @num and LINE = @line)
       insert into TEMPSUBWRH(SPID,WRH,SUBWRH,GDGID,QTY,COST)
         select @@SPID,WRH,SUBWRH,GDGID,QTY,COST from MXFDTL2
         where NUM = @num and LINE = @line

    exec @return_status = loadinsubwrh_2 @gdgid, @wrh ,@qty, @tototal
    if @return_status <> 0 return @return_status

    delete from MXFDTL2 where NUM = @num and LINE =@line

    insert into MXFDTL2 (NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST,COSTADJ,FROMTO)
      select @num, @line, subwrh, wrh, gdgid ,qty, cost, costadj, 1 from TEMPSUBWRH
      where SPID = @@SPID AND GDGID = @gdgid AND WRH = @wrh

    select @newsubwrh = min(SUBWRH), @newcost = sum(COST) from TEMPSUBWRH where SPID = @@SPID and GDGID = @gdgid AND WRH = @wrh

    if @newcost <> @tototal
    begin
      select @newtotal = @newcost
      select @newprice = @newtotal / @qty
      select @newouttax = @newtotal - (@newtotal)/(1 + @saletax/100)
      select @newtax = @newtotal - (@newtotal)/(1 + @taxrate/100)

      update MXFDTL set SUBWRH = @newsubwrh,
                        FROMCOST = @newcost, FROMTOTAL = @newtotal, FROMPRICE = @newprice, FROMTAX =@newouttax,                        TOCOST = @newcost, TOTOTAL = @newtotal, TOPRICE = @newprice, TOTAX =@newtax
        where NUM = @num and LINE = @line

      update MXF set FROMTOTAL = FROMTOTAL + (@newcost - @fromtotal), FROMTAX = FROMTAX + (@newouttax - @fromtax),
                     TOTOTAL = TOTOTAL + (@newcost - @tototal), TOTAX = TOTAX + (@newtax - @totax)
        where NUM = @num

      select @fromprice = @newprice, @fromtotal = @newtotal, @fromtax =@newouttax , @fromcost = @newcost,
             @toprice = @newprice, @tototal = @newtotal, @totax =@newtax , @tocost = @newcost
    end
  end

  exec cleartempsubwrh @gdgid, @wrh
  return(@return_status)
end
GO
