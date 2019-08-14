CREATE TABLE [dbo].[BLSMRPT]
(
[ASETTLENO] [int] NOT NULL,
[ASTORE] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[CQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__CQ__446BDB6B] DEFAULT (0),
[CT] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__CT__455FFFA4] DEFAULT (0),
[PJQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PJQ__465423DD] DEFAULT (0),
[PJI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PJI__47484816] DEFAULT (0),
[PJTQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PJTQ__483C6C4F] DEFAULT (0),
[PJTT] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PJTT__49309088] DEFAULT (0),
[PJTI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PJTI__4A24B4C1] DEFAULT (0),
[ZPJQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__ZPJQ__4B18D8FA] DEFAULT (0),
[ZPJI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__ZPJI__4C0CFD33] DEFAULT (0),
[ZPJTQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__ZPJTQ__4D01216C] DEFAULT (0),
[ZPJTT] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__ZPJTT__4DF545A5] DEFAULT (0),
[ZPJTI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__ZPJTI__4EE969DE] DEFAULT (0),
[LSQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LSQ__4FDD8E17] DEFAULT (0),
[LST] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LST__50D1B250] DEFAULT (0),
[LSI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LSI__51C5D689] DEFAULT (0),
[LSTQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LSTQ__52B9FAC2] DEFAULT (0),
[LSTT] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LSTT__53AE1EFB] DEFAULT (0),
[LSTI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LSTI__54A24334] DEFAULT (0),
[LS92] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__LS92__5596676D] DEFAULT (0),
[DBJQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__DBJQ__568A8BA6] DEFAULT (0),
[DBJI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__DBJI__577EAFDF] DEFAULT (0),
[DBCQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__DBCQ__5872D418] DEFAULT (0),
[DBCT] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__DBCT__5966F851] DEFAULT (0),
[DBCI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__DBCI__5A5B1C8A] DEFAULT (0),
[SHQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__SHQ__5B4F40C3] DEFAULT (0),
[SHI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__SHI__5C4364FC] DEFAULT (0),
[YYQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__YYQ__5D378935] DEFAULT (0),
[YYI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__YYI__5E2BAD6E] DEFAULT (0),
[PDQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PDQ__5F1FD1A7] DEFAULT (0),
[PDI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__PDI__6013F5E0] DEFAULT (0),
[FQ] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__FQ__61081A19] DEFAULT (0),
[FI] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__FI__61FC3E52] DEFAULT (0),
[OUTDIFF] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__OUTDIFF__62F0628B] DEFAULT (0),
[FINPRC] [money] NOT NULL CONSTRAINT [DF__BLSMRPT__FINPRC__63E486C4] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BLSMRPT] ADD CONSTRAINT [PK__BLSMRPT__4377B732] PRIMARY KEY CLUSTERED  ([ASETTLENO], [ASTORE], [BGDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO