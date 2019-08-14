SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[ClnStyle_Snd]
(
  @piCode varchar(10),
  @piRcvGid int,
  @piFrcUpd smallint,
  @poMsg varchar(100) output
)
As
Begin
  Declare
    @bExists smallint,
    @usergid int
  
  set @bExists = 0  
  select @bExists=1 from clnstyle where code = @piCode
  if @bExists = 0
  begin
    set @poMsg = '该客户类型资料尚未保存'
    return 1
  end
  select @usergid = USERGID from system
  insert into NCLNSTYLE (SRC,CODE,NAME,SNDTIME,RCV,RCVTIME,FRCUPD,TYPE, NSTAT,NNOTE,OUTPRC,CREATOR,CREATETIME,MODIFIER,LSTUPDTIME )
   SELECT @usergid, CODE, NAME, getdate(), @piRcvGid, NULL, @piFrcUpd, 0, 0, NULL , OUTPRC, CREATOR, CREATETIME, MODIFIER, GETDATE() 
   FROM CLNSTYLE WHERE CODE = @piCode
  return 0 
End
GO
