CREATE TABLE [dbo].[goodsjxc]
(
[date] [datetime] NOT NULL,
[gdgid] [int] NOT NULL,
[vdrgid] [int] NOT NULL CONSTRAINT [DF__goodsjxc__vdrgid__24F3FB69] DEFAULT (1),
[cinvqty] [money] NOT NULL CONSTRAINT [DF__goodsjxc__cinvqt__25E81FA2] DEFAULT (0),
[cinvtotal] [money] NOT NULL CONSTRAINT [DF__goodsjxc__cinvto__26DC43DB] DEFAULT (0),
[inqty] [money] NOT NULL CONSTRAINT [DF__goodsjxc__inqty__27D06814] DEFAULT (0),
[intotal] [money] NOT NULL CONSTRAINT [DF__goodsjxc__intota__28C48C4D] DEFAULT (0),
[inchajia] [money] NOT NULL CONSTRAINT [DF__goodsjxc__inchaj__29B8B086] DEFAULT (0),
[outqty] [money] NOT NULL CONSTRAINT [DF__goodsjxc__outqty__2AACD4BF] DEFAULT (0),
[outtotal] [money] NOT NULL CONSTRAINT [DF__goodsjxc__outtot__2BA0F8F8] DEFAULT (0),
[favamt] [money] NOT NULL CONSTRAINT [DF__goodsjxc__favamt__2C951D31] DEFAULT (0),
[rtlprcadj] [money] NOT NULL CONSTRAINT [DF__goodsjxc__rtlprc__2D89416A] DEFAULT (0),
[ykqty] [money] NOT NULL CONSTRAINT [DF__goodsjxc__ykqty__2E7D65A3] DEFAULT (0),
[yktotal] [money] NOT NULL CONSTRAINT [DF__goodsjxc__yktota__2F7189DC] DEFAULT (0),
[syqty] [money] NOT NULL CONSTRAINT [DF__goodsjxc__syqty__3065AE15] DEFAULT (0),
[sytotal] [money] NOT NULL CONSTRAINT [DF__goodsjxc__sytota__3159D24E] DEFAULT (0),
[finvqty] [money] NOT NULL CONSTRAINT [DF__goodsjxc__finvqt__324DF687] DEFAULT (0),
[finvtotal] [money] NOT NULL CONSTRAINT [DF__goodsjxc__finvto__33421AC0] DEFAULT (0),
[addrtlprcchajia] [money] NOT NULL CONSTRAINT [DF__goodsjxc__addrtl__34363EF9] DEFAULT (0),
[decrtlprcchajia] [money] NOT NULL CONSTRAINT [DF__goodsjxc__decrtl__352A6332] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[goodsjxc] ADD CONSTRAINT [PK__goodsjxc__6DF800E3] PRIMARY KEY CLUSTERED  ([date], [gdgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
