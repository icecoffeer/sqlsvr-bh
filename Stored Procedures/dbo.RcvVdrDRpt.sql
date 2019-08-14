SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvVdrDRpt] as
begin
  declare
    @id int,       @astore int,     @asettleno int,     @adate datetime,
    @bvdrgid int,  @bgdgid int,     @bwrh int,          @dq1 money,
    @dq2 money,    @dq3 money,      @dq4 money,         @dq5 money,
    @dq6 money,    @dt1 money,      @dt2 money,         @dt3 money,
    @dt4 money,    @dt5 money,      @dt6 money,         @dt7 money,
    @me int,       @sale smallint,  @billto int,        @wrh int ,
    @oldastore int,@olddt2 money ,  @olddt3 money,      @olddq2 money,
    @olddq3 money, @MSD  int,       @di2 money,         @olddi2 money,
    @old_SALE int, @old_vdrgid int, @old_wrh int, @asettleno1 int,/*2003-10-17*/
    @optvalue int,/*2002-09-26*/
    @vdrGidToDRpt int,/*来源报表供应商。接收帐款日报时，若选项“账款报表接收供应商取法”为1，供应商取此值。2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/
    @VdrOption int /*供应商选项 2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/

  /*2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/
  select @VdrOption = OptionValue from hdoption where (moduleno= 0) and (OptionCaption = '账款报表接收供应商取法')

  /* 取本店店号 */
  select @me = USERGID from SYSTEM

  exec OPTREADINT 0, 'SVICTRL', -1, @optvalue output  /*2002-09-26*/

  /* 处理网络报表 */
  declare c_vdrdrpt cursor for
    select ID, ASTORE, ASETTLENO, ADATE, BVDRGID, BGDGID, BWRH,
    DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
    DT1, DT2, DT3, DT4, DT5, DT6, DT7, DI2
    from NVDRDRPT(NOLOCK) where type=1
  open c_vdrdrpt
  fetch next from c_vdrdrpt into
    @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
    @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
    @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7, @di2
  while @@fetch_status = 0
  begin
    /* 检查本地是否有商品 */
    select @bgdgid = (select LGID from GDXLATE(NOLOCK) where NGID = @bgdgid)
    if @bgdgid is null
    begin
      update NVDRDRPT set NSTAT = 1, NNOTE = '商品不存在'
      where NVDRDRPT.ID = @id
      fetch next from c_vdrdrpt into
         @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
         @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
         @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7, @di2
      continue
    end
    /* 检查本地是否有供应商 */
    set @vdrGidToDRpt = @bvdrgid  /*2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/

    select @bvdrgid = (select LGID from VDRXLATE(NOLOCK) where NGID = @bvdrgid)
    if @bvdrgid is null
    begin
      update NVDRDRPT set NSTAT = 1, NNOTE = '供应商不存在'
         where NVDRDRPT.ID = @id
      fetch next from c_vdrdrpt into
         @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
         @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
         @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7, @di2
      continue
    end
    /* 取商品信息 */
    select @sale = SALE, @billto = BILLTO, @wrh = WRH
    from GOODS where GID = @bgdgid

    --add  by zl 12.11
    select @MSD = isNull(MSD,0) from store where gid = @astore
    select @asettleno1/*2003-10-17*/ = @aSettleno + @MSD
    select @asettleno = max(no) from monthsettle(NOLOCK) where @adate between begindate and enddate
    --

    begin transaction
    /* 复制到或更新VDRDRPT */
    select @oldastore = null,
           @olddt2=0,
           @olddt3=0,
           @olddq2=0,
           @olddq3=0,
           @olddi2 = 0
   select @oldastore=astore, @olddt2=(-1)*dt2,@olddt3=(-1)*dt3,@olddq2=(-1)*dq2,@olddq3=(-1)*dq3,
           @olddi2 = (-1)*di2
           from vdrdrpt(NOLOCK)
          where ASTORE = @astore and ASETTLENO = @asettleno1/*2003-10-17*/ and ADATE = @adate
            and BVDRGID = @bvdrgid and bwrh=@bwrh and BGDGID = @bgdgid

    if @oldastore is not null
    begin
      delete from VDRDRPT
       where ASTORE = @astore and ASETTLENO = @asettleno1/*2003-10-17*/ and ADATE = @adate
         and BVDRGID = @bvdrgid and bwrh=@bwrh and BGDGID = @bgdgid


      /*扣本地帐款 20010401*/
--      if @bvdrgid = @me
--      begin
         select @old_vdrgid = null
         select @old_vdrgid = bvdrgid, @old_wrh = bwrh, @old_sale = sale
      from VDRDRPTLOG
          where astore = @astore
            and asettleno = @asettleno
            and ADATE = @adate
            and bgdgid = @bgdgid
            and mwrh = @bwrh
         if @old_vdrgid is not null
         begin
            if @old_sale <> 1 --select @olddq3 = 0 ,@olddt3 = 0, @olddq2 = 0, @olddt2 = 0  -- sz modified
            execute AppUpdVdrDrpt
                    @me, @asettleno, @adate, @old_vdrgid, @old_wrh, @bgdgid,
                    0, @olddq2, @olddq3, 0, 0, 0,
                    0, @olddt2, @olddt3, 0, 0, 0, 0,
                    @olddi2
            delete from vdrdrptlog
             where astore = @astore
               and asettleno = @asettleno
               and ADATE = @adate
               and bgdgid = @bgdgid
               and mwrh = @bwrh
         end else
         begin
            if @sale <> 1 --select @olddq3 = 0 ,@olddt3 = 0   -- sz modified
            /*2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/
            begin
              if @VdrOption = 0
                execute AppUpdVdrDrpt
                        @me, @asettleno, @adate, @billto, @wrh, @bgdgid,
                        0, @olddq2, @olddq3, 0, 0, 0,
                        0, @olddt2, @olddt3, 0, 0, 0, 0,
                        @olddi2
              else
                execute AppUpdVdrDrpt
                        @me, @asettleno, @adate, @vdrGidToDRpt, @wrh, @bgdgid,
                        0, @olddq2, @olddq3, 0, 0, 0,
                        0, @olddt2, @olddt3, 0, 0, 0, 0,
                        @olddi2
            end
         end
    end
    else begin  /*2002.9.17*/
       Delete from vdrdrptlog
       where astore = @astore
       and asettleno = @asettleno
       and ADATE = @adate
       and bgdgid = @bgdgid
       and mwrh = @bwrh
    end

    if @VdrOption = 0  /*2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/
       insert into VDRDRPT
       (ASTORE, ASETTLENO, ADATE, BVDRGID, BGDGID, BWRH,
       DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
       DT1, DT2, DT3, DT4, DT5, DT6,
       DT7, DI2, LSTUPDTIME)
       values
       (@astore, @asettleno1/*2003-10-17*/, @adate, @bvdrgid, @bgdgid, @bwrh,
       @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
       @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6,
       @dt7, @di2, getdate())
    else
    /*2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/
       insert into VDRDRPT
       (ASTORE, ASETTLENO, ADATE, BVDRGID, BGDGID, BWRH,
       DQ1, DQ2, DQ3, DQ4, DQ5, DQ6,
       DT1, DT2, DT3, DT4, DT5, DT6,
       DT7, DI2, LSTUPDTIME)
       values
       (@astore, @asettleno1/*2003-10-17*/, @adate, @vdrGidToDRpt, @bgdgid, @bwrh,
       @dq1, @dq2, @dq3, @dq4, @dq5, @dq6,
       @dt1, @dt2, @dt3, @dt4, @dt5, @dt6,
       @dt7, @di2, getdate())

    /* 对本店配出的代销/联销商品，修改本店的应结数/应结额/销售数/销售额 */
/*    if @bvdrgid = @me	20010401 */
--    begin
 --   if @sale <> 1 --select @dq3 = 0, @dt3 = 0, @dq2 = 0, @dt2 = 0  --sz modified

    if @sale <> 1
      execute AppUpdVdrDrpt
        @me, @asettleno, @adate, @billto, @wrh, @bgdgid,
        0, @dq2, @dq3, 0, 0, 0,
        0, @dt2, @dt3, 0, 0, 0, 0,
        @di2

    if ((@sale = 2) and (@optvalue <> -1)) or (@sale = 3)/*2002.11.15*/
    begin
      if not exists (select * from osbal (nolock)
          where store = @astore and settleno =@asettleno and date = @adate
            and wrh = @bwrh and gdgid = @bgdgid and vdrgid = @bvdrgid)
            insert into osbal (store,settleno,date,vdrgid,wrh,gdgid)
          values(@astore,@asettleno,@adate,@bvdrgid,@bwrh,@bgdgid)
        update osbal set qty = qty + @olddq2,
      dt1 = dt1 + @olddt2,
      dt2 = dt2 + @olddt3
        where  store = @astore and settleno = @asettleno and date = @adate
      and wrh = @bwrh and gdgid = @bgdgid and vdrgid = @bvdrgid
    update osbal
        set qty = qty + isnull(@dq2,0),
      dt1 = dt1 + isnull(@dt2,0),
      dt2 = dt2 + isnull(@dt3,0) --应结额
        where  store = @astore and settleno = @asettleno and date = @adate
      and wrh = @bwrh and gdgid = @bgdgid and vdrgid = @bvdrgid
  end
  if @sale <> 1  -- sz add
  begin
    if @VdrOption = 0  /*2005.8.24, ShenMin, Q4707, 供应商帐款日报接收问题*/
      insert into VDRDRPTLOG ( ASTORE, ASETTLENO, ADATE, BVDRGID, mwrh, BWRH, BGDGID, sale )
                      values ( @astore, @asettleno, @adate, @billto, @bwrh, @wrh, @BGDGID, @sale )
    else
      insert into VDRDRPTLOG ( ASTORE, ASETTLENO, ADATE, BVDRGID, mwrh, BWRH, BGDGID, sale )
                      values ( @astore, @asettleno, @adate, @vdrGidToDRpt, @bwrh, @wrh, @BGDGID, @sale )
  end;
    /* 删除NVDRDRPT */
    delete from NVDRDRPT where ID = @id
    commit transaction

    /* 下一条记录 */
    fetch next from c_vdrdrpt into
      @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
      @dq1,  @dq2, @dq3,  @dq4, @dq5, @dq6,
      @dt1,  @dt2, @dt3,  @dt4, @dt5, @dt6, @dt7, @di2
  end
  close c_vdrdrpt
  deallocate c_vdrdrpt
end
GO
