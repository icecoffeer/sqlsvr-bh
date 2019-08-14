SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[GOODSRCVUPD](
  @p_src int,
  @p_id int,
  @p_l_gid int
) --with encryption
as
begin
  declare
    @n_gid int,
    @n_ispkg int,
    @n_isbind int,  /*2001.8.3*/
    @n_egid int,
    @n_egid2 int,  /*2001.8.3*/
    @n_billto int,
    @l_billto int,
    @l_wrh int,
    @n_sort char(13),
    @n_psr int,
    @l_psr int,
    @sndflag varchar(255),
    @ConsistCrtTime int /*ShenMin*/

  select @ConsistCrtTime = OptionValue from hdoption where OptionCaption = 'ConsistCrtTime'

  select @n_gid = Gid, @n_ispkg = IsPkg, @n_isbind = IsBind/*2001.8.3*/, @n_billto = BillTo, @n_sort = Sort,
      @n_psr = IsNull(Psr, 1)
  from NGOODS
    where Src = @p_src and Id = @p_id
  select @sndflag = isnull(S.SndFlag, '')
    from STORE S, SYSTEM M
  where M.UserGid = S.Gid

  if substring(@sndflag, 31, 1) <> '1' and @n_billto <> 1 and @p_src <> 6000000
  begin
    select @l_billto = LGid
      from VDRXLATE
      where NGid = @n_billto
    if @l_billto is null
    begin
      raiserror('缺省供应商未被转入', 16, 1)
      return(1)
    end
  end else if @p_src=6000000 select @l_billto = 6000000
    else  select @l_billto = @n_billto

  --振华百货定制，从批发系统接收数据时不判断类别
  /*if substring(@sndflag, 3, 1) <> '1' and
      not exists(select 1 from SORT where Code = @n_sort)
  begin
      raiserror('本地没有该商品的类别信息：%s', 16, 1, @n_sort)
      return(1)
  end*/

  if substring(@sndflag, 39, 1) <> '1' and @n_psr <> 1
  begin
    select @l_psr = LGid
      from EMPXLATE
    where NGid = @n_psr
    if @l_psr is null
    begin
      raiserror('采购员未被转入', 16, 1)
      return(1)
    end
  end else
    select @l_psr = @n_psr

  if @n_ispkg = 1
  begin           --如果是大包装商品其对应基本商品必须已经被转入
    select @n_egid = P.EGid
      from NPKG P, NGOODS G
    where P.PGid = @n_gid and P.Src = @p_src and
      P.EGid *= G.Gid and G.Src = @p_src
    if @n_egid is null
    begin
      raiserror('大包装商品对应基本商品未被转入', 16, 1)
      return(1)
    end
    if not exists (select C.Gid from GDXLATE X, GOODS C
        where X.NGid = @n_egid and X.LGid *= C.Gid)
    begin
      raiserror('大包装商品对应基本商品未被转入', 16, 1)
      return(1)
    end
  end

  if @n_isbind = 1
  begin           --如果是捆绑后商品其对应基本商品必须已经被转入
    declare c_bind Cursor for
       select P.EGid from NGDBIND P, NGOODS G
        where P.BINDGid = @n_gid and P.Src = @p_src and
            P.EGid *= G.Gid and G.Src = @p_src
    open c_bind
    fetch next from c_bind into @n_egid2
    if @@fetch_status = 0
    begin
      if @n_egid2 is null
      begin
          raiserror('捆绑后商品对应基本商品未被转入', 16, 1)
          return(1)
      end
      if not exists (select C.Gid from GDXLATE X, GOODS C
                  where X.NGid = @n_egid2 and X.LGid *= C.Gid)
      begin
        raiserror('捆绑后商品对应基本商品未被转入', 16, 1)
        return(1)
      end
      fetch next from c_bind into @n_egid2
    end
    close c_bind
    deallocate c_bind
  end

  if @p_src <> 6000000--by jzhu 如果是批发中心商品只更新部分资料
    update GOODS set
      Code = N.Code,
      Name = (case when substring(@sndflag, 1, 1) <> '1' then N.Name else C.Name end),
      Spec = (case when substring(@sndflag, 2, 1) <> '1' then N.Spec else C.Spec end),
      Sort = (case when substring(@sndflag, 3, 1) <> '1' then N.Sort else C.Sort end),
      TaxRate = (case when substring(@sndflag, 6, 1) <> '1' then N.TaxRate else C.TaxRate end),
      PrcType = (case when substring(@sndflag, 8, 1) <> '1' then N.PrcType else C.PrcType end),
      Acnt = (case when substring(@sndflag, 15, 1) <> '1' then N.Acnt else C.Acnt end),
      PayToDtl = (case when substring(@sndflag, 16, 1) <> '1' then N.PayToDtl else C.PayToDtl end),
      MUnit = (case when substring(@sndflag, 18, 1) <> '1' then N.MUnit else C.MUnit end),
      IsPkg = N.IsPkg,
      IsBind = N.IsBind,  /*2001.8.3*/
      --Gft = N.Gft,
      Qpc = (case when substring(@sndflag, 20, 1) <> '1' then N.Qpc else C.Qpc end),
      TM = (case when substring(@sndflag, 21, 1) <> '1' then N.TM else C.TM end),
      Manufactor = (case when substring(@sndflag, 22, 1) <> '1' then N.Manufactor else C.Manufactor end),
      MCode = (case when substring(@sndflag, 23, 1) <> '1' then REPLACE(N.MCode, char(9), '') else REPLACE(C.MCode, char(9), '') end),
      Gpr = (case when substring(@sndflag, 24, 1) <> '1' then N.Gpr else C.Gpr end),
      LowInv = (case when substring(@sndflag, 25, 1) <> '1' then N.LowInv else C.LowInv end),
      HighInv = (case when substring(@sndflag, 26, 1) <> '1' then N.HighInv else C.HighInv end),
      ValidPeriod = (case when substring(@sndflag, 27, 1) <> '1' then N.ValidPeriod else C.ValidPeriod end),
      CreateDate = (case when @ConsistCrtTime = 0 then N.CreateDate else C.CreateDate end),
      Memo = (case when substring(@sndflag, 28, 1) <> '1' then N.Memo else C.Memo end),
      ChkVd = (case when substring(@sndflag, 29, 1) <> '1' then N.ChkVd else C.ChkVd end),
      BillTo = (case when substring(@sndflag, 31, 1) <> '1' then @l_billto else C.BillTo end),
      Origin = (case when substring(@sndflag, 32, 1) <> '1' then N.Origin else C.Origin end),
      Grade = (case when substring(@sndflag, 33, 1) <> '1' then N.Grade else C.Grade end),
      SaleTax = (case when substring(@sndflag, 35, 1) <> '1' then N.SaleTax else C.SaleTax end),
      Alc = (case when substring(@sndflag, 36, 1) <> '1' then N.Alc else C.Alc end),
      Src = @p_src,
      SndTime = null,
      LstUpdTime = getdate(),
      Code2 = (case when substring(@sndflag, 37, 1) <> '1' then N.Code2 else C.Code2 end),
      Brand = (case when substring(@sndflag, 38, 1) <> '1' then N.Brand else C.Brand end),
      Psr = (case when substring(@sndflag, 39, 1) <> '1' then @l_psr else C.Psr end),
      F1 = (case when substring(@sndflag, 41, 1) <> '1' then N.f1 else C.f1 end),  --2001.4.27
      IsLtd = (case when substring(@sndflag, 42, 1)<> '1' then N.IsLtd else C.IsLtd end),  --2001.7.12 wang xin
      --BQtyPrc = (case when substring(@sndflag, 43, 1) <> '1' then N.BQtyPrc else C.BQtyPrc end)  --2002.4.24 Zhang Yanbo ---2002.7.10
      ALCQTY = (case when substring(@sndflag, 44, 1) <> '1' then N.ALCQTY else C.ALCQTY end),           --2002.7.30 JianWeicheng
      KEEPTYPE = (case when substring(@sndflag, 45, 1) <> '1' then N.KEEPTYPE else C.KEEPTYPE end),           --2002.8.1
      AUTOORD = (case when substring(@sndflag, 46, 1) <> '1' then N.AUTOORD else C.AUTOORD end),         --2003.6.16 QYX
         --2002.10.25-11.04
      NENDTIME = (case when substring(@sndflag, 47, 1) <> '1' then N.NENDTIME else C.NENDTIME end),
      NCANPAY = (case when substring(@sndflag, 48, 1) <> '1' then N.NCANPAY else          C.NCANPAY end),
      SSSTART = (case when substring(@sndflag, 49, 1) <> '1' then N.SSSTART else          C.SSSTART end),
      SSEND = (case when substring(@sndflag, 50, 1) <> '1' then N.SSEND else              C.SSEND end),
      SEASON = (case when substring(@sndflag, 51, 1) <> '1' then N.SEASON else            C.SEASON end),
      HQCONTROL = (case when substring(@sndflag, 52, 1) <> '1' then N.HQCONTROL else C.HQCONTROL end),
      ORDCYCLE = (case when substring(@sndflag, 53, 1) <> '1' then N.ORDCYCLE else C.ORDCYCLE end),
      ALCCTR = (case when substring(@sndflag, 54, 1) <> '1' then N.ALCCTR else C.ALCCTR end), --Added by wang xin -- 2003.06.03
      ISDISP = (case when substring(@sndflag, 55, 1) <> '1' then N.ISDISP else C.ISDISP end), --Added by wang xin 2003.06.30
      MKTINPRC = (case when substring(@sndflag, 57, 1) <> '1' then N.MKTINPRC else C.MKTINPRC end),
      UPCTRL = (case when substring(@sndflag, 58, 1) <> '1' then N.UPCTRL else C.UPCTRL end),
      --2006.4.18, ShenMin, Q6540, 商品增加定货单位
      ORDERQTY = (case when substring(@sndflag, 59, 1) <> '1' then N.ORDERQTY else C.ORDERQTY end), --ShenMin
      SubmitType = (CASE WHEN substring(@sndflag, 60, 1) <> '1' then N.SubmitType else C.SubmitType end), --Zhourong
      ELIREASON = (case when substring(@sndflag, 61, 1) <> '1' then N.ELIREASON else C.ELIREASON end), --ShenMin
      NOAUTOORDREASON = (case when substring(@sndflag, 62, 1) <> '1' then N.NOAUTOORDREASON else C.NOAUTOORDREASON end), --ShenMin
      SALCQTY = (case when substring(@sndflag, 63, 1) <> '1' then N.SALCQTY else C.SALCQTY end), --ZZ
      SALCQSTART = (case when substring(@sndflag, 64, 1) <> '1' then N.SALCQSTART ELSE C.SALCQSTART end), --ZZ
      TJCODE = (case when substring(@sndflag, 69, 1) <> '1' then N.TJCODE else C.TJCODE end),--zz 090424
      TAXSORT = N.TAXSORT
    from GOODS C, NGOODS N
      where C.Gid = @p_l_gid and N.Src = @p_src
        and  N.Id = @p_id --and @p_src <> 6000000   by jzhu delete 20091212 批发商品不更新将导致GOODSH表中数据被清除
    --振华百货:批发系统的商品不重复接收 WDP 091211
  else
    update GOODS
      set
        Code = N.Code,
        Name = (case when substring(@sndflag, 1, 1) <> '1' then N.Name else C.Name end),
        Spec = (case when substring(@sndflag, 2, 1) <> '1' then N.Spec else C.Spec end),
        --Sort = (case when substring(@sndflag, 3, 1) <> '1' then N.Sort else C.Sort end), --delete by jhzu 20091213
        TaxRate = (case when substring(@sndflag, 6, 1) <> '1' then N.TaxRate else C.TaxRate end),
        PrcType = (case when substring(@sndflag, 8, 1) <> '1' then N.PrcType else C.PrcType end),
        Acnt = (case when substring(@sndflag, 15, 1) <> '1' then N.Acnt else C.Acnt end),
        PayToDtl = (case when substring(@sndflag, 16, 1) <> '1' then N.PayToDtl else C.PayToDtl end),
        MUnit = (case when substring(@sndflag, 18, 1) <> '1' then N.MUnit else C.MUnit end),
        IsPkg = N.IsPkg,
        IsBind = N.IsBind,  /*2001.8.3*/
        --Gft = N.Gft,
        Qpc = (case when substring(@sndflag, 20, 1) <> '1' then N.Qpc else C.Qpc end),
        TM = (case when substring(@sndflag, 21, 1) <> '1' then N.TM else C.TM end),
        Manufactor = (case when substring(@sndflag, 22, 1) <> '1' then N.Manufactor else C.Manufactor end),
        MCode = (case when substring(@sndflag, 23, 1) <> '1' then REPLACE(N.MCode, char(9), '') else REPLACE(C.MCode, char(9), '') end),
        Gpr = (case when substring(@sndflag, 24, 1) <> '1' then N.Gpr else C.Gpr end),
        LowInv = (case when substring(@sndflag, 25, 1) <> '1' then N.LowInv else C.LowInv end),
        HighInv = (case when substring(@sndflag, 26, 1) <> '1' then N.HighInv else C.HighInv end),
        ValidPeriod = (case when substring(@sndflag, 27, 1) <> '1' then N.ValidPeriod else C.ValidPeriod end),
        CreateDate = (case when @ConsistCrtTime = 0 then N.CreateDate else C.CreateDate end),
        Memo = (case when substring(@sndflag, 28, 1) <> '1' then N.Memo else C.Memo end),
        ChkVd = (case when substring(@sndflag, 29, 1) <> '1' then N.ChkVd else C.ChkVd end),
        BillTo = (case when substring(@sndflag, 31, 1) <> '1' then @l_billto else C.BillTo end),
        Origin = (case when substring(@sndflag, 32, 1) <> '1' then N.Origin else C.Origin end),
        Grade = (case when substring(@sndflag, 33, 1) <> '1' then N.Grade else C.Grade end),
        SaleTax = (case when substring(@sndflag, 35, 1) <> '1' then N.SaleTax else C.SaleTax end),
        Alc = (case when substring(@sndflag, 36, 1) <> '1' then N.Alc else C.Alc end),
        Src = @p_src,
        SndTime = null,
        LstUpdTime = getdate(),
        Code2 = (case when substring(@sndflag, 37, 1) <> '1' then N.Code2 else C.Code2 end),
        Brand = (case when substring(@sndflag, 38, 1) <> '1' then N.Brand else C.Brand end),
        --Psr = (case when substring(@sndflag, 39, 1) <> '1' then @l_psr else C.Psr end),   --delete by jhzu 20091213
        --F1 = (case when substring(@sndflag, 41, 1) <> '1' then N.f1 else C.f1 end),  --2001.4.27   delete by jhzu 20091213
        IsLtd = (case when substring(@sndflag, 42, 1)<> '1' then N.IsLtd else C.IsLtd end),  --2001.7.12 wang xin
        --BQtyPrc = (case when substring(@sndflag, 43, 1) <> '1' then N.BQtyPrc else C.BQtyPrc end)  --2002.4.24 Zhang Yanbo ---2002.7.10
        ALCQTY = (case when substring(@sndflag, 44, 1) <> '1' then N.ALCQTY else C.ALCQTY end),           --2002.7.30 JianWeicheng
        KEEPTYPE = (case when substring(@sndflag, 45, 1) <> '1' then N.KEEPTYPE else C.KEEPTYPE end),           --2002.8.1
        AUTOORD = (case when substring(@sndflag, 46, 1) <> '1' then N.AUTOORD else C.AUTOORD end),         --2003.6.16 QYX
        NENDTIME = (case when substring(@sndflag, 47, 1) <> '1' then N.NENDTIME else C.NENDTIME end),
        NCANPAY = (case when substring(@sndflag, 48, 1) <> '1' then N.NCANPAY else          C.NCANPAY end),
        SSSTART = (case when substring(@sndflag, 49, 1) <> '1' then N.SSSTART else          C.SSSTART end),
        SSEND = (case when substring(@sndflag, 50, 1) <> '1' then N.SSEND else              C.SSEND end),
        SEASON = (case when substring(@sndflag, 51, 1) <> '1' then N.SEASON else            C.SEASON end),
        HQCONTROL = (case when substring(@sndflag, 52, 1) <> '1' then N.HQCONTROL else C.HQCONTROL end),
        ORDCYCLE = (case when substring(@sndflag, 53, 1) <> '1' then N.ORDCYCLE else C.ORDCYCLE end),
        ALCCTR = (case when substring(@sndflag, 54, 1) <> '1' then N.ALCCTR else C.ALCCTR end), --Added by wang xin -- 2003.06.03
        ISDISP = (case when substring(@sndflag, 55, 1) <> '1' then N.ISDISP else C.ISDISP end), --Added by wang xin 2003.06.30
        MKTINPRC = (case when substring(@sndflag, 57, 1) <> '1' then N.MKTINPRC else C.MKTINPRC end),
        UPCTRL = (case when substring(@sndflag, 58, 1) <> '1' then N.UPCTRL else C.UPCTRL end),
        --2006.4.18, ShenMin, Q6540, 商品增加定货单位
        ORDERQTY = (case when substring(@sndflag, 59, 1) <> '1' then N.ORDERQTY else C.ORDERQTY end), --ShenMin
        SubmitType = (CASE WHEN substring(@sndflag, 60, 1) <> '1' then N.SubmitType else C.SubmitType end), --Zhourong
        ELIREASON = (case when substring(@sndflag, 61, 1) <> '1' then N.ELIREASON else C.ELIREASON end), --ShenMin
        NOAUTOORDREASON = (case when substring(@sndflag, 62, 1) <> '1' then N.NOAUTOORDREASON else C.NOAUTOORDREASON end), --ShenMin
        SALCQTY = (case when substring(@sndflag, 63, 1) <> '1' then N.SALCQTY else C.SALCQTY end), --ZZ
        SALCQSTART = (case when substring(@sndflag, 64, 1) <> '1' then N.SALCQSTART ELSE C.SALCQSTART end), --ZZ
        TAXSORT = N.TAXSORT
        ---TJCODE = (case when substring(@sndflag, 69, 1) <> '1' then N.TJCODE else C.TJCODE end)--zz 090424 --delete by jzhu 20091213
    from GOODS C, NGOODS N
      where C.Gid = @p_l_gid and N.Src = @p_src
       and  N.Id = @p_id --and @p_src <> 6000000   by jzhu delete 20091212 批发商品不更新将导致GOODSH表中数据被清除
    --振华百货:批发系统的商品不重复接收 WDP 091211

  --更新Goods.TaxSortCode字段
  Update Goods SET TaxSortCode = t.CODE
    From TAXSORT t
  Where Goods.Gid = @p_l_gid And Goods.TaxSort Is Not Null
    And (Goods.Taxsort = t.GID) And Goods.TaxSortCode Is Null

  if (select RstWrh from SYSTEM) = 1
  begin
    select @l_billto = BillTo, @l_wrh = Wrh from GOODS where Gid = @p_l_gid
    if not exists(select 1 from VDRGD
      where VdrGid = @l_billto and Wrh = @l_wrh and GdGid = @p_l_gid)
      insert into VDRGD (VdrGid, GdGid, Wrh)
        values (@l_billto, @p_l_gid, @l_wrh)
  end

  return(0)
end
GO
