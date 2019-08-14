SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SETDXNAME]
--本存储过程改变collateitem和module表中的代销名称，并调用存储过程SETDXNAMEMENU改变相应菜单项
as
begin
  declare @dxname varchar(10)
  exec optreadstr 0, 'SETDXNAME', '代销', @dxname output
  update collateitem set fieldlabel= @dxname + '价'  where collateno=305 and fieldname='dxprc'
  update module set name = @dxname + '价调整单(明细)' where no = 81
  update module set memo = '商品' + @dxname + '价调整单，以单据明细(商品)为单位进行维护' where no = 81
  update module set name = @dxname + '价调整单(汇总)' where no = 82
  update module set memo = '商品' + @dxname + '价调整单，以单据为单位进行维护' where no = 82
  update module set name = '网络' + @dxname + '价调整单(汇总)' where no = 128
  update module set name = '网络' + @dxname + '价调整单(明细)' where no = 129
  update module set name = @dxname + '结算单(明细)' where no = 470
  update module set name = @dxname + '结算单(汇总)' where no = 471

  exec SETDXNAMEMENU 81,@dxname 
  exec SETDXNAMEMENU 82,@dxname
  exec SETDXNAMEMENU 128,@dxname
  exec SETDXNAMEMENU 129,@dxname
  exec SETDXNAMEMENU 470,@dxname
  exec SETDXNAMEMENU 471,@dxname
end
GO
