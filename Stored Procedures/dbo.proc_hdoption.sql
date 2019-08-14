SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--------------------------------------------------------------------------------------------------------------------    
CREATE proc [dbo].[proc_hdoption] @optioncaption varchar(50)        
as        
exec ('select * from hdoption(nolock) where optioncaption= '''+ @optioncaption+'''') 
GO
