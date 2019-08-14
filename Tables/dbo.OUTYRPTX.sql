CREATE TABLE [dbo].[OUTYRPTX]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BCSTGID] [int] NOT NULL,
[DTN1] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN1__48D23483] DEFAULT (0),
[DTN2] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN2__49C658BC] DEFAULT (0),
[DTN3] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN3__4ABA7CF5] DEFAULT (0),
[DTN4] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN4__4BAEA12E] DEFAULT (0),
[DTN5] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN5__4CA2C567] DEFAULT (0),
[DTN6] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN6__4D96E9A0] DEFAULT (0),
[DTN7] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN7__4E8B0DD9] DEFAULT (0),
[DTN8] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN8__4F7F3212] DEFAULT (0),
[DTN9] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTN9__5073564B] DEFAULT (0),
[DTX1] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX1__51677A84] DEFAULT (0),
[DTX2] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX2__525B9EBD] DEFAULT (0),
[DTX3] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX3__534FC2F6] DEFAULT (0),
[DTX4] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX4__5443E72F] DEFAULT (0),
[DTX5] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX5__55380B68] DEFAULT (0),
[DTX6] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX6__562C2FA1] DEFAULT (0),
[DTX7] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX7__572053DA] DEFAULT (0),
[DTX8] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX8__58147813] DEFAULT (0),
[DTX9] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DTX9__59089C4C] DEFAULT (0),
[DIN1] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN1__59FCC085] DEFAULT (0),
[DIN2] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN2__5AF0E4BE] DEFAULT (0),
[DIN3] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN3__5BE508F7] DEFAULT (0),
[DIN4] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN4__5CD92D30] DEFAULT (0),
[DIN5] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN5__5DCD5169] DEFAULT (0),
[DIN6] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN6__5EC175A2] DEFAULT (0),
[DIN7] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN7__5FB599DB] DEFAULT (0),
[DIN8] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN8__60A9BE14] DEFAULT (0),
[DIN9] [money] NOT NULL CONSTRAINT [DF__OUTYRPTX__DIN9__619DE24D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OUTYRPTX] ADD CONSTRAINT [PK__OUTYRPTX__61BB7BD9] PRIMARY KEY CLUSTERED  ([ASETTLENO], [BGDGID], [BCSTGID], [BWRH], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO