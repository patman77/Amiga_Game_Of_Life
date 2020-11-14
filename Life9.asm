		MC68030
; Spiel des Lebens
; geschrieben von Patrick Klie
; benutzt die graphics.library zum Zeichnen der Quadrate
; benutzt Funktionen von OS3

		include	"lvo/exec.i"
		include	"exec/memory.i"
		include	"lvo/intuition.i"
		include	"intuition/intuition.i"
		include	"lvo/graphics.i"
		include	"lvo/diskfont.i"
		include	"libraries/gadtools.i"
		include	"lvo/gadtools.i"
		include	"startup2"

TRUE		equ	1
FALSE		equ	0

begin:
		lea	IntName(PC),a1
		moveq	#37,d0
		movea.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		lea	IntBase(PC),a0
		move.l	d0,(a0)
		beq	quit
Open_Gfx:
		lea	GfxName(PC),a1
		moveq	#37,d0
		movea.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		lea	GfxBase(PC),a0
		move.l	d0,(a0)
		beq	Close_Int
Open_GadTools:
		lea	GadToolsName(PC),a1
		moveq	#37,d0
		movea.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		lea	GadToolsBase(PC),a0
		move.l	d0,(a0)
		beq	Close_Gfx
Open_DiskFont:
		lea	DiskFontName(PC),a1
		moveq	#37,d0
		movea.l	4.w,a6
		jsr	_LVOOpenLibrary(a6)
		lea	DiskFontBase(PC),a0
		move.l	d0,(a0)
		beq	Close_GadTools

		lea	textAttr1(PC),a0
		movea.l	DiskFontBase(PC),a6
		jsr	_LVOOpenDiskFont(a6)
		lea	TextFont1(PC),a0
		move.l	d0,(a0)
		beq	Close_DiskFont

Open_Screen:
		suba.l	a0,a0
		lea	Screen1_Tags(PC),a1
		movea.l	IntBase(PC),a6
		jsr	_LVOOpenScreenTagList(a6)
		lea	Screen1(PC),a0
		move.l	d0,(a0)
		beq	Close_DiskFont
		lea	Window1_Tags(PC),a0
		move.l	Screen1(PC),4(a0)
Open_Window:
		suba.l	a0,a0
		lea	Window1_Tags(PC),a1
		movea.l	IntBase(PC),a6
		jsr	_LVOOpenWindowTagList(a6)
		lea	Window1(PC),a0
		move.l	d0,(a0)
		beq	Close_Screen
		lea	UserPort1(PC),a1
		lea	RastPort1(PC),a2
		movea.l	Window1(PC),a0
		move.l	wd_UserPort(a0),(a1)
		move.l	wd_RPort(a0),(a2)

GetVisualInfo:
		movea.l	GadToolsBase(PC),a6
		movea.l	Screen1(PC),a0
		suba.l	a1,a1
		jsr	_LVOGetVisualInfoA(a6)
		lea	VisualInfo(PC),a0
		move.l	d0,(a0)
		beq	Close_Window
		lea	TagList1(PC),a0
		move.l	d0,4(a0)
		lea	TagList3(PC),a0
		move.l	d0,4(a0)
Alloc_Mem1:
		move.l	#42*42,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		movea.l	4.w,a6
		jsr	_LVOAllocVec(a6)
                lea	Feld1(PC),a0
		move.l	d0,(a0)
		beq	FreeVisualInfo
Alloc_Mem2:
		move.l	#42*42,d0
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1
		movea.l	4.w,a6
		jsr	_LVOAllocVec(a6)
		lea	Feld2(PC),a0
		move.l	d0,(a0)
		beq.s	Free_Mem1
		bra.s	Programm

Free_Mem2:
		movea.l	Feld2(PC),a1
		movea.l	4.w,a6
		jsr	_LVOFreeVec(a6)

Free_Mem1:
		movea.l	Feld1(PC),a1
		movea.l	4.w,a6
		jsr	_LVOFreeVec(a6)

FreeVisualInfo:
		movea.l	GadToolsBase(PC),a6
		movea.l	VisualInfo(PC),a0
		jsr	_LVOFreeVisualInfo(a6)

Close_Window:
		movea.l	Window1(PC),a0
		movea.l	IntBase(PC),a6
		jsr	_LVOCloseWindow(a6)

