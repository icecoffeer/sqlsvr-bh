CREATE TABLE [dbo].[Fifomrpt]
(
[ASETTLENO] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[lastcostQTY] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__lastco__25E8EAF9] DEFAULT (0),
[lastcosttotal] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__lastco__26DD0F32] DEFAULT (0),
[costqty] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__costqt__27D1336B] DEFAULT (0),
[costtotal] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__costto__28C557A4] DEFAULT (0),
[zjqty] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__zjqty__29B97BDD] DEFAULT (0),
[zjtotal] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__zjtota__2AADA016] DEFAULT (0),
[zjtqty] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__zjtqty__2BA1C44F] DEFAULT (0),
[zjttotal] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__zjttot__2C95E888] DEFAULT (0),
[outqty] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__outqty__2D8A0CC1] DEFAULT (0),
[outtotal] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__outtot__2E7E30FA] DEFAULT (0),
[indj] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__indj__2F725533] DEFAULT (0),
[invadjqty] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__invadj__3066796C] DEFAULT (0),
[invadjtotal] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__invadj__315A9DA5] DEFAULT (0),
[outcost] [money] NOT NULL CONSTRAINT [DF__Fifomrpt__outcos__324EC1DE] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Fifomrpt] ADD CONSTRAINT [PK__Fifomrpt__5C37ACAD] PRIMARY KEY CLUSTERED  ([ASETTLENO], [GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
