SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[GetPayDate]
    @VdrCode Varchar(10),
    @OcrDate datetime,
    @VdrGid Int OutPut,
    @VdrName Varchar(50) OutPut,
    @PayTerm smallint output,
    @PayDate datetime output
as
begin
  declare
  	@rstwrh int,
  	@vdrpayterm smallint,
  	@vdrpaycls smallint	
  select @rstwrh = RstWrh from system(NOLOCK) 
  if @rstwrh = 0
  	select @VdrGid=GID, @VdrName=NAME, @vdrpayterm=PAYTERM, @vdrpaycls = PAYCLS 
  		from VENDOR (NOLOCK) where CODE = @vdrCode
  else
  	select @VdrGid=GID, @VdrName=NAME, @vdrpayterm=PAYTERM, @vdrpaycls = PAYCLS 
  		from V_VENDOR (NOLOCK) where CODE = @vdrCode
  if @vdrgid is null
  	return(0)
  if (@vdrpayterm is null) or (@vdrpaycls is null)
  begin
  	set @payterm = -1
  	return(1)
  end
  else
  begin
  	set @payterm = 1
  	if @vdrpaycls = 0
  	    set @PayDate = DateAdd(day, @vdrpayterm - day(@OcrDate), DateAdd(month, 1, @OcrDate))
  	else
  	if @vdrpaycls = 1
  	begin
  	    if day(@OcrDate) <= 15 
  	    	set @PayDate = DateAdd(day, 15 - day(@OcrDate) + @vdrpayterm, @OcrDate)	
  	    else
  	        set @PayDate = DateAdd(day, @vdrpayterm - day(@OcrDate), DateAdd(month, 1, @OcrDate))
     	end
     	else
     	if @vdrpaycls = 2
     	    set @PayDate = DateAdd(day, @vdrpayterm, @OcrDate)
     	return(1)
  end  	   
end
GO