Close_Screen:
		movea.l	Screen1(PC),a0
		movea.l	IntBase(PC),a6
		jsr	_LVOCloseScreen(a6)

RemFont:
		movea.l	TextFont1(PC),a1
		movea.l	GfxBase(PC),a6
		jsr	_LVOCloseFont(a6)

Close_DiskFont:
		movea.l	DiskFontBase(PC),a1
		movea.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)

Close_GadTools:
		movea.l	GadToolsBase(PC),a1
		movea.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)

Close_Gfx:
		movea.l	GfxBase(PC),a1
		movea.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)

Close_Int:
		movea.l	IntBase(PC),a1
		movea.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)

quit:
		moveq	#0,d0
		rts

; hier beginnt das eigentliche Programm

Programm:
		bsr	DrawBox
		bsr	DrawOthers
main:
		lea	AnzahlGen(PC),a0
		clr.l	(a0)
		move.l	AnzahlGen(PC),d2
		lea	Text1(PC),a2
		bsr	decl
		bsr	Feld1_löschen
		bsr	Clear_Generation
		bsr	Generation
		bsr	Clear_Screen
		lea	MouseX(PC),a0
		move.l	#0,(a0)
		lea	MouseY(PC),a0
		move.l	#0,(a0)

Pause:
		movea.l	UserPort1(PC),a0
		movea.l	4.w,a6
		jsr	_LVOWaitPort(a6)

		movea.l	UserPort1(PC),a0
		movea.l	4.w,a6
		jsr	_LVOGetMsg(a6)
		movea.l	d0,a1
		move.l	im_Class(a1),d4
		move.w	im_MouseX(a1),d5
		move.w	im_MouseY(a1),d6
		move.w	im_Code(a1),d7
		jsr	_LVOReplyMsg(a6)
		cmpi.l	#IDCMP_CLOSEWINDOW,d4
		beq	Free_Mem2
		cmpi.l	#IDCMP_MOUSEBUTTONS,d4
		beq	Draw_Cell
		cmpi.l	#IDCMP_VANILLAKEY,d4
		beq	Rechnen
		cmpi.l	#IDCMP_MOUSEMOVE,d4
		beq	Koordinaten
		bra	Pause
Draw_Cell:
		cmpi.l	#SELECTDOWN,d7
		bne     Pause
		cmpi.w	#40,d5
		bmi	Pause
		cmpi.w	#440,d5
		bpl	Pause
		cmpi.w	#40,d6
		bmi	Pause
		cmpi.w  #440,d6
		bpl	Pause
go_on:
		moveq	#0,d1
		move.w	d5,d1
		moveq	#10,d0
		divu	d0,d1
		swap	d1
		sub.w	d1,d5
		moveq	#0,d1
		move.w	d6,d1
		moveq	#10,d0
		divu	d0,d1
		swap    d1
		sub.w	d1,d6

		movea.l	GfxBase(PC),a6

		moveq	#0,d0
		moveq	#0,d1
		move.w	d5,d0
		divu	#10,d0
		move.w	d6,d1
		divu	#10,d1
		subi.w	#3,d0
		subi.w	#3,d1
		moveq	#42,d7
		mulu.w	d1,d7
		add.w	d0,d7
		move.l	Feld1(PC),a0
		lea	0(a0,d7.w),a1
		move.b	(a1),d0
		beq	setzen
löschen:
		move.b	#FALSE,(a1)
		bsr	Grau
		bra	weiter
setzen:
		move.b	#TRUE,(a1)
		bsr	Schwarz
weiter:
		movea.l	a5,a1
		move.w	d5,d0
		move.w	d6,d1
		jsr	_LVOMove(a6)
		move.w	d5,d0
		move.w	d6,d1
		move.w	d0,d2
		move.w	d1,d3
		add.w	#8,d2
		add.w	#8,d3
                move.l	a5,a1
		jsr	_LVORectFill(a6)
		bra	Pause
Rechnen:
		bsr	Clear_Status
		movea.l	UserPort1(PC),a0
		movea.l	4.w,a6
		jsr	_LVOGetMsg(a6)
		tst.l	d0
		beq	weiter2
		movea.l	d0,a1
		move.l	im_Class(a1),d7
		jsr	_LVOReplyMsg(a6)
		cmpi.l	#IDCMP_VANILLAKEY,d7
		beq	Abbruch
weiter2:
		lea	AnzahlGen(PC),a0
		add.l	#1,(a0)
		move.l	AnzahlGen(PC),d2
		lea	Text1(PC),a2
		bsr	decl
		bsr	Generation
		moveq	#0,d7
Loop1:
		cmpi.w	#39,d7
		bgt	weiter3
		addq.w	#1,d7
		moveq	#0,d6
Loop2:
		cmpi.w	#39,d6
		bgt	Loop1
		addq.w	#1,d6
		moveq	#42,d5
		mulu.w	d7,d5
		add.w	d6,d5
		movea.l	Feld1(PC),a0
		lea	0(a0,d5.w),a0
		move.b	(a0),d0
		beq	Loop2

		movea.l	Feld2(PC),a1
		lea	0(a1,d5.w),a1
linksoben:
		addq.b	#1,-43(a1)
oben:
		addq.b	#1,-42(a1)
rechtsoben:
		addq.b	#1,-41(a1)
rechts:
		addq.b	#1,1(a1)
rechtsunten:
		addq.b	#1,43(a1)
unten:
		addq.b	#1,42(a1)
linksunten:
		addq.b	#1,41(a1)
links:
		addq.b	#1,-1(a1)
		bra	Loop2

weiter3:
		moveq	#0,d7
		movea.l	Feld2(PC),a0
		movea.l	Feld1(PC),a1
LoopI:
		cmpi.w	#39,d7
		bgt	Feld2_löschen
		addq.w	#1,d7
		moveq	#0,d6
LoopII:
		cmpi.w	#39,d6
		bgt	LoopI
		addq.w	#1,d6
		moveq	#42,d5
		mulu.w	d7,d5
		add.w	d6,d5
		move.b	0(a0,d5.w),d0
		cmpi.b	#2,d0
		beq	überleben
		cmpi.b	#3,d0
		beq	Geburt
Zelle_tot:
		move.b	#0,0(a1,d5.w)
		bra	LoopII
überleben:
		move.b	0(a1,d5.w),d0
		beq	LoopII
Geburt:
		move.b	#TRUE,0(a1,d5.w)
		bra	LoopII
Feld2_löschen:
		movea.l	Feld2(PC),a1
		move.l	#42*42,d0
		moveq	#1,d1
		movea.l	GfxBase(PC),a6
		jsr	_LVOBltClear(a6)

Zeichnen2:
		bsr	Clear_Screen
		bsr	Schwarz
		movea.l	Feld1(PC),a5
		moveq	#0,d6
		moveq	#0,d7
Schleife3:
		cmpi.w	#39,d7
		bgt	Leben
		addq.w	#1,d7
		moveq	#0,d6
Schleife4:
		cmpi.w	#39,d6
		bgt	Schleife3
		addq.w	#1,d6
		moveq	#42,d3
		mulu.w	d7,d3
		add.w	d6,d3
		move.b  0(a5,d3.w),d0
		beq	Schleife4
Draw_Cell2:
		move.w	d6,d0
		addq.w	#3,d0
		mulu	#10,d0
		move.w	d7,d1
		addq.w	#3,d1
		mulu	#10,d1
		move.w	d0,d2
		move.w	d1,d3
		add.w	#8,d2
		add.w	#8,d3
		movea.l	RastPort1(PC),a1
		movea.l	GfxBase(PC),a6
		jsr	_LVORectFill(a6)
		bra	Schleife4

Leben:
		move.l	#42*42-1,d0
		movea.l	Feld1(PC),a0
Schleife:
		move.b	(a0)+,d1
		bne	Statistik
		dbra	d0,Schleife
		bra	allestot

Statistik:
		move.l	#42*42-1,d0
		movea.l	Feld1(PC),a0
		moveq	#0,d7
Schleife6:
                move.b	(a0)+,d1
		beq	weiter4
		addq.w	#1,d7
weiter4:
		dbra	d0,Schleife6
		moveq	#1,d0
		moveq	#0,d1
		move.w	#455,d2
		move.w	#247,d3
		move.w	#615,d4
		move.w	#434,d5
		movea.l	RastPort1(PC),a1
                movea.l	GfxBase(PC),a6
		jsr	_LVOScrollRasterBF(a6)
		cmpi.w	#935,d7
		bmi	weiter5
		move.w	#935,d7
		move.l	Screen1_Tags+36(PC),d0
		cmpi.l	#1,d0
		beq     weiter5
		bsr	Weiß
		bra	weiter6
