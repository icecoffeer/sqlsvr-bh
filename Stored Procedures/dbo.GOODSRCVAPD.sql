SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[GOODSRCVAPD](
  @p_src int,
  @p_id int
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
    @ConsistCrtTime int, /*ShenMin*/
    @oldwrh int

  --ShenMin
  select @ConsistCrtTime = OptionValue from hdoption where OptionCaption = 'ConsistCrtTime'

  select @n_gid = Gid, @n_ispkg = IsPkg, @n_isbind = IsBind/*2001.8.3*/, @n_billto = BillTo, @n_sort = Sort,
      @n_psr = IsNull(Psr, 1)
      from NGOODS
      where Src = @p_src and Id = @p_id
  select @sndflag = isnull(S.SndFlag, '')
      from STORE S, SYSTEM M
      where M.UserGid = S.Gid

  if substring(@sndflag, 31, 1) <> '1' and @n_billto <> 1
  begin
    select @l_billto = LGid
      from VDRXLATE
    where NGid = @n_billto
    if @l_billto is null
    begin
      raiserror('缺省供应商未被转入。', 16, 1)
      return(1)
    end
  end else
    select @l_billto = @n_billto

  --振华百货定制，从批发系统接收数据时不判断类别
  /*if substring(@sndflag, 3, 1) <> '1' and
      not exists(select 1 from SORT where Code = @n_sort)
  begin
      raiserror('本地没有该商品的类别信息。', 16, 1)
      return(1)
  end */

  if substring(@sndflag, 39, 1) <> '1' and @n_psr <> 1
  begin
    select @l_psr = LGid
      from EMPXLATE
    where NGid = @n_psr
    if @l_psr is null
    begin
      raiserror('采购员未被转入。', 16, 1)
      return(1)
    end
  end else
    select @l_psr = @n_psr

  if @n_ispkg = 1
  begin           --如果是大包装商品其对应基本商品必须已经被转入
    select @n_egid = P.EGid
      from NPKG P, NGOODS G
    where P.PGid = @n_gid and P.Src = @p_src
      and P.EGid *= G.Gid and G.Src = @p_src
    if @n_egid is null
    begin
      raiserror('大包装商品对应基本商品未被转入。', 16, 1)
      return(1)
    end
    if not exists (select C.Gid
      from GDXLATE X, GOODS C
      where X.NGid = @n_egid and X.LGid *= C.Gid)
    begin
      raiserror('大包装商品对应基本商品未被转入。', 16, 1)
      return(1)
    end
  end

  /*2001.8.3*/
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
          raiserror('捆绑后商品对应基本商品未被转入。', 16, 1)
          return(1)
      end
      if not exists (select C.Gid from GDXLATE X, GOODS C
                  where X.NGid = @n_egid2 and X.LGid *= C.Gid)
      begin
          raiserror('捆绑后商品对应基本商品未被转入。', 16, 1)
          return(1)
      end

      fetch next from c_bind into @n_egid2
    end
    close c_bind
    deallocate c_bind
  end

  if exists (select * from GOODSH where Gid = @n_gid)
  begin
    select @oldwrh = wrh from GOODSH where GID = @n_Gid
    delete from GOODSH where Gid = @n_gid
  end
  else
    select @oldwrh = null

  if (@p_src = 6000000)
  begin
    insert into GOODS(
      Gid, Code, Name, Spec, Sort,
      RtlPrc, InPrc, TaxRate, Promote, PrcType,
      Sale, LstInPrc, InvPrc, OldInvPrc, LwtRtlPrc,
      WhsPrc, Wrh, Acnt, PayToDtl, PayRate,
      MUnit, IsPkg, IsBind/*2001.8.3*/, Gft, Qpc, TM,
      Manufactor, MCode, Gpr, LowInv, HighInv,
      ValidPeriod, CreateDate, Memo, ChkVd,
      DxPrc, BillTo, Origin, Grade, MbrPrc,
      SaleTax, Alc, Src, SndTime, LstUpdTime,
      Code2, Brand, Psr, CNTINPRC, f1,IsLtd, BQtyPrc, ALCQTY, KEEPTYPE,
      AUTOORD, NENDTIME, NCANPAY, SSSTART, SSEND,SEASON, HQCONTROL,
      ORDCYCLE, ALCCTR, ISDISP,TopRtlPrc, MKTINPRC, UPCTRL, ORDERQTY, SubmitType,
      ELIREASON, NOAUTOORDREASON, SALCQTY, SALCQSTART, TJCODE, TAXSORT)   --2006.4.18, ShenMin, Q6540, 商品增加定货单位
    select
      Gid,
      Code,
      (case when substring(@sndflag, 1, 1) <> '1' then Name else '' end),
      (case when substring(@sndflag, 2, 1) <> '1' then Spec else null end),
      (case when substring(@sndflag, 3, 1) <> '1' then Sort else '-' end),
      (case when substring(@sndflag, 4, 1) <> '1' then RtlPrc else 0 end),
      (case when substring(@sndflag, 5, 1) <> '1' then InPrc else 0 end),
      (case when substring(@sndflag, 6, 1) <> '1' then TaxRate else 17 end),
      (case when substring(@sndflag, 7, 1) <> '1' then Promote else -1 end),
      (case when substring(@sndflag, 8, 1) <> '1' then PrcType else 0 end),
      (case when substring(@sndflag, 9, 1) <> '1' then 3 else 3 end),--**定制接收为联销,联销率80**20050325
      (case when substring(@sndflag, 10, 1) <> '1' then LstInPrc else 0 end),
      (case when substring(@sndflag, 11, 1) <> '1' then InvPrc else 0 end),
      (case when substring(@sndflag, 12, 1) <> '1' then OldInvPrc else 0 end),
      (case when substring(@sndflag, 13, 1) <> '1' then LwtRtlPrc else null end),
      (case when substring(@sndflag, 14, 1) <> '1' then WhsPrc else 0 end),
      isnull(@oldwrh, (select dftwrh from system)),
      (case when substring(@sndflag, 15, 1) <> '1' then Acnt else 1 end),
      (case when substring(@sndflag, 16, 1) <> '1' then PayToDtl else 0 end),
      (case when substring(@sndflag, 17, 1) <> '1' then PayRate else convert(numeric (5,2) ,whsprc/ rtlprc )*100  end),--**定制接收为联销率80**20050325
      (case when substring(@sndflag, 18, 1) <> '1' then MUnit else '' end),
      IsPkg,
      IsBind,  /*2001.8.3*/
      (case when substring(@sndflag, 19, 1) <> '1' then Gft else 0 end),
      (case when substring(@sndflag, 20, 1) <> '1' then Qpc else 1 end),
      (case when substring(@sndflag, 21, 1) <> '1' then TM else null end),
      (case when substring(@sndflag, 22, 1) <> '1' then Manufactor else null end),
      (case when substring(@sndflag, 23, 1) <> '1' then REPLACE(MCode, char(9), '') else null end),
      (case when substring(@sndflag, 24, 1) <> '1' then Gpr else null end),
      (case when substring(@sndflag, 25, 1) <> '1' then LowInv else null end),
      (case when substring(@sndflag, 26, 1) <> '1' then HighInv else null end),
      (case when substring(@sndflag, 27, 1) <> '1' then ValidPeriod else null end),
      (case when @ConsistCrtTime = 0 then CreateDate else GetDate() end),
      (case when substring(@sndflag, 28, 1) <> '1' then Memo else null end),
      (case when substring(@sndflag, 29, 1) <> '1' then ChkVd else 0 end),
      (case when substring(@sndflag, 30, 1) <> '1' then DxPrc else 0 end),
      (case when substring(@sndflag, 31, 1) <> '1' then 6000000 else 6000000 end),--**定制接收正华批发**20050325
      (case when substring(@sndflag, 32, 1) <> '1' then Origin else null end),
      (case when substring(@sndflag, 33, 1) <> '1' then Grade else null end),
      (case when substring(@sndflag, 34, 1) <> '1' then MbrPrc else null end),
      (case when substring(@sndflag, 35, 1) <> '1' then SaleTax else 17 end),
      (case when substring(@sndflag, 36, 1) <> '1' then Alc else null end),
      Src, null, getdate(),
      (case when substring(@sndflag, 37, 1) <> '1' then Code2 else null end),
      (case when substring(@sndflag, 38, 1) <> '1' then Brand else null end),
      (case when substring(@sndflag, 39, 1) <> '1' then @l_psr else 1 end),
      (case when substring(@sndflag, 40, 1) <> '1' then CNTINPRC else null end),    --2001.4.2
      --开始定制 gs 接收商品部门不能为空
      (case when substring(@sndflag, 41, 1) <> '1' then f1 else '-' end),    --2001.4.27
      (case when substring(@sndflag, 42, 1) <> '1' then IsLtd else 0 end),    --2003.6.13 qyx
      (case when substring(@sndflag, 43, 1) <> '1' then BQtyPrc else null end),           --2002.4.24
      (case when substring(@sndflag, 44, 1) <> '1' then ALCQTY else null end),
      (case when substring(@sndflag, 45, 1) <> '1' then KEEPTYPE else 0 end),  --2002.8.1
      (case when substring(@sndflag, 46, 1) <> '1' then AUTOORD else 0 end),
      (case when substring(@sndflag, 47, 1) <> '1' then NENDTIME else null end),
      (case when substring(@sndflag, 48, 1) <> '1' then NCANPAY else 0 end),
      (case when substring(@sndflag, 49, 1) <> '1' then SSSTART else null end),
      (case when substring(@sndflag, 50, 1) <> '1' then SSEND else null end),
      (case when substring(@sndflag, 51, 1) <> '1' then SEASON else null end),
      (case when substring(@sndflag, 52, 1) <> '1' then HQCONTROL else 0 end),
      (case when substring(@sndflag, 53, 1) <> '1' then ORDCYCLE else null end),
      (case when substring(@sndflag, 54, 1) <> '1' then ALCCTR else null end),
      (case when substring(@sndflag, 55, 1) <> '1' then ISDISP else 0 end),
      (case when substring(@sndflag, 56, 1) <> '1' then TopRtlPrc else null end),
      (case when substring(@sndflag, 57, 1) <> '1' then MKTINPRC else null end),
      (case when substring(@sndflag, 58, 1) <> '1' then UPCTRL else null end),
      (case when substring(@sndflag, 59, 1) <> '1' then ORDERQTY else null end),  --2006.4.18, ShenMin, Q6540, 商品增加定货单位
      (CASE WHEN substring(@sndflag, 60, 1) <> '1' then SubmitType else NULL end), --Zhourong
      (case when substring(@sndflag, 61, 1) <> '1' then ELIREASON else null end),  --ShenMin
      (case when substring(@sndflag, 62, 1) <> '1' then NOAUTOORDREASON else null end),  --ShenMin
      (case when substring(@sndflag, 63, 1) <> '1' then SALCQTY ELSE null end), --ZZ
      (case when substring(@sndflag, 64, 1) <> '1' then SALCQSTART else null end), --ZZ
      (case when substring(@sndflag, 69, 1) <> '1' then TJCODE else '-' end), --zz 090424
      TAXSORT
    from NGOODS
      where Src = @p_src and Id = @p_id and f1 like 'P%'
    ------
    insert into GOODS(
      Gid, Code, Name, Spec, Sort,
      RtlPrc, InPrc, TaxRate, Promote, PrcType,
      Sale, LstInPrc, InvPrc, OldInvPrc, LwtRtlPrc,
      WhsPrc, Wrh, Acnt, PayToDtl, PayRate,
      MUnit, IsPkg, IsBind/*2001.8.3*/, Gft, Qpc, TM,
      Manufactor, MCode, Gpr, LowInv, HighInv,
      ValidPeriod, CreateDate, Memo, ChkVd,
      DxPrc, BillTo, Origin, Grade, MbrPrc,
      SaleTax, Alc, Src, SndTime, LstUpdTime,
      Code2, Brand, Psr, CNTINPRC, f1,IsLtd, BQtyPrc, ALCQTY, KEEPTYPE,
      AUTOORD, NENDTIME, NCANPAY, SSSTART, SSEND,SEASON, HQCONTROL,
      ORDCYCLE, ALCCTR, ISDISP,TopRtlPrc, MKTINPRC, UPCTRL, ORDERQTY, SubmitType, ELIREASON,
      NOAUTOORDREASON, SALCQTY, SALCQSTART, TJCODE, TAXSORT)   --2006.4.18, ShenMin, Q6540, 商品增加定货单位
    select
      Gid,
      Code,
      (case when substring(@sndflag, 1, 1) <> '1' then Name else '' end),
      (case when substring(@sndflag, 2, 1) <> '1' then Spec else null end),
      (case when substring(@sndflag, 3, 1) <> '1' then Sort else '-' end),
      (case when substring(@sndflag, 4, 1) <> '1' then RtlPrc else 0 end),
      (case when substring(@sndflag, 5, 1) <> '1' then InPrc else 0 end),
      (case when substring(@sndflag, 6, 1) <> '1' then TaxRate else 17 end),
      (case when substring(@sndflag, 7, 1) <> '1' then Promote else -1 end),
      (case when substring(@sndflag, 8, 1) <> '1' then PrcType else 0 end),
      (case when substring(@sndflag, 9, 1) <> '1' then Sale else 1 end),
      (case when substring(@sndflag, 10, 1) <> '1' then LstInPrc else 0 end),
      (case when substring(@sndflag, 11, 1) <> '1' then InvPrc else 0 end),
      (case when substring(@sndflag, 12, 1) <> '1' then OldInvPrc else 0 end),
      (case when substring(@sndflag, 13, 1) <> '1' then LwtRtlPrc else null end),
      (case when substring(@sndflag, 14, 1) <> '1' then WhsPrc else 0 end),
      isnull(@oldwrh, (select dftwrh from system)),
      (case when substring(@sndflag, 15, 1) <> '1' then Acnt else 1 end),
      (case when substring(@sndflag, 16, 1) <> '1' then PayToDtl else 0 end),
      (case when substring(@sndflag, 17, 1) <> '1' then PayRate else 0 end),
      (case when substring(@sndflag, 18, 1) <> '1' then MUnit else '' end),
      IsPkg,
      IsBind,  /*2001.8.3*/
      (case when substring(@sndflag, 19, 1) <> '1' then Gft else 0 end),
      (case when substring(@sndflag, 20, 1) <> '1' then Qpc else 1 end),
      (case when substring(@sndflag, 21, 1) <> '1' then TM else null end),
      (case when substring(@sndflag, 22, 1) <> '1' then Manufactor else null end),
      (case when substring(@sndflag, 23, 1) <> '1' then REPLACE(MCode, char(9), '') else null end),
      (case when substring(@sndflag, 24, 1) <> '1' then Gpr else null end),
      (case when substring(@sndflag, 25, 1) <> '1' then LowInv else null end),
      (case when substring(@sndflag, 26, 1) <> '1' then HighInv else null end),
      (case when substring(@sndflag, 27, 1) <> '1' then ValidPeriod else null end),
      (case when @ConsistCrtTime = 0 then CreateDate else GetDate() end),
      (case when substring(@sndflag, 28, 1) <> '1' then Memo else null end),
      (case when substring(@sndflag, 29, 1) <> '1' then ChkVd else 0 end),
      (case when substring(@sndflag, 30, 1) <> '1' then DxPrc else 0 end),
      (case when substring(@sndflag, 31, 1) <> '1' then @l_billto else 1 end),
      (case when substring(@sndflag, 32, 1) <> '1' then Origin else null end),
      (case when substring(@sndflag, 33, 1) <> '1' then Grade else null end),
      (case when substring(@sndflag, 34, 1) <> '1' then MbrPrc else null end),
      (case when substring(@sndflag, 35, 1) <> '1' then SaleTax else 17 end),
      (case when substring(@sndflag, 36, 1) <> '1' then Alc else null end),
      Src, null, getdate(),
      (case when substring(@sndflag, 37, 1) <> '1' then Code2 else null end),
      (case when substring(@sndflag, 38, 1) <> '1' then Brand else null end),
      (case when substring(@sndflag, 39, 1) <> '1' then @l_psr else 1 end),
      (case when substring(@sndflag, 40, 1) <> '1' then CNTINPRC else null end),    --2001.4.2
      (case when substring(@sndflag, 41, 1) <> '1' then f1 else '-' end),    --2001.4.27
      (case when substring(@sndflag, 42, 1) <> '1' then IsLtd else 0 end),    --2003.6.13 qyx
      (case when substring(@sndflag, 43, 1) <> '1' then BQtyPrc else null end),           --2002.4.24
      (case when substring(@sndflag, 44, 1) <> '1' then ALCQTY else null end),
      (case when substring(@sndflag, 45, 1) <> '1' then KEEPTYPE else 0 end),  --2002.8.1
      (case when substring(@sndflag, 46, 1) <> '1' then AUTOORD else 0 end),
      (case when substring(@sndflag, 47, 1) <> '1' then NENDTIME else null end),
      (case when substring(@sndflag, 48, 1) <> '1' then NCANPAY else 0 end),
      (case when substring(@sndflag, 49, 1) <> '1' then SSSTART else null end),
      (case when substring(@sndflag, 50, 1) <> '1' then SSEND else null end),
      (case when substring(@sndflag, 51, 1) <> '1' then SEASON else null end),
      (case when substring(@sndflag, 52, 1) <> '1' then HQCONTROL else 0 end),
      (case when substring(@sndflag, 53, 1) <> '1' then ORDCYCLE else null end),
      (case when substring(@sndflag, 54, 1) <> '1' then ALCCTR else null end),
      (case when substring(@sndflag, 55, 1) <> '1' then ISDISP else 0 end),
      (case when substring(@sndflag, 56, 1) <> '1' then TopRtlPrc else null end),
      (case when substring(@sndflag, 57, 1) <> '1' then MKTINPRC else null end),
      (case when substring(@sndflag, 58, 1) <> '1' then UPCTRL else null end),
      (case when substring(@sndflag, 59, 1) <> '1' then ORDERQTY else null end),  --2006.4.18, ShenMin, Q6540, 商品增加定货单位
      (CASE WHEN substring(@sndflag, 60, 1) <> '1' then SubmitType else NULL end), --Zhourong
      (case when substring(@sndflag, 61, 1) <> '1' then ELIREASON else null end),  --ShenMin
      (case when substring(@sndflag, 62, 1) <> '1' then NOAUTOORDREASON else null end),  --ShenMin
      (case when substring(@sndflag, 63, 1) <> '1' then SALCQTY ELSE null end), --ZZ
      (case when substring(@sndflag, 64, 1) <> '1' then SALCQSTART else null end), --ZZ
      (case when substring(@sndflag, 69, 1) <> '1' then TJCODE else '-' end), --zz 090424
      TAXSORT
    from NGOODS
      where Src = @p_src and Id = @p_id and f1 not like 'P%'
  end
  else if @p_src <> 6000000
    insert into GOODS(
      Gid, Code, Name, Spec, Sort,
      RtlPrc, InPrc, TaxRate, Promote, PrcType,
      Sale, LstInPrc, InvPrc, OldInvPrc, LwtRtlPrc,
      WhsPrc, Wrh, Acnt, PayToDtl, PayRate,
      MUnit, IsPkg, IsBind/*2001.8.3*/, Gft, Qpc, TM,
      Manufactor, MCode, Gpr, LowInv, HighInv,
      ValidPeriod, CreateDate, Memo, ChkVd,
      DxPrc, BillTo, Origin, Grade, MbrPrc,
      SaleTax, Alc, Src, SndTime, LstUpdTime,
      Code2, Brand, Psr, CNTINPRC, f1,IsLtd, BQtyPrc, ALCQTY, KEEPTYPE,
      AUTOORD, NENDTIME, NCANPAY, SSSTART, SSEND,SEASON, HQCONTROL,
      ORDCYCLE, ALCCTR, ISDISP,TopRtlPrc, MKTINPRC, UPCTRL, ORDERQTY, SubmitType, ELIREASON, NOAUTOORDREASON, SALCQTY, SALCQSTART, TJCODE, TAXSORT)   --2006.4.18, ShenMin, Q6540, 商品增加定货单位
    select
      Gid,
      Code,
      (case when substring(@sndflag, 1, 1) <> '1' then Name else '' end),
      (case when substring(@sndflag, 2, 1) <> '1' then Spec else null end),
      (case when substring(@sndflag, 3, 1) <> '1' then Sort else '-' end),
      (case when substring(@sndflag, 4, 1) <> '1' then RtlPrc else 0 end),
      (case when substring(@sndflag, 5, 1) <> '1' then InPrc else 0 end),
      (case when substring(@sndflag, 6, 1) <> '1' then TaxRate else 17 end),
      (case when substring(@sndflag, 7, 1) <> '1' then Promote else -1 end),
      (case when substring(@sndflag, 8, 1) <> '1' then PrcType else 0 end),
      (case when substring(@sndflag, 9, 1) <> '1' then Sale else 1 end),
      (case when substring(@sndflag, 10, 1) <> '1' then LstInPrc else 0 end),
      (case when substring(@sndflag, 11, 1) <> '1' then InvPrc else 0 end),
      (case when substring(@sndflag, 12, 1) <> '1' then OldInvPrc else 0 end),
      (case when substring(@sndflag, 13, 1) <> '1' then LwtRtlPrc else null end),
      (case when substring(@sndflag, 14, 1) <> '1' then WhsPrc else 0 end),
      isnull(@oldwrh, (select dftwrh from system)),
      (case when substring(@sndflag, 15, 1) <> '1' then Acnt else 1 end),
      (case when substring(@sndflag, 16, 1) <> '1' then PayToDtl else 0 end),
      (case when substring(@sndflag, 17, 1) <> '1' then PayRate else null end),
      (case when substring(@sndflag, 18, 1) <> '1' then MUnit else '' end),
      IsPkg,
      IsBind,  /*2001.8.3*/
      (case when substring(@sndflag, 19, 1) <> '1' then Gft else 0 end),
      (case when substring(@sndflag, 20, 1) <> '1' then Qpc else 1 end),
      (case when substring(@sndflag, 21, 1) <> '1' then TM else null end),
      (case when substring(@sndflag, 22, 1) <> '1' then Manufactor else null end),
      (case when substring(@sndflag, 23, 1) <> '1' then REPLACE(MCode, char(9), '') else null end),
      (case when substring(@sndflag, 24, 1) <> '1' then Gpr else null end),
      (case when substring(@sndflag, 25, 1) <> '1' then LowInv else null end),
      (case when substring(@sndflag, 26, 1) <> '1' then HighInv else null end),
      (case when substring(@sndflag, 27, 1) <> '1' then ValidPeriod else null end),
      (case when @ConsistCrtTime = 0 then CreateDate else GetDate() end),
      (case when substring(@sndflag, 28, 1) <> '1' then Memo else null end),
      (case when substring(@sndflag, 29, 1) <> '1' then ChkVd else 0 end),
      (case when substring(@sndflag, 30, 1) <> '1' then DxPrc else 0 end),
      (case when substring(@sndflag, 31, 1) <> '1' then @l_billto else 1 end),
      (case when substring(@sndflag, 32, 1) <> '1' then Origin else null end),
      (case when substring(@sndflag, 33, 1) <> '1' then Grade else null end),
      (case when substring(@sndflag, 34, 1) <> '1' then MbrPrc else null end),
      (case when substring(@sndflag, 35, 1) <> '1' then SaleTax else 17 end),
      (case when substring(@sndflag, 36, 1) <> '1' then Alc else null end),
      Src, null, getdate(),
      (case when substring(@sndflag, 37, 1) <> '1' then Code2 else null end),
      (case when substring(@sndflag, 38, 1) <> '1' then Brand else null end),
      (case when substring(@sndflag, 39, 1) <> '1' then @l_psr else 1 end),
      (case when substring(@sndflag, 40, 1) <> '1' then CNTINPRC else null end),    --2001.4.2
      (case when substring(@sndflag, 41, 1) <> '1' then f1 else '-' end),    --2001.4.27
      (case when substring(@sndflag, 42, 1) <> '1' then IsLtd else 0 end),    --2003.6.13 qyx
      (case when substring(@sndflag, 43, 1) <> '1' then BQtyPrc else null end),           --2002.4.24
      (case when substring(@sndflag, 44, 1) <> '1' then ALCQTY else null end),
      (case when substring(@sndflag, 45, 1) <> '1' then KEEPTYPE else 0 end),  --2002.8.1
      (case when substring(@sndflag, 46, 1) <> '1' then AUTOORD else 0 end),
      (case when substring(@sndflag, 47, 1) <> '1' then NENDTIME else null end),
      (case when substring(@sndflag, 48, 1) <> '1' then NCANPAY else 0 end),
      (case when substring(@sndflag, 49, 1) <> '1' then SSSTART else null end),
      (case when substring(@sndflag, 50, 1) <> '1' then SSEND else null end),
      (case when substring(@sndflag, 51, 1) <> '1' then SEASON else null end),
      (case when substring(@sndflag, 52, 1) <> '1' then HQCONTROL else 0 end),
      (case when substring(@sndflag, 53, 1) <> '1' then ORDCYCLE else null end),
      (case when substring(@sndflag, 54, 1) <> '1' then ALCCTR else null end),
      (case when substring(@sndflag, 55, 1) <> '1' then ISDISP else 0 end),
      (case when substring(@sndflag, 56, 1) <> '1' then TopRtlPrc else null end),
      (case when substring(@sndflag, 57, 1) <> '1' then MKTINPRC else null end),
      (case when substring(@sndflag, 58, 1) <> '1' then UPCTRL else null end),
      (case when substring(@sndflag, 59, 1) <> '1' then ORDERQTY else null end),  --2006.4.18, ShenMin, Q6540, 商品增加定货单位
      (CASE WHEN substring(@sndflag, 60, 1) <> '1' then SubmitType else NULL end), --Zhourong
      (case when substring(@sndflag, 61, 1) <> '1' then ELIREASON else null end),  --ShenMin
      (case when substring(@sndflag, 62, 1) <> '1' then NOAUTOORDREASON else null end),  --ShenMin
      (case when substring(@sndflag, 63, 1) <> '1' then SALCQTY ELSE null end), --ZZ
      (case when substring(@sndflag, 64, 1) <> '1' then SALCQSTART else null end), --ZZ
      (case when substring(@sndflag, 69, 1) <> '1' then TJCODE else '-' end), --zz 090424
      TAXSORT
    from NGOODS
      where Src = @p_src and Id = @p_id

  --更新Goods.TaxSortCode字段
  Update Goods SET TaxSortCode = t.CODE
    From TAXSORT t
  Where Exists (Select Code From NGoods n Where Goods.Gid = n.gid and Src = @p_src and Id = @p_id)
    And Goods.TaxSort Is Not Null And (Goods.Taxsort = t.GID)
    And Goods.TaxSortCode Is Null

  if (select RstWrh from SYSTEM) = 1
  begin
    select @l_billto = BillTo, @l_wrh = Wrh from GOODS where Gid = @n_gid
    if not exists(select 1 from VDRGD
      where VdrGid = @l_billto and Wrh = @l_wrh and GdGid = @n_gid)
        insert into VDRGD (VdrGid, GdGid, Wrh)
          values(@l_billto, @n_gid, @l_wrh)
  end

  return(0)
end
GO
