SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ORDCHK](
	@num char(10)
) --with encryption 
as
begin
	declare
	@return_status int,
	@stat int,
	@vendor int,
	@src int,
	@usergid int,
	@gdgid int,
	@wrh int,
	@qty money,
	@price money,
	@line smallint,           --2001.7.12
	@isltd smallint,          --2001.7.12
	@message varchar(50),     --2001.7.13
	@opt_value int,			--2002.06.12
	@GDLtd int,
	@GDStoreLtd int,
	@Keeptype int,
	@checkltd smallint, --2002.10.23
	@ChkZeroBerofeOrdChk smallint,
	@receiver int,
	@optVendorOrd int, --Q6795, 是否使用供应商定货周期
	@alc char(10),
	@SPECIALORDUSED INT,	--是否起用分类定单0-不启用；1-启用
	@BLMTQTY INT,	--是否起用数量限制0-不启用；1-启用
	@TRECCNT INT,  			--定单的商品种类数
	@SRECCNT INT,   			--定单的商品种类数
	@chkid int,  --审核级别
        @usechklvl varchar(255),   --审核级别选项
        @GDCODE varchar(20),
        @QTYLMT MONEY,
        @QTYLMTSTR VARCHAR(50),
        @QTYSTR VARCHAR(50)


  exec OPTREADINT 0, 'ChkZeroBerofeOrdChk', 0, @ChkZeroBerofeOrdChk output

   --2006.5.26, ShenMin, Q6795
	EXEC OPTREADINT 114, 'VendorOrd', 0, @optVendorOrd OUTPUT

	if not exists(select * from ORD where NUM = @num)
	begin
		--raiserror('单据已被其他用户删除', 16, 1)
		raiserror('不存在要审核的单据', 16, 1)
		return(1)
	end
	select @usergid = usergid from system
--2002.10.23 wang xin
	select @src = src, @receiver = receiver from ord where num = @num
	if (@src = @usergid) or (@Src = 1)
		select @checkltd = 1
	else
		select @checkltd = 0

--2007.8.16 huangliang
    SELECT @SPECIALORDUSED = OPTIONVALUE FROM [HDOPTION] where MODULENO = 0 AND OPTIONCAPTION = 'SPECIALORDUSED'
    IF @SPECIALORDUSED = 0
      EXEC OPTREADINT 114, 'GdQttLmt', 0, @SRECCNT OUTPUT
	ELSE 
    BEGIN
      IF (SELECT ALCCLS FROM ORD WHERE NUM = @NUM) IS NULL 
        EXEC OPTREADINT 524, 'GdQttLmt', 0, @SRECCNT OUTPUT
      ELSE
        SET @SRECCNT = 0
    END
          
	SELECT @TRECCNT = RECCNT FROM ORD WHERE NUM = @num
	if (@TRECCNT > @SRECCNT) AND (@SRECCNT > 0)
	begin
		raiserror('定单中商品的记录数超出了限制,限制数为 %d', 16, 1,@SRECCNT)
		return(1)
	end

--added end

  SET @BLMTQTY = 0
  SELECT @BLMTQTY = OPTIONVALUE FROM [HDOPTION] WHERE MODULENO = 114 AND OPTIONCAPTION = 'LMTQTYTOHIGHINV'
  IF @SPECIALORDUSED = 0 AND @BLMTQTY = 1 
  BEGIN
  	SET @LINE = -1
    SELECT @LINE = D.LINE, @QTY = D.QTY, @GDCODE = G.CODE, 
      @QTYLMT = ISNULL(ISNULL(S.HIGHINV, G.HIGHINV), 0) - ISNULL(SUM(V.QTY), 0) - ISNULL(SUM(V.ORDQTY), 0)
    FROM GOODS G(NOLOCK), GDSTORE S(NOLOCK), INV V(NOLOCK), ORDDTL D(NOLOCK)
    WHERE G.GID = D.GDGID AND S.STOREGID = @RECEIVER AND S.GDGID =* D.GDGID AND D.NUM = @NUM 
      AND V.GDGID =* D.GDGID AND V.STORE = @RECEIVER  
    GROUP BY D.LINE, D.QTY, S.HIGHINV, G.HIGHINV, G.CODE
    HAVING ISNULL(SUM(V.QTY), 0) + ISNULL(SUM(V.ORDQTY), 0) + D.QTY - ISNULL(ISNULL(S.HIGHINV, G.HIGHINV), 0) > 0
    ORDER BY D.LINE DESC
    IF @LINE <> -1 
    BEGIN    
      SET @QTYSTR = CONVERT(VARCHAR(50), @QTY)
      SET @QTYLMTSTR = CONVERT(VARCHAR(50), @QTYLMT)
    
      RAISERROR('定单中第%d行商品%s定货数%s超过了最高库存-库存数-在单量%s', 16, 1, @LINE, @GDCODE, @QTYSTR, @QTYLMTSTR)
      RETURN(1)
    END
  END
    
    
	select @stat = STAT, @vendor = VENDOR--, @src = RECEIVER	-- SRC 20010702 CQH
		from ORD where NUM = @num

	if @stat not in (0, 7)
	begin
		raiserror('审核的不是未审核的单据', 16, 1)
		return(1)
	end