weiter5:
		bsr	Schwarz
weiter6:
		move.w	#615,d0
		move.w	#434,d1
		divu	#5,d7
		sub.w	d7,d1
		movea.l	RastPort1(PC),a1
		movea.l	GfxBase(PC),a6
		jsr	_LVOMove(a6)
		move.w	#615,d0
		move.w	#434,d1
		movea.l	RastPort1(PC),a1
		movea.l	GfxBase(PC),a6
		jsr	_LVODraw(a6)
		bra	Rechnen

allestot:
		bsr	Schwarz
		movea.l	RastPort1(PC),a1
		move.l	#489,d0
		moveq	#78,d1
		jsr	_LVOMove(a6)
		movea.l	RastPort1(PC),a1
		lea	Text2(PC),a0
		moveq	#Text2ende-Text2,d0
		jsr	_LVOText(a6)
stop:
		movea.l	UserPort1(PC),a0
		movea.l	4.w,a6
		jsr	_LVOWaitPort(a6)
		movea.l	UserPort1(PC),a0
		jsr	_LVOGetMsg(a6)
		move.l	d0,a1
		move.l	im_Class(a1),d4
		jsr	_LVOReplyMsg(a6)
		cmpi.l	#IDCMP_CLOSEWINDOW,d4
		beq     Free_Mem2
		cmpi.l	#IDCMP_MOUSEBUTTONS,d4
		bne	stop
		bsr	Clear_Status
		bsr	Clear_Statistic
		bra	main

Koordinaten:
		cmpi.w	#40,d5
                bmi	Pause
		cmpi.w	#40,d6
		bmi	Pause
		cmpi.w	#440,d5
		bpl	Pause
		cmpi.w	#440,d6
		bpl	Pause
		andi.l	#%00000000000000001111111111111111,d5
		divu	#10,d5
		andi.l	#%00000000000000001111111111111111,d5
		subq.l	#3,d5
		lea	MouseX(PC),a0
		move.l	d5,(a0)
		andi.l	#%00000000000000001111111111111111,d6
		divu	#10,d6
		andi.l	#%00000000000000001111111111111111,d6
		subq.l	#3,d6
		lea	MouseY(PC),a0
		move.l	d6,(a0)
		move.l	MouseX(PC),d2
		lea	Text7(PC),a2
		bsr	decl
		move.l	MouseY(PC),d2
		lea	Text8(PC),a2
		bsr	decl
		bsr	Schwarz
		movea.l	GfxBase(PC),a6
		movea.l	RastPort1(PC),a1
		move.w	#500,d0
		moveq	#79,d1
		jsr	_LVOMove(a6)
		lea	Text7(PC),a0
		moveq	#Text8ende-Text7,d0
		movea.l	RastPort1(PC),a1
		jsr	_LVOText(a6)
		bra	Pause
Abbruch:
		movea.l	GfxBase(PC),a6
		movea.l	RastPort1(PC),a1
                move.w	#470,d0
		moveq	#79,d1
		jsr	_LVOMove(a6)
		bsr	Schwarz
		movea.l	RastPort1(PC),a1
		lea	Text3(PC),a0
                moveq	#Text3ende-Text3,d0
		jsr	_LVOText(a6)
		movea.l	4.w,a6
		movea.l	UserPort1(PC),a0
		jsr	_LVOWaitPort(a6)
		movea.l	UserPort1(PC),a0
		jsr	_LVOGetMsg(a6)
		movea.l	d0,a1
		move.l	im_Class(a1),d7
		jsr	_LVOReplyMsg(a6)
		cmpi.l	#IDCMP_CLOSEWINDOW,d7
		beq	Free_Mem2
		cmpi.l	#IDCMP_MOUSEBUTTONS,d7
		bne	Abbruch
		bsr	Clear_Status
		bsr	Clear_Statistic
		bra	main

Clear_Statistic:
		move.w	#455,d0
		move.w	#247,d1
		move.w	#615,d2
		move.w	#434,d3
		movea.l	RastPort1(PC),a1
		movea.l	GfxBase(PC),a6
		jsr	_LVOEraseRect(a6)
		lea	AnzahlGen(PC),a0
		move.l	#0,(a0)
		bra	Generation


decl:		; wandelt Zahl in d2 in ASCII-String (in a2) um
plus:
		moveq	#5,d0
		movea.l	a2,a0
;		add.l	#1,a0
		lea	pwrof10(PC),a1
next:
		moveq	#"0",d1
dec:
		addq	#1,d1
		sub.l	(a1),d2
		bcc.s	dec
		subq	#1,d1
		add.l	(a1),d2
		move.b	d1,(a0)+
		lea	4(a1),a1
		dbra	d0,next
		movea.l	a2,a0
rep:
		move.b	#" ",(a0)+
		cmp.b	#"0",(a0)
		beq	rep
done:
		rts
pwrof10:
		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10
		dc.l	1

Schwarz:
		movea.l	GfxBase(PC),a6
		movea.l	RastPort1(PC),a1
		moveq	#1,d0
		jmp	_LVOSetAPen(a6)
Grau:
		movea.l	GfxBase(PC),a6
		movea.l	RastPort1(PC),a1
		moveq	#0,d0
		jmp	_LVOSetAPen(a6)
Weiß:
		movea.l	GfxBase(PC),a6
		movea.l	RastPort1(PC),a1
		moveq	#2,d0
		jmp	_LVOSetAPen(a6)
Feld1_löschen:
		movea.l	Feld1(PC),a5
		move.l	#42*42-1,d7
Schleife5:
		clr.b	(a5)+
		dbra	d7,Schleife5
                rts
Generation:
		movea.l	GfxBase(PC),a6
		movea.l	RastPort1(PC),a5
		bsr	Schwarz
		move.l	#516,d0
		move.l	#51,d1
		movea.l	a5,a1
		jsr	_LVOMove(a6)
		lea	Text1(PC),a0
		moveq	#Text1ende-Text1,d0
		movea.l	a5,a1
		jmp	_LVOText(a6)

Clear_Screen:
		movea.l	GfxBase(PC),a6
		moveq	#40,d0
		moveq	#40,d1
		move.w	#439,d2
		move.w	#439,d3
		movea.l	RastPort1(PC),a1
		jmp	_LVOEraseRect(a6)

Clear_Status:
		movea.l	RastPort1(PC),a1
		move.w	#453,d0
		moveq	#68,d1
		move.w	#617,d2
		moveq	#83,d3
		movea.l	GfxBase(PC),a6
		jmp	_LVOEraseRect(a6)

Clear_Generation:
		movea.l	GfxBase(PC),a6
		move.w	#453,d0
		moveq	#40,d1
		move.w	#617,d2
		moveq	#55,d3
		movea.l	RastPort1(PC),a1
		jmp	_LVOEraseRect(a6)
DrawBox:
		movea.l	GadToolsBase(PC),a6
		movea.l	RastPort1(PC),a0
		moveq	#37,d0
		moveq	#38,d1
		move.l	#405,d2
		move.l	#403,d3
		lea	TagList1(PC),a1
		jmp	_LVODrawBevelBoxA(a6)

DrawOthers:
		movea.l	GadToolsBase(PC),a6
		movea.l	RastPort1(PC),a0
		move.w	#450,d0
		moveq	#38,d1
		move.w	#170,d2
		moveq	#19,d3
		lea	TagList3(PC),a1
		jsr	_LVODrawBevelBoxA(a6)

		movea.l	RastPort1(PC),a0
		move.w	#450,d0
		moveq	#66,d1
		move.w	#170,d2
		moveq	#19,d3
		lea	TagList3(PC),a1
		jsr	_LVODrawBevelBoxA(a6)

		movea.l	RastPort1(PC),a0
		move.w	#450,d0
		moveq	#94,d1
		move.w	#170,d2
		move.w	#137,d3
		lea	TagList3(PC),a1
		jsr	_LVODrawBevelBoxA(a6)

		movea.l	RastPort1(PC),a0
		move.w	#450,d0
		move.w	#240,d1
		move.w	#170,d2
		move.w	#201,d3
		lea	TagList3(PC),a1
		jsr	_LVODrawBevelBoxA(a6)

		bsr	Schwarz
		move.w	#487,d0
		moveq	#126,d1
		movea.l	RastPort1(PC),a1
		jsr	_LVOMove(a6)
		lea	Text4(PC),a0
		moveq	#Text4ende-Text4,d0
		movea.l	RastPort1(PC),a1
		jsr	_LVOText(a6)

		move.w	#489,d0
		move.w	#163,d1
		movea.l	RastPort1(PC),a1
		jsr	_LVOMove(a6)
		lea	Text5(PC),a0
		moveq	#Text5ende-Text5,d0
		movea.l	RastPort1(PC),a1
		jsr	_LVOText(a6)

		move.w	#503,d0
		move.w	#200,d1
		movea.l	RastPort1(PC),a1
		jsr	_LVOMove(a6)
		lea	Text6(PC),a0
		moveq	#Text6ende-Text6,d0
		movea.l	RastPort1(PC),a1
		jmp	_LVOText(a6)



