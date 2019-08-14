SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RCVPS3STAMPSCO]
(
  @SRC      INT, 
  @CLS      VARCHAR(30), 
  @MSG      VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE  	
    @STORE int, 
    @vZBGID int      
    
    select @vZBGid = ZBGid from FASystem(nolock) where ZBGid <> UserGid   
	  if @@ROWCOUNT = 0
	  begin
	    set @MSG = '总部不能接收印花积分规则'
	    return(1)
	  end 
   
    SELECT @STORE = USERGID FROM FASYSTEM(NOLOCK)   
    
    if @cls = 'PS3STAMPSCORULE'    
    begin    		    
	    -- 先删除不是本单位的网络数据
	    delete from NPS3STAMPSCORULE where rcv <> @STORE
	    
	    --先删除当前值
	    delete from PS3STAMPSCORULE
	    
	    --插入当前值
	    insert into PS3STAMPSCORULE(UUID, TOTAL, SCORE, SCOTOP, BEGINDATE, ENDDATE, NOTE, OPER, OPERTIME)
		    select UUID, TOTAL, SCORE, SCOTOP, BEGINDATE, ENDDATE, NOTE, OPER, OPERTIME
		    from NPS3STAMPSCORULE(nolock)
	    
	    --删除网络数据
	    delete from NPS3STAMPSCORULE    
  	end   
  	
  	if @cls = 'PS3NOTSTAMPSCOGOODS'
  	begin
  		delete from NPS3NOTSTAMPSCOGOODS where rcv <> @store
  		delete from PS3NOTSTAMPSCOGOODS
  		insert into PS3NOTSTAMPSCOGOODS(GOODS, NOTE, OPER, OPERTIME)
  			select GOODS, NOTE, OPER, OPERTIME from NPS3NOTSTAMPSCOGOODS(nolock)		 	
  		delete from NPS3NOTSTAMPSCOGOODS
  	end	
		      
    return 0
END

GO
