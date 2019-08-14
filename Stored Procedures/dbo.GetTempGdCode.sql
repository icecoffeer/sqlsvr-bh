SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetTempGdCode](
                @gdcode         char(13)        output
)
as
begin
                select @gdcode = null
                if not exists(select 1 from goods(nolock) where code = '--')
                                select @gdcode = '--'
                else if not exists(select 1 from goods(nolock) where code = '---')
                                select @gdcode = '---'
                else if not exists(select 1 from goods(nolock) where code = '----')
                                select @gdcode = '----'
                else if not exists(select 1 from goods(nolock) where code = '-----')
                                select @gdcode = '-----'
                else if not exists(select 1 from goods(nolock) where code = '------')
                                select @gdcode = '------'
                else if not exists(select 1 from goods(nolock) where code = '-------')
                                select @gdcode = '-------'
                else if not exists(select 1 from goods(nolock) where code = '--------')
                                select @gdcode = '--------'
                else if not exists(select 1 from goods(nolock) where code = '---------')
                                select @gdcode = '---------'
                else if not exists(select 1 from goods(nolock) where code = '----------')
                                select @gdcode = '----------'
                else if not exists(select 1 from goods(nolock) where code = '-----------')
                                select @gdcode = '-----------'
                else if not exists(select 1 from goods(nolock) where code = '------------')
                                select @gdcode = '------------'
                else if not exists(select 1 from goods(nolock) where code = '-------------')
                                select @gdcode = '-------------'
                else
                                raiserror('找不到可用的临时商品代码', 16, 1)
end
GO
