CREATE TABLE [dbo].[INDRPTX]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BVDRGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[DTN1] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN1__4FB43C3C] DEFAULT (0),
[DTN2] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN2__50A86075] DEFAULT (0),
[DTN3] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN3__519C84AE] DEFAULT (0),
[DTN4] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN4__5290A8E7] DEFAULT (0),
[DTN5] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN5__5384CD20] DEFAULT (0),
[DTN6] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN6__5478F159] DEFAULT (0),
[DTN7] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTN7__556D1592] DEFAULT (0),
[DTX1] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX1__566139CB] DEFAULT (0),
[DTX2] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX2__57555E04] DEFAULT (0),
[DTX3] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX3__5849823D] DEFAULT (0),
[DTX4] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX4__593DA676] DEFAULT (0),
[DTX5] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX5__5A31CAAF] DEFAULT (0),
[DTX6] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX6__5B25EEE8] DEFAULT (0),
[DTX7] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DTX7__5C1A1321] DEFAULT (0),
[DIN1] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN1__5D0E375A] DEFAULT (0),
[DIN2] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN2__5E025B93] DEFAULT (0),
[DIN3] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN3__5EF67FCC] DEFAULT (0),
[DIN4] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN4__5FEAA405] DEFAULT (0),
[DIN5] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN5__60DEC83E] DEFAULT (0),
[DIN6] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN6__61D2EC77] DEFAULT (0),
[DIN7] [money] NOT NULL CONSTRAINT [DF__INDRPTX__DIN7__62C710B0] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INDRPTX] ADD CONSTRAINT [PK__INDRPTX__703EA55A] PRIMARY KEY CLUSTERED  ([ADATE], [BGDGID], [BVDRGID], [BWRH], [ASETTLENO], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO