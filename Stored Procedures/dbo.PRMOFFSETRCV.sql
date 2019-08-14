SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PRMOFFSETRCV]
(
  @Src int,
  @ID int,
  @Oper Char(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
  declare @type int,
          @cnt int,
          @n_num char(14),
          @line int,
          @checker char(30),
          @ret int,
          @settleno int,
          @nd_line int,
          @nd_lgid int,

          @nd_note varchar(100),
          @nd_qty int,
          @l_qty int,
          @n_frcchk smallint,
          @nd_QPC money,
          @nd_QPCSTR varchar(15),
          @nd_OffSetPrc money,
          @nd_CntInprc money,
          @nd_Start datetime,
          @nd_Finish datetime,
          @total decimal(24, 4),
          @tax decimal(24, 4),
          @amount decimal(24, 4),
          @alc varchar(100),
          @diffPrc decimal(24, 4);

  select @type = TYPE from NPRMOFFSET where SRC = @src and ID = @id
  if @@rowcount <1
  begin
    set @Msg ='未找到指定网络促销补差单'
    update NPRMOFFSET set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end;
  if @type<>1
  begin
    set @Msg ='不是可接收单据'
    update NPRMOFFSET set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @cnt = sum(case when X.LGid is null then 1 else 0 end)
    from NPRMOFFSETDTL N, GDXLATE X
    where N.Id = @id and
    N.GdGid *= X.NGid
  if @cnt > 0
  begin
    set @Msg='本地未包含商品资料'
    update NPRMOFFSET set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @n_num =num,@n_frcchk = FrcChk from NPRMOFFSET where src=@src and id=@id
  if exists (select * from PRMOFFSET where num =@n_num)
  begin
    set @Msg='该单据已被接收过,不允许重复接收';
    update NPRMOFFSET set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @settleno = max(no) from monthsettle
  declare c_PRMOFFSET_rcv cursor for
   select N.Line, X.LGid, N.QPC, N.QPCSTR, N.OFFSETPRC, N.CNTINPRC, N.QTY, N.START, N.FINISH, N.NOTE, N.Tax, N.Total, N.Amount, N.DiffPrc, N.Alc from NPRMOFFSETDTL N, GDXLATE X
   where N.Id = @id and N.GdGid *= X.NGid
  open c_PRMOFFSET_rcv
  fetch next from c_PRMOFFSET_rcv into @nd_line, @nd_lgid, @nd_QPC, @nd_QPCSTR, @nd_OffSetPrc, @nd_CntInprc, @nd_Qty, @nd_Start, @nd_Finish, @nd_note, @tax, @total, @amount, @diffPrc, @alc

  while @@fetch_status = 0
  begin
    insert into PRMOFFSETDtl (NUM, LINE, SettleNo, GDGID, QPC, QPCSTR, OFFSETPRC, CNTINPRC, QTY, START, FINISH, NOTE, Tax, Total, Amount, DiffPrc, Alc)
    values (@n_num, @nd_line, @settleno, @nd_lgid, @nd_QPC, @nd_QPCSTR, @nd_OffSetPrc, @nd_CntInprc, @nd_Qty, @nd_Start, @nd_Finish, @nd_note, @tax, @total, @amount, @diffPrc, @alc);
    fetch next from c_PRMOFFSET_rcv into @nd_line, @nd_lgid, @nd_QPC, @nd_QPCSTR, @nd_OffSetPrc, @nd_CntInprc, @nd_Qty, @nd_Start, @nd_Finish, @nd_note, @tax, @total, @amount, @diffPrc, @alc
  end;
  close c_PRMOFFSET_rcv
  deallocate c_PRMOFFSET_rcv

  insert into PRMOFFSET (NUM, VDRGID, SETTLENO, FILDATE, FILLER, CHECKER, CHKDATE, RECCNT, STAT, NOTE, EON, LAUNCH, LSTUPDTIME, Total, Tax, Amount, BillTo, OffsetType, OffsetCalcType, GatheringMode)
    select @n_num, VDRGID, @settleno, fildate, filler, checker, chkdate, reccnt, 0, NOTE, 1, launch, lstupdtime, Total, Tax, Amount, BillTo, OffsetType, OffsetCalcType, GatheringMode from NPRMOFFSET where src=@src and id=@id

    -- 写入生效单位
    DELETE FROM PrmOffsetLacDtl WHERE Num = @n_num;
    DECLARE @storeGid int;
    SELECT @storeGid = UserGid FROM System;
    INSERT INTO PrmOffsetLacDtl(Num, StoreGid) VALUES (@n_num, @storeGid);

  if @n_frcchk=1
  begin
    select @checker= checker from PRMOFFSET where num = @n_num
    execute @ret= PRMOFFSETCHK @n_num, '', 100, @checker, @msg output
    if @ret <>0
    begin
      return @ret
    end
  end
  delete from NPRMOFFSET where Id = @id
  delete from NPRMOFFSETDtl where Id = @id
End
GO
