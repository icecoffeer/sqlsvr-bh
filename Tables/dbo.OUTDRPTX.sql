CREATE TABLE [dbo].[OUTDRPTX]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BCSTGID] [int] NOT NULL,
[DTN1] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN1__1181FF99] DEFAULT (0),
[DTN2] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN2__127623D2] DEFAULT (0),
[DTN3] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN3__136A480B] DEFAULT (0),
[DTN4] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN4__145E6C44] DEFAULT (0),
[DTN5] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN5__1552907D] DEFAULT (0),
[DTN6] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN6__1646B4B6] DEFAULT (0),
[DTN7] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN7__173AD8EF] DEFAULT (0),
[DTN8] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN8__182EFD28] DEFAULT (0),
[DTN9] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTN9__19232161] DEFAULT (0),
[DTX1] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX1__1A17459A] DEFAULT (0),
[DTX2] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX2__1B0B69D3] DEFAULT (0),
[DTX3] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX3__1BFF8E0C] DEFAULT (0),
[DTX4] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX4__1CF3B245] DEFAULT (0),
[DTX5] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX5__1DE7D67E] DEFAULT (0),
[DTX6] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX6__1EDBFAB7] DEFAULT (0),
[DTX7] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX7__1FD01EF0] DEFAULT (0),
[DTX8] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX8__20C44329] DEFAULT (0),
[DTX9] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DTX9__21B86762] DEFAULT (0),
[DIN1] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN1__22AC8B9B] DEFAULT (0),
[DIN2] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN2__23A0AFD4] DEFAULT (0),
[DIN3] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN3__2494D40D] DEFAULT (0),
[DIN4] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN4__2588F846] DEFAULT (0),
[DIN5] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN5__267D1C7F] DEFAULT (0),
[DIN6] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN6__277140B8] DEFAULT (0),
[DIN7] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN7__286564F1] DEFAULT (0),
[DIN8] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN8__2959892A] DEFAULT (0),
[DIN9] [money] NOT NULL CONSTRAINT [DF__OUTDRPTX__DIN9__2A4DAD63] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OUTDRPTX] ADD CONSTRAINT [PK__OUTDRPTX__5DEAEAF5] PRIMARY KEY CLUSTERED  ([ADATE], [BGDGID], [BCSTGID], [BWRH], [ASETTLENO], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