IntName:	dc.b	"intuition.library",0
GfxName:	dc.b	"graphics.library",0
GadToolsName:	dc.b	"gadtools.library",0
DiskFontName:	dc.b	"diskfont.library",0
		even
IntBase:	ds.l	1
GfxBase:	ds.l	1
GadToolsBase:	ds.l	1
DiskFontBase:	ds.l	1
Screen1_Tags:
                dc.l	SA_Left,0
		dc.l	SA_Top,0
		dc.l	SA_Width,640
		dc.l	SA_Height,480
		dc.l	SA_Depth,2			; 1 > schneller
		dc.l	SA_DisplayID,$39024
                dc.l	SA_Title,ScreenTitle
		dc.l	SA_FullPalette,TRUE
		dc.l	SA_Font,textAttr1
;		dc.l	SA_SysFont,TRUE
		dc.l	SA_Pens,PenArray
		dc.l	SA_AutoScroll,TRUE
		dc.l	SA_Overscan,1
		dc.l	SA_Interleaved,TRUE
;		dc.l	SA_Exclusive,TRUE
		dc.l	TAG_DONE
Screen1:	ds.l	1
PenArray:	dc.w	$ffff
;		dc.w	0,0,1,2,1,3,0,0,2,1,2,1,-1
textAttr1:	dc.l	FontName1
		dc.w	15
		dc.b	0,$2!$40
FontName1:	dc.b	"times.font",0
		even
TextFont1:	ds.l	1
TextFont2:	ds.l	1
Window1_Tags:
		dc.l	WA_CustomScreen,0
		dc.l	WA_Top,18
		dc.l	WA_Left,0
		dc.l	WA_Height,462
		dc.l	WA_Width,640
		dc.l	WA_CloseGadget,TRUE
		dc.l	WA_IDCMP,IDCMP_MOUSEMOVE!IDCMP_CLOSEWINDOW!IDCMP_MOUSEBUTTONS!IDCMP_VANILLAKEY
		dc.l	WA_Activate,TRUE
		dc.l	WA_Title,WindowTitle
		dc.l	WA_ReportMouse,TRUE
		dc.l	WA_DragBar,TRUE
		dc.l	TAG_DONE
Window1:	ds.l	1
UserPort1:	ds.l	1
RastPort1:	ds.l	1
Feld1:		ds.l	1
Feld2:		ds.l	1
ScreenTitle:	dc.b	"Spiel des Lebens",0
WindowTitle:	dc.b	"Ausgabefenster",0
zweimal:	ds.b	1
Text1:		dc.b	"     0   "
Text1ende:
Nachbarn:	ds.b	1
		even
AnzahlGen:	ds.l	1
MouseX:		dc.l	4
MouseY:		dc.l	4
TagList1:
		dc.l	GT_VisualInfo,0
		dc.l	TAG_DONE
VisualInfo:	ds.l	1
TagList3:
		dc.l	GT_VisualInfo,0
		dc.l	GTBB_Recessed,TRUE
		dc.l	TAG_DONE
Text2:		dc.b	"tot - Maustaste"
Text2ende:
Text3:		dc.b	"Abbruch - Maustaste"
Text3ende:
Text4:		dc.b	"Spiel des Lebens"
Text4ende:
Text5:		dc.b	"geschrieben von"
Text5ende:
Text6:		dc.b	"Patrick Klie"
Text6ende:
		even
Text7:		dc.b	"     0    "
Text7ende:
Text8:		dc.b	"     0   "
Text8ende:

		END

