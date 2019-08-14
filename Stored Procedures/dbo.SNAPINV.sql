SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SNAPINV]
    @wrh int,
    @gdgid int,
    @newqty money,
    @newamt money,
    @keptdate char(24),
    @acttype smallint,
    @operator int,
    @subwrh int,
    @uppcks int
as
begin
    /*
    99-5-17: 改写'将该商品的大包装商品也记入CKINV'的写法
    99-7-6: 使用INV代替V_INV (LINE 68)
    99-8-23
          对于没有货位的仓位,加上未提数和销售退货数
          对于有货位的仓位,货位记录中的数量即为可用数
    */
    ---------------------------------------------------------
    -- Attention:
    --   This procedure used in Check for keeping
    -- the goods storage information. It will update
    -- CKINV and PCKS.
    --
    -- Parameters
    --   @acttype
    --     0: read and keep current goods information
    --     1: update CKINV and PCKS only from the user input
    --          while other column untouched.
    ---------------------------------------------------------

    declare @rtlprc money
    declare @inprc money
    declare @prctype smallint
    declare @total money
    declare @ovfamt money
    declare @losamt money
    declare @store int, @wrh_saved int
    declare @pgid int
    declare @oldqty money
    declare @oldtotal money
    declare @settleno int, @newqty2 money
    declare @invprc money, @invcost money --2002-10-11
    declare @opt_value int --2004-08-12

    select @settleno = max(no) from monthsettle(nolock)
    select @store = null, @wrh_saved = @wrh
    select @store = GID from STORE where GID = @wrh
    if @store is null select @store = USERGID from SYSTEM
    else select @wrh = 1

    if (@acttype = 0)
    begin
         select @rtlprc = g.rtlprc, @inprc = g.inprc,
            @prctype = g.prctype
        from GOODS g
        where g.gid = @gdgid
        if (@rtlprc is null)
        begin
            raiserror( 'SNAPINV: cannot find goods', 16, -1 )
            return
        end
        if @subwrh = 0  begin
          select @newqty = isnull(sum(v.qty),0), @newamt = isnull(sum(v.total),0)
          from INV v (nolock)
          where wrh = @wrh and gdgid = @gdgid and STORE = @store

          /* 99-8-23
          对于没有货位的仓位,加上未提数和销售退货数
          对于有货位的仓位,货位记录中的数量即为可用数
          */
          select @newqty2 = isnull(sum(dspqty)+sum(bckqty), 0)
          from INV v (nolock)
          where wrh = @wrh and gdgid = @gdgid and STORE = @store
          if @newqty <> 0
            select @newamt = @newamt * (1 + @newqty2 / @newqty)
          select @newqty = @newqty + @newqty2
          
          /*2002-10-11 读取库存价和库存成本*/
          select @invprc = INVPRC, @invcost = INVCOST 
            from GDWRH (nolock)
            where GDGID = @gdgid and WRH = @wrh_saved
          if @@rowcount = 0
          begin
            set @invcost = 0
            --2004-08-12
			exec OPTREADINT 0, 'InitInvPrc', 1, @opt_value output
			if @opt_value = 1
				select @invprc = CNTINPRC from GOODS (nolock) where GID = @gdgid
			else
				set @invprc = 0            
          end

          delete from CKINV where Wrh = @wrh_saved and GDGID = @gdgid
          insert into CKINV(wrh,gdgid,qty,total,keptdate,rtlprc,inprc,
            INVPRC, INVCOST)  --2002.10.11
          values( @wrh_saved, @gdgid, @newqty, @newamt, @keptdate, @rtlprc, @inprc,
            @invprc, @invcost )  --2002.10.11
          if @uppcks = 1
          begin
           if  not exists (select * from pcks(nolock) where wrh=@wrh_saved and gdgid=@gdgid and subwrh =0)
            insert into pcks( SETTLENO, GDGID, WRH, ACNTQTY, QTY,  ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC,subwrh)
                    values( @settleno,@gdgid ,@wrh_saved,@newqty,0,@newamt,0,0,0 ,@rtlprc,@inprc ,0)
          end
        end else begin
          select @newqty = isnull(sum(v.qty),0), @newamt = isnull(sum(v.total),0)
          from subwrhinv v (nolock)
          where wrh = @wrh and gdgid = @gdgid and subwrh =@subwrh
          delete from ckswi where wrh = @wrh and gdgid = @gdgid and subwrh =@subwrh
          insert into ckswi(wrh,subwrh,gdgid,qty,total,rtlprc,inprc)
                  values(@wrh_saved,@subwrh,@gdgid,@newqty,@newamt,@rtlprc,@inprc)
          if @uppcks = 1  begin
            if  not exists (select * from pcks(nolock) where wrh=@wrh_saved and gdgid=@gdgid and subwrh = @subwrh)
             insert into pcks( SETTLENO, GDGID, WRH, ACNTQTY, QTY,  ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC,subwrh)
                    values(@settleno,@gdgid,@wrh_saved,@newqty,0,@newamt,0,0,0,@rtlprc,@inprc ,@subwrh)
           end
	end



        /* 将该商品的大包装商品也记入CKINV.
        仅记录WRH,GDGID,KEPTDATE,其他字段为0.
        目的是为了能够让盘点单中输入这些商品.
        它们存在于PCKDTL和PCKS中,但PCKS中帐面和实盘均为0.
        在PCKDTLCHK时被转换. */

        /*
        if not exists (select * from CKINV where WRH = @wrh_saved and GDGID in
        (select PGID from PKG where EGID = @gdgid))
         begin
	  if @subwrh = 0
          insert into CKINV(wrh, gdgid, qty, total, keptdate, rtlprc, inprc)
          select @wrh_saved, PGID, 0, 0, @keptdate, rtlprc, inprc
          from PKG, GOODS
          where EGID = @gdgid
          and PGID = GID
        end
        */
        /* 替代上面被注解掉的写法 */
        declare pkg cursor for select pgid from pkg (nolock) where egid=@gdgid
        open pkg
        fetch next from pkg into @pgid
        while @@fetch_status = 0
        begin
             if @subwrh = 0 begin
             delete from ckinv where wrh=@wrh_saved and gdgid=@pgid
             insert into CKINV(wrh, gdgid, qty, total, keptdate, rtlprc, inprc,
               INVPRC, INVCOST)  --2002-10-11
             select @wrh_saved,@pgid ,0,0,@keptdate,rtlprc,inprc, 0, 0  --2002-10-11
             from goods where gid=@pgid
             if @uppcks = 1 begin
              if not exists( select * from pcks(nolock) where wrh = @wrh_saved and gdgid = @pgid and subwrh = @subwrh)
              insert into pcks( SETTLENO, GDGID, WRH, ACNTQTY, QTY,  ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC,subwrh)
                  values(@settleno,@pgid,@wrh_saved,0,0,0,0,0,0,@rtlprc,@inprc ,@subwrh)
              end
             fetch next from pkg into @pgid
             end else begin
             delete from ckswi where wrh=@wrh_saved and gdgid =@pgid and subwrh =@subwrh
             insert into ckswi(wrh,subwrh,gdgid,qty,total,rtlprc,inprc)
		select @wrh_saved,@subwrh,@pgid,0,0,rtlprc,inprc 
                from goods where gid=@pgid
              if @uppcks =1 begin
                if not exists( select * from pcks(nolock) where wrh = @wrh_saved and gdgid = @pgid and subwrh = @subwrh)
              insert into pcks( SETTLENO, GDGID, WRH, ACNTQTY, QTY,  ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC,subwrh)
                  values(@settleno,@pgid,@wrh_saved,0,0,0,0,0,0,@rtlprc,@inprc ,@subwrh)             
               end
             fetch next from pkg into @pgid
             end
        end
        close pkg
        deallocate pkg

        -- should the @newamt recaculated as @newqty * @rtlprc
        -- if @prctype is 0 ?
        -- you cannot do this, or the final @total in INV
        -- will be unexactness after audited.

        select @total = TOTAL from PCKS where wrh = @wrh_saved and gdgid = @gdgid and subwrh = @subwrh
        if not(@total is null)
        begin
            if (@total > @newamt)
            begin
                select @losamt = 0
                select @ovfamt = @total - @newamt
            end else
            begin
                select @losamt = @newamt - @total
                select @ovfamt = 0
            end
            update PCKS
            set ACNTQTY = @newqty, ACNTTL = @newamt,
                OVFAMT = @ovfamt, LOSAMT = @losamt,
                INPRC = @inprc, RTLPRC = @rtlprc
            where wrh = @wrh_saved and gdgid = @gdgid and subwrh = @subwrh
        end
    end else
    begin
        select @prctype = g.prctype
        from GOODS g
        where g.gid = @gdgid
        if (@prctype is null)
        begin
            raiserror( 'SNAPINV: cannot find goods', 16, -1 )
            return
        end

