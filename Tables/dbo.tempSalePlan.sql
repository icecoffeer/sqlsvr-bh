CREATE TABLE [dbo].[tempSalePlan]
(
[Year] [decimal] (4, 0) NOT NULL,
[Gid] [int] NULL,
[Code] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Name] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[esCode] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[esName] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[ToJan] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToJan__0905C0E4] DEFAULT (0),
[ToFeb] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToFeb__09F9E51D] DEFAULT (0),
[ToMar] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToMar__0AEE0956] DEFAULT (0),
[ToApr] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToApr__0BE22D8F] DEFAULT (0),
[ToMay] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToMay__0CD651C8] DEFAULT (0),
[ToJun] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToJun__0DCA7601] DEFAULT (0),
[ToJul] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToJul__0EBE9A3A] DEFAULT (0),
[ToAug] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToAug__0FB2BE73] DEFAULT (0),
[ToSep] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToSep__10A6E2AC] DEFAULT (0),
[ToOct] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToOct__119B06E5] DEFAULT (0),
[ToNov] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToNov__128F2B1E] DEFAULT (0),
[ToDec] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToDec__13834F57] DEFAULT (0),
[ToJanGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToJan__4DAFF0EC] DEFAULT (0),
[ToFebGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToFeb__4EA41525] DEFAULT (0),
[ToMarGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToMar__4F98395E] DEFAULT (0),
[ToAprGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToApr__508C5D97] DEFAULT (0),
[ToMayGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToMay__518081D0] DEFAULT (0),
[ToJunGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToJun__5274A609] DEFAULT (0),
[ToJulGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToJul__5368CA42] DEFAULT (0),
[ToAugGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToAug__545CEE7B] DEFAULT (0),
[ToSepGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToSep__555112B4] DEFAULT (0),
[ToOctGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToOct__564536ED] DEFAULT (0),
[ToNovGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToNov__57395B26] DEFAULT (0),
[ToDecGP] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__tempSaleP__ToDec__582D7F5F] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempSalePlan] ADD CONSTRAINT [PK__tempSalePlan__14777390] PRIMARY KEY CLUSTERED  ([Year], [Code]) ON [PRIMARY]
GO
