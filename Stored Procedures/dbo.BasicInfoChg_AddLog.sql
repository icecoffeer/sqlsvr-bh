SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BasicInfoChg_AddLog](
  @piTable Varchar(40), /*基础资料表名*/
  @piKeyName Varchar(10), /*主键名*/
  @piKeyValue Varchar(20), /*主键值*/
  @piAction Varchar(40), /*本次操作: Upd, Ins, Del*/
  @piOper Varchar(60) /*操作员*/
)
As
Begin
  Declare
    @vAction Varchar(40),
    @vAct SmallInt,
    @vUUID Varchar(40)

  --操作
  Set @vAction = UPPER(@piAction)
  If @vAction = 'UPD'
    Set @vAct = 0
  Else If @vAction = 'DEL'
    Set @vAct = 1
  Else
    Set @vAct = 2
  --UUID取值
  Select @vUUID = RTrim(Replace(NewId(), '-', ''))

  insert into PS3_BASICINFOCHANGELOG(UUID, TABLENAME, IUD, KEYNAME, KEYVALUE, LSTUPDOR, LSTUPDTIME)
    Values(@vUUID, @piTable, @vAct, @piKeyName, @piKeyValue, @piOper, getdate())

  Return(0)
end
GO
