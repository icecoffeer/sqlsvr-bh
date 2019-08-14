SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3STAMPSCO_SEND]
(   
	@src      int,
  @rcv      int,
  @msg      varchar(255) output   
)
as
begin 	
	-- 印花积分规则
	delete from NPS3STAMPSCORULE where rcv = @rcv
	insert into NPS3STAMPSCORULE(SRC, CLS, UUID, TOTAL, SCORE, SCOTOP, BEGINDATE, ENDDATE, 
		NOTE, OPER, OPERTIME, RCV, RCVTIME, TYPE, NSTAT, NNOTE, SNDTIME)
	select @src, 'PS3STAMPSCORULE', UUID, TOTAL, SCORE, SCOTOP, BEGINDATE, ENDDATE,
		NOTE, OPER, OPERTIME, @rcv, NULL, 0, 0, '', getdate()
	from PS3STAMPSCORULE(nolock)
	
	-- 不能与印花积分规则商品规则
	delete from NPS3NOTSTAMPSCOGOODS where rcv = @rcv
	insert into NPS3NOTSTAMPSCOGOODS(SRC, CLS, GOODS, NOTE, OPER, OPERTIME, RCV, RCVTIME, TYPE, NSTAT, NNOTE, SNDTIME)
	select @src, 'PS3NOTSTAMPSCOGOODS', GOODS, NOTE, OPER, OPERTIME, @rcv, NULL, 0, 0, '', getdate()
	from PS3NOTSTAMPSCOGOODS(nolock) 
 
  return 0
end

GO
