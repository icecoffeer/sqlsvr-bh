SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdj_Rcv]
(
  @Src int,
  @ID int,
  @Oper Char(30),
  @MSG VARCHAR(255) OUTPUT
)
With Encryption
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
          @nd_oldrtlprc money,
          @nd_newrtlprc money,
          @nd_oldlwtprc money,
          @nd_newlwtprc money,
          @nd_oldtopprc money,
          @nd_newtopprc money,
          @nd_oldmbrprc money,
          @nd_newmbrprc money,
          @nd_oldwhsprc money,
          @nd_newwhsprc money,
          @nd_note varchar(100),
          @nd_qty int,
          @l_qty int,
          @n_frcchk smallint,
          @nd_QPC money,
          @nd_QPCSTR varchar(15)

  select @type =type from NRtlPrcAdj where src=@src and id=@id
  if @@rowcount <1
  begin
    set @Msg ='未找到指定售价调整单'
    update NRtlPrcAdj set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end;
  if @type<>1
  begin
    set @Msg ='不是可接收单据'
    update NRtlPrcAdj set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @cnt = sum(case when X.LGid is null then 1 else 0 end)
    from NRTLPRCADJDTL N, GDXLATE X
    where N.Src = @src and N.Id = @id and
    N.GdGid *= X.NGid
  if @cnt > 0
  begin
    set @Msg='本地未包含商品资料'
    update NRtlPrcAdj set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @n_num =num,@n_frcchk = FrcChk from NRtlPrcAdj where src=@src and id=@id
  if exists (select * from RtlPrcAdj where num =@n_num)
  begin
    set @Msg='该单据已被接收过,不允许重复接收';
    update NRtlPrcAdj set nstat=1,nnote=@Msg where src=@src and id=@id
    return 1
  end
  select @settleno = max(no) from monthsettle
  declare c_rtlprcadj_rcv cursor for
   select N.Line, X.LGid,N.OLDRTLPRC,N.NEWRTLPRC,N.OLDLWTPRC,N.NEWLWTPRC,
   N.OldTOPPrc, N.NewTOPPrc, N.OLDMBRPRC, N.NEWMBRPRC, N.OLDWHSPRC, N.NEWWHSPRC,
   N.QTY ,N.NOTE, N.QPC, N.QPCSTR from NRTLPRCADJDTL N, GDXLATE X
   where N.Src = @src and N.Id = @id and N.GdGid *= X.NGid
  open c_rtlprcadj_rcv
  fetch next from c_rtlprcadj_rcv into @nd_line, @nd_lgid,
    @nd_oldrtlprc,@nd_newrtlprc,@nd_oldlwtprc,@nd_newlwtprc,@nd_oldtopprc,@nd_newtopprc,
    @nd_oldmbrprc , @nd_newmbrprc, @nd_oldwhsprc, @nd_newwhsprc, @nd_Qty,@nd_note, @nd_QPC, @nd_QPCSTR

  --2005.10.14, Added by ShenMin, Q5047, 售价调整单记录日志
  if @@fetch_status = 0
    exec WritePrcAdjLog '网络售价', @n_num, '接收'

  while @@fetch_status = 0
  begin
    select @l_qty = sum(qty) from Inv where GdGid = @nd_lgid
    insert into RtlPrcAdjDtl
      (num,line,gdgid,oldrtlprc,newrtlprc,oldlwtprc,newlwtprc,oldtopprc,newtopprc,
      oldmbrprc,newmbrprc,oldwhsprc,newwhsprc,qty,note, QPC, QPCSTR)
      values (@n_num,@nd_line,@nd_lgid,@nd_oldrtlprc,@nd_newrtlprc,@nd_oldlwtprc,
      @nd_newlwtprc,@nd_oldtopprc,@nd_newtopprc,@nd_oldmbrprc, @nd_newmbrprc,
      @nd_oldwhsprc, @nd_newwhsprc, isnull(@l_qty, 0),@nd_note, @nd_QPC, @nd_QPCSTR)
   fetch next from c_rtlprcadj_rcv into @nd_line, @nd_lgid,
    @nd_oldrtlprc,@nd_newrtlprc,@nd_oldlwtprc,@nd_newlwtprc,@nd_oldtopprc,@nd_newtopprc,
    @nd_oldmbrprc , @nd_newmbrprc, @nd_oldwhsprc, @nd_newwhsprc, @nd_Qty,@nd_note, @nd_QPC, @nd_QPCSTR
  end
  close c_rtlprcadj_rcv
  deallocate c_rtlprcadj_rcv

  insert into RtlPrcAdj (num,settleno,fildate,filler,checker,chkdate,stat,note,
    reccnt,launch,eon,src,srcnum,sndtime,prntime,wrh,lstupdtime)
    select @n_num,@settleno,fildate,filler,checker,chkdate,0,note,reccnt,launch,
    1,src,num,sndtime,null,null,lstupdtime from NRtlPrcAdj where src=@src and id=@id

  if @n_frcchk=1
  begin
    select @checker=checker from RtlPrcAdj where num=@n_num
    execute @ret= RtlPrcAdj_To100 @n_num,@checker,@msg output
    if @ret <>0
    begin
      return @ret
    end
  end
  delete from NRtlPrcAdj where Src = @src and Id = @id
  delete from NRtlPrcAdjDtl where Src = @src and Id = @id
End
GO
