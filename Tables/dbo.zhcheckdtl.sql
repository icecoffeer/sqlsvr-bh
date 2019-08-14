CREATE TABLE [dbo].[zhcheckdtl]
(
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[line] [int] NOT NULL,
[settleno] [int] NOT NULL,
[gdgid] [int] NOT NULL,
[wrh] [int] NOT NULL,
[sale] [int] NOT NULL,
[inprc] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__inprc__60D3DB46] DEFAULT (0),
[rtlprc] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__rtlpr__61C7FF7F] DEFAULT (0),
[invqty] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__invqt__62BC23B8] DEFAULT (0),
[invtotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__invto__63B047F1] DEFAULT (0),
[payinvqty] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__payin__64A46C2A] DEFAULT (0),
[payinvtotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__payin__65989063] DEFAULT (0),
[nopayinvqty] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__nopay__668CB49C] DEFAULT (0),
[nopayinvtotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__nopay__6780D8D5] DEFAULT (0),
[vdrchajia] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__vdrch__6874FD0E] DEFAULT (0),
[storechajia] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__store__69692147] DEFAULT (0),
[invalidtotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__inval__6A5D4580] DEFAULT (0),
[dxallqty] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__dxall__6B5169B9] DEFAULT (0),
[dxalltotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__dxall__6C458DF2] DEFAULT (0),
[dxoutqty] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__dxout__6D39B22B] DEFAULT (0),
[dxouttotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__dxout__6E2DD664] DEFAULT (0),
[acnttotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__anctt__6F21FA9D] DEFAULT (0),
[note] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[DXOutInTotal] [money] NOT NULL CONSTRAINT [DF__zhcheckdt__DXOut__36738D26] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[zhcheckdtl] ADD CONSTRAINT [PK_zhcheckdtl] PRIMARY KEY NONCLUSTERED  ([num], [line]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