-- 1999.7.8 调整库存记录时写库存调整记录表
	if @subwrh  = 0 
         select @oldqty = qty , @oldtotal = total
         from  ckinv where wrh = @wrh_saved and gdgid = @gdgid
        else 
         select @oldqty = qty ,@oldtotal = total 
         from ckswi  where wrh=@wrh_saved and gdgid = @gdgid and subwrh = @subwrh

        if exists (select 1 from warehouse where gid = @store)     --2002-03-20  任务单2002032040779        
            insert into ckchg (wrh,gdgid,operator,oldqty,oldtotal,newqty,newtotal ,subwrh)
         	  values(@store,@gdgid,@operator,@oldqty,@oldtotal,@newqty,@newamt,@subwrh)
        else
            insert into ckchg (wrh,gdgid,operator,oldqty,oldtotal,newqty,newtotal ,subwrh)
         	  values(@wrh,@gdgid,@operator,@oldqty,@oldtotal,@newqty,@newamt,@subwrh)


       if @subwrh = 0 
        update CKINV
        set qty = @newqty, total = @newamt, invcost = invprc * @newqty  /*2003-05-30*/
        where wrh = @wrh_saved and gdgid = @gdgid
	else
        update ckswi
        set qty = @newqty,total = @newamt
        where wrh = @wrh_saved and gdgid = @gdgid and subwrh =@subwrh 
        select @total = TOTAL from PCKS where wrh = @wrh_saved and gdgid = @gdgid and subwrh = @subwrh
        if not(@total is null)
        begin
            if (@total > @newamt)
            begin
                select @losamt = 0
                select @ovfamt = @total - @newamt
            end else
            begin
                select @losamt = @newamt - @total
                select @ovfamt = 0
            end
            update PCKS
            set ACNTQTY = @newqty, ACNTTL = @newamt,
                OVFAMT = @ovfamt, LOSAMT = @losamt
            where wrh = @wrh_saved and gdgid = @gdgid and subwrh = @subwrh
        end
    end

    return
end
GO
