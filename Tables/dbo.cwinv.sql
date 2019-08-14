CREATE TABLE [dbo].[cwinv]
(
[date] [datetime] NOT NULL,
[gdgid] [int] NOT NULL,
[cnoutnin] [money] NOT NULL CONSTRAINT [DF__cwinv__cnoutnin__18591A5A] DEFAULT (0),
[cnoutnintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__cnoutnint__194D3E93] DEFAULT (0),
[cnoutyin] [money] NOT NULL CONSTRAINT [DF__cwinv__cnoutyin__1A4162CC] DEFAULT (0),
[cnoutyintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__cnoutyint__1B358705] DEFAULT (0),
[cyoutnin] [money] NOT NULL CONSTRAINT [DF__cwinv__cyoutnin__1C29AB3E] DEFAULT (0),
[cyoutnintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__cyoutnint__1D1DCF77] DEFAULT (0),
[cyoutyin] [money] NOT NULL CONSTRAINT [DF__cwinv__cyoutyin__1E11F3B0] DEFAULT (0),
[cyoutyintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__cyoutyint__1F0617E9] DEFAULT (0),
[inqty] [money] NOT NULL CONSTRAINT [DF__cwinv__inqty__1FFA3C22] DEFAULT (0),
[intotal] [money] NOT NULL CONSTRAINT [DF__cwinv__intotal__20EE605B] DEFAULT (0),
[inbckqty] [money] NOT NULL CONSTRAINT [DF__cwinv__inbckqty__21E28494] DEFAULT (0),
[inbcktotal] [money] NOT NULL CONSTRAINT [DF__cwinv__inbcktota__22D6A8CD] DEFAULT (0),
[outqty] [money] NOT NULL CONSTRAINT [DF__cwinv__outqty__23CACD06] DEFAULT (0),
[outtotal] [money] NOT NULL CONSTRAINT [DF__cwinv__outtotal__24BEF13F] DEFAULT (0),
[outbckqty] [money] NOT NULL CONSTRAINT [DF__cwinv__outbckqty__25B31578] DEFAULT (0),
[outbcktotal] [money] NOT NULL CONSTRAINT [DF__cwinv__outbcktot__26A739B1] DEFAULT (0),
[payqty] [money] NOT NULL CONSTRAINT [DF__cwinv__payqty__279B5DEA] DEFAULT (0),
[paytotal] [money] NOT NULL CONSTRAINT [DF__cwinv__paytotal__288F8223] DEFAULT (0),
[fnoutnin] [money] NOT NULL CONSTRAINT [DF__cwinv__fnoutnin__2983A65C] DEFAULT (0),
[fnoutnintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__fnoutnint__2A77CA95] DEFAULT (0),
[fnoutyin] [money] NOT NULL CONSTRAINT [DF__cwinv__fnoutyin__2B6BEECE] DEFAULT (0),
[fnoutyintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__fnoutyint__2C601307] DEFAULT (0),
[fyoutnin] [money] NOT NULL CONSTRAINT [DF__cwinv__fyoutnin__2D543740] DEFAULT (0),
[fyoutnintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__fyoutnint__2E485B79] DEFAULT (0),
[fyoutyin] [money] NOT NULL CONSTRAINT [DF__cwinv__fyoutyin__2F3C7FB2] DEFAULT (0),
[fyoutyintotal] [money] NOT NULL CONSTRAINT [DF__cwinv__fyoutyint__3030A3EB] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwinv] ADD CONSTRAINT [PK__cwinv__6B1B9438] PRIMARY KEY CLUSTERED  ([date], [gdgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
