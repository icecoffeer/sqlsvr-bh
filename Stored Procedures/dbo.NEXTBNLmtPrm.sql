SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[NEXTBNLmtPrm] ( @piNum varchar(16), @poNum varchar(16) output) as
begin
	declare @num_str varchar(6),
                @num_int int
        
        select @num_str = substring(@piNum,11,6)
          
        select @num_int = convert(int,@num_str)
        select @num_int = @num_int+1
        if len(@num_int)=1
	   select @num_str = '00000'+convert(char(1),@num_int)        
        else if len(@num_int)=2
           select @num_str = '0000'+convert(char(2),@num_int)
        else if len(@num_int)=3
           select @num_str = '000'+convert(char(3),@num_int)
        else if len(@num_int)=4
           select @num_str = '00'+convert(char(4),@num_int)
        else if len(@num_int)=5
           select @num_str = '0'+convert(char(5),@num_int)
        else if len(@num_int)=6
           select @num_str = convert(char(6),@num_int)

        select @poNum = substring(@piNum,1,10)+@num_str
end
GO
