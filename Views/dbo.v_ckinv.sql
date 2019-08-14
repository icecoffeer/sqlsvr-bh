SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_ckinv] as
	select gdgid, max(inprc) inprc, max(rtlprc) rtlprc
	from ckinv
	group by gdgid


GO
