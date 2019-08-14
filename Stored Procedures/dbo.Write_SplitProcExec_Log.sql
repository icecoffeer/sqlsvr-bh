SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[Write_SplitProcExec_Log]
(
  @PROCTASKNUM varchar(14), --加工任务单号
  @PSCPCODE varchar(14),    --配方代码
  @CLS varchar(20),         --类型
  @PROCEXECNUM varchar(14), --加工入库单号
  @OPER varchar(30),        --操作员
  @ACTION varchar(20),      --成功 失败
  @NOTE varchar(255)        --备注
)
as
begin
  insert into PROCEXECPOOLLOG (OPERTIME, PROCTASKNUM, PSCPCODE, CLS, PROCEXECNUM, OPER, ACTION, NOTE)
  values (getdate(), @PROCTASKNUM, @PSCPCODE, @CLS, @PROCEXECNUM, @OPER, @ACTION, @NOTE)
end
GO