--2006.5.26, ShenMin, Q6795
	if @optVendorOrd = 1
	  begin
	    if not exists(select 1 from V_OrdVendor where VdrGid = @vendor)
	      begin
	        raiserror('本日不是该供应商的定货周期，不能审核', 16, 1)
		return(1)
	      end
	  end

--ShenMin
	if (@ChkZeroBerofeOrdChk = 1) and exists(select 1 from orddtl where num = @num and qty = 0)
	begin
		raiserror('单据中存在数量为零的商品，不能审核', 16, 1)
		return(1)
	end
	
--gaoliping
        if (@src = @usergid) and exists(select 1 from hdoption where moduleno = 114 and optioncaption = 'UseOrdChkLvl' and optionvalue = '1') 
        begin
          Select @chkid = min ([id]) from ORDCHKLVL where AMT >= (select Total from ord where num=@num)
   
       if (select amt from ordchklvl where [id] = @chkid -1) >= (select Total from ord where num=@num)
               select @chkid = @chkid - 1
        
          if (select stat2 from ord where num=@num) < @chkid
          begin
                raiserror('分级审核未完成，不能审核该单据', 16, 1)
                return(1)
          end
        end

	declare I_ord cursor for
	select LINE,GDGID from ORDDTL where NUM = @num

	open I_ord
	fetch next from I_ord into
		@line, @gdgid
	while @@fetch_status = 0
	begin
--2002.10.23 wang xin
		IF @checkltd = 1
		begin
			select @GDLtd = isnull(Isltd,0),@KeepType = isnull(KeepType,0) from goods where gid = @gdgid

			if @receiver <> @usergid
			begin
				select @GDStoreltd = 0
				select @GDStoreltd = isnull(isltd,0) from gdstore where gdgid = @gdgid and storegid = @receiver

				if @@Rowcount = 1
				begin
					if @KeepType & 1 =1
					begin
						if @GDStoreLtd & 4 = 4
						begin
							SELECT @MESSAGE = '定货单[' + @NUM + ']的第' + LTRIM(STR(@LINE)) + '行商品为新品且在收货门店不允许销售'
							close I_Ord
							DealLocate I_Ord
							RAISERROR(@MESSAGE, 16, 1)
							RETURN(1)

						end
						else
						begin
							if @GDStoreLtd & 2 = 2  --GDLtd->GDStoreLtd 2005.07.29
							begin
								SELECT @MESSAGE = '定货单[' + @NUM + ']的第' + LTRIM(STR(@LINE)) + '行商品不允许定货'
								close I_Ord
								DealLocate I_Ord
								RAISERROR(@MESSAGE, 16, 1)
								RETURN(1)
							end
						end
					end
					else
					begin
						if @GDStoreLtd & 2 = 2 --GDLtd->GDStoreLtd
						begin
							SELECT @MESSAGE = '定货单[' + @NUM + ']的第' + LTRIM(STR(@LINE)) + '行商品不允许定货'
							close I_Ord
							DealLocate I_Ord
							RAISERROR(@MESSAGE, 16, 1)
							RETURN(1)
						end
					end

				end
				else--判断当前店表中的记录
				begin
					if @GDLtd & 2 = 2
					begin
						select @message = '定货单[' + @num + ']的第' + ltrim(str(@line)) + '行商品不允许定货'
						close I_Ord
						Deallocate I_Ord
						raiserror(@message, 16, 1)
						return(1)
					end
				end
			end
			else
			begin
				if @GDLtd & 2 = 2
				begin
					select @message = '定货单[' + @num + ']的第' + ltrim(str(@line)) + '行商品不允许定货'
					close I_Ord
					Deallocate I_Ord
					raiserror(@message, 16, 1)
					return(1)
				end
			end
		end
--added end
		fetch next from I_ord into
			@line, @gdgid
	end
	close I_ord
	deallocate I_ord



	update ORD set STAT = 1, FILDATE = getdate() where NUM = @num

	--2002.06.12
	exec OPTREADINT 0, 'OrdUpdLstInPrc', 1, @opt_value output

	declare c_ord cursor for
	select GDGID, WRH, QTY, PRICE
	from ORDDTL
	where NUM = @num

	open c_ord
	fetch next from c_ord into
		@gdgid, @wrh, @qty, @price
	while @@fetch_status = 0
	begin
		if not exists(select * from VDRGD where VDRGID = @vendor
				and GDGID = @gdgid and WRH = @wrh)
			insert into VDRGD(VDRGID, GDGID, WRH)
				values(@vendor, @gdgid, @wrh)

		/* 在单量 */
		if @receiver = @usergid
		begin
			if @opt_value = 1		--2002.06.12
			begin
				if exists (select INPRCTAX from SYSTEM where INPRCTAX = 1)
					update GOODS set LSTINPRC = @price where GID = @gdgid
				else
					update GOODS set LSTINPRC = @price/(1.0+TAXRATE/100.0) where GID = @gdgid
			end
			select @alc = alc from Goods(nolock) where gid = @gdgid
			--2006.11.29 added by zhanglong, 供应单位若为总部，则配货方式必须为‘统配’才可影响在单量
			if not exists(select 1 from store(nolock) where gid = @vendor)
				or (@alc = '统配')            
			execute IncOrdQty @wrh, @gdgid, @qty
		end

		fetch next from c_ord into
			@gdgid, @wrh, @qty, @price
	end
	close c_ord
	deallocate c_ord

	--2003.01.07
	exec OrdUpdAlcPool @num
end

GO
