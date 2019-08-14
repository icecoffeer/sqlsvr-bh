SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdj_To800]
(
  @p_num varchar(14),
  @msg varchar(255) output
)
With Encryption
As
Begin
  declare @cur_settleno int,
          @cur_date datetime,
          @d_line int,
          @d_gdgid int,
          @d_newrtlprc money,
          @d_newlwtprc money,
          @d_newtopprc money,
          @d_newmbrprc money,
          @d_newwhsprc money,
          @d_cls int,
          @m_eon int,
          @launch datetime,
          @ret int,
          @canoccur int,
          @fildate datetime,
          @msgeon1 varchar(255),
          @d_QpcStr varchar(15)

  select @cur_date = convert(datetime, convert(char,getdate(),102)),
   @m_eon=eon,@launch=launch,@fildate=fildate
    from rtlprcadj where num=@p_num
  select @cur_settleno = max(NO) from MONTHSETTLE
  declare c_rtlprcadj800 cursor for
    select LINE, GDGID,newrtlprc,newlwtprc,newtopprc,newmbrprc,newwhsprc,QpcStr
    from rtlprcadjdtl where NUM = @p_num for update
  open c_rtlprcadj800
  fetch next from c_rtlprcadj800 into
    @d_line, @d_gdgid, @d_newrtlprc, @d_newlwtprc, @d_newtopprc, @d_newmbrprc, @d_newwhsprc, @d_QpcStr
  while @@fetch_status = 0
    begin
      set @d_cls=0
      if @d_newrtlprc is not null set @d_cls = @d_cls + 1
      if @d_newlwtprc is not null set @d_cls = @d_cls + 2
      if @d_newtopprc is not null set @d_cls = @d_cls + 4
      if @d_newmbrprc is not null set @d_cls = @d_cls + 8
      if @d_newwhsprc is not null set @d_cls = @d_cls + 16
      if @m_eon = 1
      begin
        exec @canoccur = RtlPrcAdj_To800_ChkData_Eon1 @d_cls,@p_num, @d_line,
          @d_gdgid, @d_QpcStr, @launch, @fildate, @msgeon1 output
        if @canoccur <> 0
          update rtlprcadjdtl set note = '本行不生效,' + @msgeon1
            where num = @p_num and line = @d_line and gdgid = @d_gdgid
        else
        begin
          exec RtlPrcAdj_To800_Eon1
            @cur_date, @cur_settleno,@d_cls, @p_num, @d_line, @d_gdgid, @d_QpcStr,
            @d_newrtlprc,@d_newlwtprc,@d_newtopprc,@d_newmbrprc,@d_newwhsprc
        end
      end
      exec @ret = RtlPrcAdj_To800_Eon0 @cur_date, @cur_settleno,@d_cls,
        @p_num, @d_line, @d_gdgid, @d_QpcStr, @d_newrtlprc, @d_newlwtprc, @d_newtopprc,
        @d_newmbrprc, @msg output
      if @ret <>0 break
      fetch next from c_rtlprcadj800 into
        @d_line, @d_gdgid, @d_newrtlprc, @d_newlwtprc, @d_newtopprc,
        @d_newmbrprc, @d_newwhsprc, @d_QpcStr
    end
    close c_rtlprcadj800
    deallocate c_rtlprcadj800

  --本店生效检查错误不影响单据生效
  if @ret = 0
  begin
    update rtlprcadj set STAT = 800,FILDATE = getdate(),
      SETTLENO = @cur_settleno where NUM = @p_num
    --2007.12.18, add by Zhuhaohui, 生效消息提醒
    execute RtlPrcAdjValidate @p_num
    --结束消息提醒
  end
  return (@ret)
End
GO
