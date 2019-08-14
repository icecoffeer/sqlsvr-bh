SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3MbrPromSubj_CHECK]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vRet int,
    @Stat int,
    @uuid varchar(32),
    @vCode varchar(20),
    @vName varchar(50),
    @vNote varchar(255),
    @vSubjCode varchar(20),
    @Settleno int

  declare Dtl cursor for
    select CODE, NAME, NOTE
      from PS3MBRPROMSUBJDTL l
    WHERE l.Cls = @Cls And l.Num = @Num
    order by l.line asc

  select @Stat = STAT, @vSubjCode = CODE
    from PS3MBRPROMSUBJ(nolock)
  where Cls = @Cls And NUM = @Num
  select @Settleno = max(no) from MONTHSETTLE

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  update PS3MBRPROMSUBJ
    set STAT = @ToStat, SETTLENO = @Settleno, CHKDATE = GETDATE(), CHECKER = @Oper, 
        LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

  -- 是否需要后单压前单？若不写则同时只能在同一时间段(包括交叉的时间段)允许一个单据处于审核状态,这个每次在建立单据时都需要判断是否满足允许保存单据
  --IF @Stat = 0
  --begin
    --exec @VRET = PS3MbrPromSubj_OCR  @NUM, @CLS, @OPER, @MSG
    --IF @VRET <> 0 RETURN(@VRET)
  --end

  select @uuid = uuid from PS3MBRPROMSUBJ(nolock) where Cls = @Cls And Num = @Num

  insert into PS3CRMPROMSUBJECT(UUID, STORE, CODE, NAME, CLS, NSCORE, BEGINDATE, ENDDATE, NOTE, 
    OPER, OPERTIME, /*ISALLCARDTYPEIN,*/ TPCLS, DISCOUNT, MAXDISCOUNT, PREC)
  SELECT UUID, STORE, CODE, NAME, CLS, NSCORE, BEGINDATE, ENDDATE, NOTE,
    @Oper, getdate(), /*ISALLCARDTYPEIN,*/ TPCLS, DISCOUNT, MAXDISCOUNT, PREC
  from PS3MBRPROMSUBJ
  where Cls = @Cls And Num = @Num

  -- 加入游标
  open Dtl
  fetch next from Dtl into @vCode, @vName, @vNote
  while @@fetch_status = 0
  begin
    insert into PS3CRMPROMSUBJECTDTL(SUBJUUID, SUBJCODE, CARDTYPE, CARDTYPENAME)
    values (@uuid, @vSubjCode, @vCode, @vName)

    fetch next from Dtl into @vCode, @vName, @vNote
  end
  close Dtl
  deallocate Dtl

  exec PS3MbrPromSubj_ADD_LOG @Num, @Cls, @ToStat, '审核', @Oper

  return(0)
end
GO
