; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Req. & Donate" tab under the "Village" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: MonkeyHunter (07-2016), CodeSlinger69 (01-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_DONATE = 0, $g_hGUI_DONATE_TAB = 0, $g_hGUI_DONATE_TAB_ITEM1 = 0, $g_hGUI_DONATE_TAB_ITEM2 = 0

; Request
Global $g_hChkRequestTroopsEnable = 0, $g_hTxtRequestCC = 0
Global $g_hChkReinforcementCake = 0, $g_hChkUpdateRequest = 0
Global $g_hCmbRequestTroop1 = 0, $g_hCmbRequestTroop2 = 0, $g_hRequestTroopQuantity1 = 0, $g_hRequestTroopQuantity2 = 0
Global $g_hCmbRequestSpell1 = 0, $g_hCmbRequestSpell2 = 0, $g_hRequestSpellQuantity1 = 0, $g_hRequestSpellQuantity2 = 0
Global $g_hCmbRequestSiege1 = 0, $g_hCmbRequestSiege2 = 0, $g_hRequestSiegeQuantity1 = 0, $g_hRequestSiegeQuantity2 = 0
Global $g_hLblRequestTroopCap = 0, $g_hLblRequestSpellCap = 0, $g_hLblRequestSiegeCap = 0 
Global $g_hGrpRequestCC = 0

; Donate
Global $g_hChkExtraAlphabets = 0, $g_hChkExtraChinese = 0, $g_hChkExtraKorean = 0, $g_hChkExtraPersian = 0
Global $g_hCmbDonateCategory = 0, $g_hBtnAllSelected = 0, $g_hBtnResetSelected = 0 ; category drop down, check all / none
Global $g_aDonateCategory[3] ; Troops / Spells / Sieges: arrays of [is spell, index] of the icons shown for the category
Global $g_ahChkDonateTroop[$eTroopCount + $eSiegeMachineCount + $eDonExTroopCount]
Global $g_ahTxtDonateTroop[$eTroopCount + $eSiegeMachineCount + $eDonExTroopCount]
Global $g_ahGrpDonateTroop[$eTroopCount + $eSiegeMachineCount + $eDonExTroopCount]
Global $g_ahLblDonateTroop[$eTroopCount + $eSiegeMachineCount + $eDonExTroopCount]
Global $g_ahBtnDonateTroop[$eTroopCount + $eSiegeMachineCount + $eDonExTroopCount]

Global $g_ahChkDonateSpell[$eSpellCount + $eDonExSpellCount]
Global $g_ahTxtDonateSpell[$eSpellCount + $eDonExSpellCount]
Global $g_ahGrpDonateSpell[$eSpellCount + $eDonExSpellCount]
Global $g_ahLblDonateSpell[$eSpellCount + $eDonExSpellCount]
Global $g_ahBtnDonateSpell[$eSpellCount + $eDonExSpellCount]

; Schedule ; Clan castle
Global $g_hGUI_RequestCC = 0, $g_hGUI_DONATECC = 0
Global $g_hGrpDonate = 0, $g_hChkDonate = 1, $g_hLblDonateDisabled = 0, $g_hLblScheduleDisabled = 0

Func CreateVillageDonate()
	$g_hGUI_DONATE = _GUICreate("", $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_VILLAGE)
	;GUISetBkColor($COLOR_WHITE, $g_hGUI_DONATE)
	Local $x = 82
	$g_hChkDonate = GUICtrlCreateCheckbox("", $x + 131, 6, 13, 13)
		GUICtrlSetState(-1,$GUI_CHECKED)
		GUICtrlSetOnEvent(-1, "Doncheck")
		CreateRequestSubTab()
		CreateDonateSubTab()
	GUISwitch($g_hGUI_DONATE)

	$g_hGUI_DONATE_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
	$g_hGUI_DONATE_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_02_STab_01", "Request Troops"))
	$g_hGUI_DONATE_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_02_STab_02", "Donate Troops") & "    ")
	$g_hLblDonateDisabled = GUICtrlCreateLabel(GetTranslatedFileIni("MBR Main GUI", "disabled_Tab_02_STab_02_STab_Info_01", "Note: Donate is disabled, tick the checkmark on the") & " " & GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_02_STab_02", -1) & " " & GetTranslatedFileIni("MBR Main GUI", "disabled_Tab_03_STab_02_STab_Info_02", -1), 5, 30, $g_iSizeWGrpTab3, 374)
		GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateTabItem("")

EndFunc   ;==>CreateVillageDonate

#Region CreateRequestSubTab
Func CreateRequestSubTab()

	Local $sTxtTip = ""
	Local $xStart = 25, $yStart = 45
	$g_hGUI_RequestCC = _GUICreate("", $g_iSizeWGrpTab3, $g_iSizeHGrpTab3, $xStart - 20, $yStart - 20, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_DONATE)
	GUISetBkColor($COLOR_WHITE, $g_hGUI_RequestCC)
	Local $xStart = 20, $yStart = 20
	Local $x = $xStart
	Local $y = $yStart
	$g_hGrpRequestCC = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Donate-CC", "Group_01", "Clan Castle Troops"), $x - 20, $y - 20, $g_iSizeWGrpTab3, 140)
	$y += 10
	$x += 5
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCCRequest, $x - 5, $y, 48, 48, $BS_ICON)
		$g_hChkRequestTroopsEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Donate-CC", "ChkRequestTroopsEnable", "Request Troops / Spells"), $x + 40 + 30, $y - 6)
		GUICtrlSetOnEvent(-1, "chkRequestCC")
		$g_hTxtRequestCC = GUICtrlCreateInput(GetTranslatedFileIni("MBR GUI Design Child Village - Donate-CC", "TxtRequestCC", "any"), $x + 40 + 30, $y + 15, 214, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Donate-CC", "TxtRequestCC_Info_01", "This text is used on your request for troops in the Clan chat."))
	
	$y += 70
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCake, $x - 5, $y - 20, 48, 48, $BS_ICON)
		$g_hChkReinforcementCake = GUICtrlCreateCheckbox("Use Reinforcement Cake", $x + 40 + 30, $y - 10)
			GUICtrlSetOnEvent(-1, "chkReinforcementCake")
	GUICtrlCreateGroup("", -99, -99, 1, 1)					
		
	$x = 25
	$y = 150
	
	GUICtrlCreateGroup("Reinforcement", $x - 25, $y, $g_iSizeWGrpTab3, 169)
		$g_hChkUpdateRequest = GUICtrlCreateCheckbox("Update Request", $x - 15, $y + 20)
			GUICtrlSetOnEvent(-1, "chkUpdateRequest")
			
		Local $sTxtCmbTroop, $sTxtCmbSpell, $sTxtCmbSiege
		For $i = 0 To UBound($g_aCmbRequestTroop) - 1
			$sTxtCmbTroop &= $g_aCmbRequestTroop[$i][1] & "|"
		Next
		For $i = 0 To UBound($g_aCmbRequestSpell) - 1
			$sTxtCmbSpell &= $g_aCmbRequestSpell[$i][1] & "|"
		Next
		For $i = 0 To UBound($g_aCmbRequestSiege) - 1
			$sTxtCmbSiege &= $g_aCmbRequestSiege[$i][1] & "|"
		Next
	
	$x = 10
	$y += 25
		GuiCtrlCreateLabel("Troop : ", $x, $y + 20, 80)
		GuiCtrlCreateLabel("Spell : ", $x, $y + 45, 80)
		GuiCtrlCreateLabel("Siege : ", $x, $y + 70, 80)
	$x = 50
		$g_hCmbRequestTroop1 = GUICtrlCreateCombo("", $x, $y + 20, 100, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, $sTxtCmbTroop, "")
			_GUICtrlComboBox_SetCurSel(-1, 0)
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hCmbRequestSpell1 = GUICtrlCreateCombo("", $x, $y + 45, 100, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, $sTxtCmbSpell, "")
			_GUICtrlComboBox_SetCurSel(-1, 0)
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hCmbRequestSiege1 = GUICtrlCreateCombo("", $x, $y + 70, 100, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, $sTxtCmbSiege, "")
			_GUICtrlComboBox_SetCurSel(-1, 0)
			GUICtrlSetOnEvent(-1, "RequestQty")
	$x = 155
		$g_hRequestTroopQuantity1 = GUICtrlCreateInput("0", $x, $y + 20, 25, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hRequestSpellQuantity1 = GUICtrlCreateInput("0", $x, $y + 45, 25, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hRequestSiegeQuantity1 = GUICtrlCreateInput("0", $x, $y + 70, 25, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "RequestQty")
	$x = 190
		$g_hCmbRequestTroop2 = GUICtrlCreateCombo("", $x, $y + 20, 100, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, $sTxtCmbTroop, "")
			_GUICtrlComboBox_SetCurSel(-1, 0)
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hCmbRequestSpell2 = GUICtrlCreateCombo("", $x, $y + 45, 100, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, $sTxtCmbSpell, "")
			_GUICtrlComboBox_SetCurSel(-1, 0)
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hCmbRequestSiege2 = GUICtrlCreateCombo("", $x, $y + 70, 100, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, $sTxtCmbSiege, "")
			_GUICtrlComboBox_SetCurSel(-1, 0)
			GUICtrlSetOnEvent(-1, "RequestQty")
	$x = 295
		$g_hRequestTroopQuantity2 = GUICtrlCreateInput("0", $x, $y + 20, 25, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hRequestSpellQuantity2 = GUICtrlCreateInput("0", $x, $y + 45, 25, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "RequestQty")
		$g_hRequestSiegeQuantity2 = GUICtrlCreateInput("0", $x, $y + 70, 25, 20, BitOR($SS_CENTER, $ES_AUTOHSCROLL))
			GUICtrlSetOnEvent(-1, "RequestQty")
	$x = 330
		$g_hLblRequestTroopCap = GuiCtrlCreateLabel("", $x, $y + 22, 25, 20)
		$g_hLblRequestSpellCap = GuiCtrlCreateLabel("", $x, $y + 47, 25, 20)
		$g_hLblRequestSiegeCap = GuiCtrlCreateLabel("", $x, $y + 72, 25, 20)
	
	GUICtrlCreateGroup("", -99, -99, 1, 1)	

EndFunc   ;==>CreateRequestSubTab
#EndRegion

Func CreateDonateSubTab()
	Local $xStart = 25, $yStart = 45
	$g_hGUI_DONATECC = _GUICreate("", $g_iSizeWGrpTab3, $g_iSizeHGrpTab3, $xStart - 20, $yStart - 20, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_DONATE)
	GUISetBkColor($COLOR_WHITE, $g_hGUI_DONATECC)
	Local $xStart = 20, $yStart = 20
	;~ -------------------------------------------------------------
	;~ Language Variables used a lot
	;~ -------------------------------------------------------------

	Local $sTxtNothing = GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtNothing", "Nothing")

	Local $sTxtDonate = GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonate", "Donate")
	Local $sTxtDonateTip = GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTip", "Check this to donate")
	Local $sTxtKeywords = GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtKeywords", "Keywords for donating")
	Local $sTxtDonateTipTroop = GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTipTroop", "if keywords match the Chat Request.")

	Local $sTxtBarbarians = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtBarbarians", "Barbarians")
	Local $sTxtArchers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtArchers", "Archers")
	Local $sTxtGiants = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtGiants", "Giants")
	Local $sTxtGoblins = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtGoblins", "Goblins")
	Local $sTxtWallBreakers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtWallBreakers", "Wall Breakers")
	Local $sTxtBalloons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtBalloons", "Balloons")
	Local $sTxtRocketBalloons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtRocketBalloons", "Rocket Balloons")
	Local $sTxtWizards = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtWizards", "Wizards")
	Local $sTxtHealers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtHealers", "Healers")
	Local $sTxtDragons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtDragons", "Dragons")
	Local $sTxtPekkas = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtPekkas", "Pekkas")
	Local $sTxtMinions = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtMinions", "Minions")
	Local $sTxtHogRiders = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtHogRiders", "Hog Riders")
	Local $sTxtValkyries = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtValkyries", "Valkyries")
	Local $sTxtGolems = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtGolems", "Golems")
	Local $sTxtWitches = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtWitches", "Witches")
	Local $sTxtLavaHounds = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtLavaHounds", "Lava Hounds")
	Local $sTxtBowlers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtBowlers", "Bowlers")
	Local $sTxtSuperBowlers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperBowlers", "Super Bowlers")
	Local $sTxtIceGolems = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtIceGolems", "Ice Golems")
	Local $sTxtHeadhunters = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtHeadhunters", "Headhunters")
	Local $sTxtBabyDragons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtBabyDragons", "Baby Dragons")
	Local $sTxtMiners = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtMiners", "Miners")
	Local $sTxtSuperMiners = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperMiners", "Super Miners")
	Local $sTxtElectroDragons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtElectroDragons", "Electro Dragons")
	Local $sTxtYetis = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtYetis", "Yetis")
	Local $sTxtDragonRiders = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtDragonRiders", "Dragon Riders")
	Local $sTxtElectroTitans = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtElectroTitans", "Electro Titans")

	Local $sTxtWallWreckers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtWallWreckers", "Wall Wreckers")
	Local $sTxtBattleBlimps = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtBattleBlimps", "Battle Blimps")
	Local $sTxtStoneSlammers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtStoneSlammers", "Stone Slammers")
	Local $sTxtSiegeBarracks = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSiegeBarracks", "Siege Barracks")
	Local $sTxtLogLaunchers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtLogLaunchers", "Log Launchers")
	Local $sTxtFlameFlingers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtFlameFlingers", "Flame Flingers")
	Local $sTxtBattleDrills = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtBattleDrills", "Battle Drills")

	Local $sTxtSuperBarbarians = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperBarbarians", "Super Barbarians")
	Local $sTxtSuperArchers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperArchers", "Super Archers")
	Local $sTxtSuperGiants = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperGiants", "Super Giants")
	Local $sTxtSneakyGoblins = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSneakyGoblins", "Sneaky Goblins")
	Local $sTxtSuperWallBreakers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperWallBreakers", "SWall Breakers")
	Local $sTxtSuperWizards = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperWizards", "Super Wizards")
	Local $sTxtSuperDragons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperDragons", "Super Dragons")
	Local $sTxtInfernoDragons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtInfernoDragons", "Inferno Dragons")
	Local $sTxtSuperMinions = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperMinions", "Super Minions")
	Local $sTxtSuperValkyries = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperValkyries", "Super Valkyries")
	Local $sTxtSuperWitches = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperWitches", "Super Witches")
	Local $sTxtIceHounds = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtIceHounds", "Ice Hounds")

	Local $sTxtLightningSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortLightningSpells", "Lightning")
	Local $sTxtHealSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortHealSpells", "Heal")
	Local $sTxtRageSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortRageSpells", "Rage")
	Local $sTxtJumpSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortJumpSpells", "Jump")
	Local $sTxtFreezeSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortFreezeSpells", "Freeze")
	Local $sTxtInvisibilitySpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortInvisibilitySpells", "Invisibility")
	Local $sTxtRecallSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortRecallSpells", "Recall")
	Local $sTxtPoisonSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortPoisonSpells", "Poison")
	Local $sTxtEarthquakeSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortEarthquakeSpells", "EarthQuake")
	Local $sTxtHasteSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortHasteSpells", "Haste")
	Local $sTxtSkeletonSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortSkeletonSpells", "Skeleton")
	Local $sTxtBatSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortBatSpells", "Bat")
	Local $sTxtCloneSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortCloneSpells", "Clone")
	Local $sTxtOvergrowthSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtShortOvergrowthSpells", "Overgrowth")
	Local $sTxtRootRiders = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtRootRiders", "Root Riders")
	Local $sTxtAppWards = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtAppWards", "App. Wardens")
	Local $sTxtSuperHogRiders = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperHogRiders", "Super Hog Riders")
	Local $sTxtTroopLaunchers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtTroopLaunchers", "Troop Launchers")
	Local $sTxtSkyWagons = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSkyWagons", "Sky Wagons")
	Local $sTxtThrowers = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtThrowers", "Throwers")
	Local $sTxtMeteorGolems = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtMeteorGolems", "Meteor Golems")
	Local $sTxtDruids = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtDruids", "Druids")
	Local $sTxtFurnaces = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtFurnaces", "Furnaces")
	Local $sTxtRuinWitches = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtRuinWitches", "Ruin Witches")
	Local $sTxtSuperYetis = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtSuperYetis", "Super Yetis")
	Local $sTxtReviveSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtReviveSpells", "Revive")
	Local $sTxtTotemSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtTotemSpells", "Totem")
	Local $sTxtIceBlockSpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtIceBlockSpells", "Ice Block")
	Local $sTxtAngrySpells = GetTranslatedFileIni("MBR Global GUI Design Names Spells", "TxtAngrySpells", "Angry")

	Local $x = $xStart
	Local $y = $yStart - 15
	Local $Offx = 33
	; icon grid: one category (drop down below) shown at a time, 13 icons per row
	; Troops
	Local $aCat0[49][2]
	$x = 0
	$y = 5
		$g_ahLblDonateTroop[$eTroopBarbarian] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopBarbarian] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBarbarian, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[0][0] = False
		$aCat0[0][1] = $eTroopBarbarian
	$x = 33
	$y = 5
		$g_ahLblDonateTroop[$eTroopArcher] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopArcher] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnArcher, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[1][0] = False
		$aCat0[1][1] = $eTroopArcher
	$x = 66
	$y = 5
		$g_ahLblDonateTroop[$eTroopGiant] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopGiant] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnGiant, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[2][0] = False
		$aCat0[2][1] = $eTroopGiant
	$x = 99
	$y = 5
		$g_ahLblDonateTroop[$eTroopGoblin] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopGoblin] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnGoblin, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[3][0] = False
		$aCat0[3][1] = $eTroopGoblin
	$x = 132
	$y = 5
		$g_ahLblDonateTroop[$eTroopWallBreaker] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopWallBreaker] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnWallBreaker, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[4][0] = False
		$aCat0[4][1] = $eTroopWallBreaker
	$x = 165
	$y = 5
		$g_ahLblDonateTroop[$eTroopBalloon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopBalloon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBalloon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[5][0] = False
		$aCat0[5][1] = $eTroopBalloon
	$x = 198
	$y = 5
		$g_ahLblDonateTroop[$eTroopWizard] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopWizard] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnWizard, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[6][0] = False
		$aCat0[6][1] = $eTroopWizard
	$x = 231
	$y = 5
		$g_ahLblDonateTroop[$eTroopHealer] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopHealer] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnHealer, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[7][0] = False
		$aCat0[7][1] = $eTroopHealer
	$x = 264
	$y = 5
		$g_ahLblDonateTroop[$eTroopDragon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopDragon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnDragon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[8][0] = False
		$aCat0[8][1] = $eTroopDragon
	$x = 297
	$y = 5
		$g_ahLblDonateTroop[$eTroopPekka] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopPekka] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnPekka, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[9][0] = False
		$aCat0[9][1] = $eTroopPekka
	$x = 330
	$y = 5
		$g_ahLblDonateTroop[$eTroopBabyDragon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopBabyDragon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBabyDragon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[10][0] = False
		$aCat0[10][1] = $eTroopBabyDragon
	$x = 363
	$y = 5
		$g_ahLblDonateTroop[$eTroopMiner] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopMiner] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnMiner, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[11][0] = False
		$aCat0[11][1] = $eTroopMiner
	$x = 396
	$y = 5
		$g_ahLblDonateTroop[$eTroopElectroDragon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopElectroDragon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnElectroDragon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[12][0] = False
		$aCat0[12][1] = $eTroopElectroDragon
	$x = 0
	$y = 38
		$g_ahLblDonateTroop[$eTroopYeti] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopYeti] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnYeti, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[13][0] = False
		$aCat0[13][1] = $eTroopYeti
	$x = 33
	$y = 38
		$g_ahLblDonateTroop[$eTroopDragonRider] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopDragonRider] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnDragonRider, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[14][0] = False
		$aCat0[14][1] = $eTroopDragonRider
	$x = 66
	$y = 38
		$g_ahLblDonateTroop[$eTroopElectroTitan] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopElectroTitan] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnElectroTitan, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[15][0] = False
		$aCat0[15][1] = $eTroopElectroTitan
	$x = 99
	$y = 38
		$g_ahLblDonateTroop[$eTroopRootRider] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopRootRider] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnRootRider, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[16][0] = False
		$aCat0[16][1] = $eTroopRootRider
	$x = 132
	$y = 38
		$g_ahLblDonateTroop[$g_iDonExTroopBase + $eDonExThrower] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$g_iDonExTroopBase + $eDonExThrower] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnThrower, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[17][0] = False
		$aCat0[17][1] = $g_iDonExTroopBase + $eDonExThrower
	$x = 165
	$y = 38
		$g_ahLblDonateTroop[$g_iDonExTroopBase + $eDonExMeteorGolem] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$g_iDonExTroopBase + $eDonExMeteorGolem] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnMeteorGolem, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[18][0] = False
		$aCat0[18][1] = $g_iDonExTroopBase + $eDonExMeteorGolem
	$x = 198
	$y = 38
		$g_ahLblDonateTroop[$eTroopMinion] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopMinion] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnMinion, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[19][0] = False
		$aCat0[19][1] = $eTroopMinion
	$x = 231
	$y = 38
		$g_ahLblDonateTroop[$eTroopHogRider] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopHogRider] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnHogRider, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[20][0] = False
		$aCat0[20][1] = $eTroopHogRider
	$x = 264
	$y = 38
		$g_ahLblDonateTroop[$eTroopValkyrie] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopValkyrie] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnValkyrie, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[21][0] = False
		$aCat0[21][1] = $eTroopValkyrie
	$x = 297
	$y = 38
		$g_ahLblDonateTroop[$eTroopGolem] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopGolem] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnGolem, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[22][0] = False
		$aCat0[22][1] = $eTroopGolem
	$x = 330
	$y = 38
		$g_ahLblDonateTroop[$eTroopWitch] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopWitch] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnWitch, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[23][0] = False
		$aCat0[23][1] = $eTroopWitch
	$x = 363
	$y = 38
		$g_ahLblDonateTroop[$eTroopLavaHound] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopLavaHound] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnLavaHound, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[24][0] = False
		$aCat0[24][1] = $eTroopLavaHound
	$x = 396
	$y = 38
		$g_ahLblDonateTroop[$eTroopBowler] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopBowler] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBowler, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[25][0] = False
		$aCat0[25][1] = $eTroopBowler
	$x = 0
	$y = 71
		$g_ahLblDonateTroop[$eTroopIceGolem] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopIceGolem] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnIceGolem, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[26][0] = False
		$aCat0[26][1] = $eTroopIceGolem
	$x = 33
	$y = 71
		$g_ahLblDonateTroop[$eTroopHeadhunter] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopHeadhunter] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnHeadhunter, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[27][0] = False
		$aCat0[27][1] = $eTroopHeadhunter
	$x = 66
	$y = 71
		$g_ahLblDonateTroop[$eTroopAppWard] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopAppWard] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnAppWard, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[28][0] = False
		$aCat0[28][1] = $eTroopAppWard
	$x = 99
	$y = 71
		$g_ahLblDonateTroop[$g_iDonExTroopBase + $eDonExDruid] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$g_iDonExTroopBase + $eDonExDruid] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnDruid, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[29][0] = False
		$aCat0[29][1] = $g_iDonExTroopBase + $eDonExDruid
	$x = 132
	$y = 71
		$g_ahLblDonateTroop[$g_iDonExTroopBase + $eDonExFurnace] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$g_iDonExTroopBase + $eDonExFurnace] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnFurnace, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[30][0] = False
		$aCat0[30][1] = $g_iDonExTroopBase + $eDonExFurnace
	$x = 165
	$y = 71
		$g_ahLblDonateTroop[$g_iDonExTroopBase + $eDonExRuinWitch] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$g_iDonExTroopBase + $eDonExRuinWitch] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnRuinWitch, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[31][0] = False
		$aCat0[31][1] = $g_iDonExTroopBase + $eDonExRuinWitch
	$x = 198
	$y = 71
		$g_ahLblDonateTroop[$eTroopSuperBarbarian] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperBarbarian] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperBarbarian, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[32][0] = False
		$aCat0[32][1] = $eTroopSuperBarbarian
	$x = 231
	$y = 71
		$g_ahLblDonateTroop[$eTroopSuperArcher] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperArcher] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperArcher, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[33][0] = False
		$aCat0[33][1] = $eTroopSuperArcher
	$x = 264
	$y = 71
		$g_ahLblDonateTroop[$eTroopSuperGiant] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperGiant] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperGiant, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[34][0] = False
		$aCat0[34][1] = $eTroopSuperGiant
	$x = 297
	$y = 71
		$g_ahLblDonateTroop[$eTroopSneakyGoblin] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSneakyGoblin] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSneakyGoblin, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[35][0] = False
		$aCat0[35][1] = $eTroopSneakyGoblin
	$x = 330
	$y = 71
		$g_ahLblDonateTroop[$eTroopSuperWallBreaker] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperWallBreaker] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperWallBreaker, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[36][0] = False
		$aCat0[36][1] = $eTroopSuperWallBreaker
	$x = 363
	$y = 71
		$g_ahLblDonateTroop[$eTroopRocketBalloon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopRocketBalloon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnRocketBalloon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[37][0] = False
		$aCat0[37][1] = $eTroopRocketBalloon
	$x = 396
	$y = 71
		$g_ahLblDonateTroop[$eTroopSuperWizard] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperWizard] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperWizard, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[38][0] = False
		$aCat0[38][1] = $eTroopSuperWizard
	$x = 0
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperDragon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperDragon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperDragon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[39][0] = False
		$aCat0[39][1] = $eTroopSuperDragon
	$x = 33
	$y = 104
		$g_ahLblDonateTroop[$eTroopInfernoDragon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopInfernoDragon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnInfernoDragon, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[40][0] = False
		$aCat0[40][1] = $eTroopInfernoDragon
	$x = 66
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperMiner] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperMiner] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperMiner, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[41][0] = False
		$aCat0[41][1] = $eTroopSuperMiner
	$x = 99
	$y = 104
		$g_ahLblDonateTroop[$g_iDonExTroopBase + $eDonExSuperYeti] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$g_iDonExTroopBase + $eDonExSuperYeti] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperYeti, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[42][0] = False
		$aCat0[42][1] = $g_iDonExTroopBase + $eDonExSuperYeti
	$x = 132
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperMinion] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperMinion] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperMinion, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[43][0] = False
		$aCat0[43][1] = $eTroopSuperMinion
	$x = 165
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperHogRider] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperHogRider] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperHogRider, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[44][0] = False
		$aCat0[44][1] = $eTroopSuperHogRider
	$x = 198
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperValkyrie] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperValkyrie] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperValkyrie, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[45][0] = False
		$aCat0[45][1] = $eTroopSuperValkyrie
	$x = 231
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperWitch] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperWitch] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperWitch, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[46][0] = False
		$aCat0[46][1] = $eTroopSuperWitch
	$x = 264
	$y = 104
		$g_ahLblDonateTroop[$eTroopIceHound] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopIceHound] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnIceHound, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[47][0] = False
		$aCat0[47][1] = $eTroopIceHound
	$x = 297
	$y = 104
		$g_ahLblDonateTroop[$eTroopSuperBowler] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopSuperBowler] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSuperBowler, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat0[48][0] = False
		$aCat0[48][1] = $eTroopSuperBowler
	$g_aDonateCategory[0] = $aCat0
	; Spells
	Local $aCat1[18][2]
	$x = 0
	$y = 5
		$g_ahLblDonateSpell[$eSpellLightning] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellLightning] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnLightSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[0][0] = True
		$aCat1[0][1] = $eSpellLightning
	$x = 33
	$y = 5
		$g_ahLblDonateSpell[$eSpellHeal] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellHeal] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnHealSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[1][0] = True
		$aCat1[1][1] = $eSpellHeal
	$x = 66
	$y = 5
		$g_ahLblDonateSpell[$eSpellRage] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellRage] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnRageSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[2][0] = True
		$aCat1[2][1] = $eSpellRage
	$x = 99
	$y = 5
		$g_ahLblDonateSpell[$eSpellJump] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellJump] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnJumpSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[3][0] = True
		$aCat1[3][1] = $eSpellJump
	$x = 132
	$y = 5
		$g_ahLblDonateSpell[$eSpellFreeze] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellFreeze] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnFreezeSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[4][0] = True
		$aCat1[4][1] = $eSpellFreeze
	$x = 165
	$y = 5
		$g_ahLblDonateSpell[$eSpellClone] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellClone] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnCloneSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[5][0] = True
		$aCat1[5][1] = $eSpellClone
	$x = 198
	$y = 5
		$g_ahLblDonateSpell[$eSpellInvisibility] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellInvisibility] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnInvisibilitySpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[6][0] = True
		$aCat1[6][1] = $eSpellInvisibility
	$x = 231
	$y = 5
		$g_ahLblDonateSpell[$eSpellRecall] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellRecall] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnRecallSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[7][0] = True
		$aCat1[7][1] = $eSpellRecall
	$x = 264
	$y = 5
		$g_ahLblDonateSpell[$g_iDonExSpellBase + $eDonExRevive] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$g_iDonExSpellBase + $eDonExRevive] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnReviveSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[8][0] = True
		$aCat1[8][1] = $g_iDonExSpellBase + $eDonExRevive
	$x = 297
	$y = 5
		$g_ahLblDonateSpell[$g_iDonExSpellBase + $eDonExTotem] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$g_iDonExSpellBase + $eDonExTotem] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnTotemSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[9][0] = True
		$aCat1[9][1] = $g_iDonExSpellBase + $eDonExTotem
	$x = 330
	$y = 5
		$g_ahLblDonateSpell[$eSpellPoison] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellPoison] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnPoisonSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[10][0] = True
		$aCat1[10][1] = $eSpellPoison
	$x = 363
	$y = 5
		$g_ahLblDonateSpell[$eSpellEarthquake] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellEarthquake] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnEarthQuakeSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[11][0] = True
		$aCat1[11][1] = $eSpellEarthquake
	$x = 396
	$y = 5
		$g_ahLblDonateSpell[$eSpellHaste] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellHaste] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnHasteSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[12][0] = True
		$aCat1[12][1] = $eSpellHaste
	$x = 0
	$y = 38
		$g_ahLblDonateSpell[$eSpellSkeleton] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellSkeleton] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSkeletonSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[13][0] = True
		$aCat1[13][1] = $eSpellSkeleton
	$x = 33
	$y = 38
		$g_ahLblDonateSpell[$eSpellBat] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellBat] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBatSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[14][0] = True
		$aCat1[14][1] = $eSpellBat
	$x = 66
	$y = 38
		$g_ahLblDonateSpell[$eSpellOverGrowth] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$eSpellOverGrowth] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnOverGrowthSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[15][0] = True
		$aCat1[15][1] = $eSpellOverGrowth
	$x = 99
	$y = 38
		$g_ahLblDonateSpell[$g_iDonExSpellBase + $eDonExIceBlock] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$g_iDonExSpellBase + $eDonExIceBlock] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnIBSpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[16][0] = True
		$aCat1[16][1] = $g_iDonExSpellBase + $eDonExIceBlock
	$x = 132
	$y = 38
		$g_ahLblDonateSpell[$g_iDonExSpellBase + $eDonExAngry] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateSpell[$g_iDonExSpellBase + $eDonExAngry] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnAngrySpell, 1)
			GUICtrlSetOnEvent(-1, "btnDonateSpell")
		$aCat1[17][0] = True
		$aCat1[17][1] = $g_iDonExSpellBase + $eDonExAngry
	$g_aDonateCategory[1] = $aCat1
	; Sieges
	Local $aCat2[9][2]
	$x = 0
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeWallWrecker] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeWallWrecker] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnWallW, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[0][0] = False
		$aCat2[0][1] = $eTroopCount + $eSiegeWallWrecker
	$x = 33
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeBattleBlimp] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeBattleBlimp] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBattleB, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[1][0] = False
		$aCat2[1][1] = $eTroopCount + $eSiegeBattleBlimp
	$x = 66
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeStoneSlammer] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeStoneSlammer] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnStoneS, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[2][0] = False
		$aCat2[2][1] = $eTroopCount + $eSiegeStoneSlammer
	$x = 99
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeBarracks] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeBarracks] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSiegeB, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[3][0] = False
		$aCat2[3][1] = $eTroopCount + $eSiegeBarracks
	$x = 132
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeLogLauncher] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeLogLauncher] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnLogL, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[4][0] = False
		$aCat2[4][1] = $eTroopCount + $eSiegeLogLauncher
	$x = 165
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeFlameFlinger] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeFlameFlinger] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnFlameF, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[5][0] = False
		$aCat2[5][1] = $eTroopCount + $eSiegeFlameFlinger
	$x = 198
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeBattleDrill] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeBattleDrill] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnBattleD, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[6][0] = False
		$aCat2[6][1] = $eTroopCount + $eSiegeBattleDrill
	$x = 231
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeTroopLauncher] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeTroopLauncher] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnTroopL, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[7][0] = False
		$aCat2[7][1] = $eTroopCount + $eSiegeTroopLauncher
	$x = 264
	$y = 5
		$g_ahLblDonateTroop[$eTroopCount + $eSiegeSkyWagon] = GUICtrlCreateLabel("", $x, $y - 2, $Offx + 2, $Offx + 2)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahBtnDonateTroop[$eTroopCount + $eSiegeSkyWagon] = GUICtrlCreateButton("", $x + 2, $y, $Offx - 2, $Offx - 2, $BS_ICON)
			_GUICtrlSetImage(-1, $g_sLibIconPath, $eIcnSkyW, 1)
			GUICtrlSetOnEvent(-1, "btnDonateTroop")
		$aCat2[8][0] = False
		$aCat2[8][1] = $eTroopCount + $eSiegeSkyWagon
	$g_aDonateCategory[2] = $aCat2

	; check all / none and category drop down, right side above the troop panel
	Local Const $iDonateControlsGap = 2, $iDonateCmbW = 74, $iDonateAllW = 32, $iDonateResetW = 40
	Local Const $iDonateControlsX = $xStart + 410 - $iDonateCmbW - $iDonateControlsGap - $iDonateAllW - $iDonateControlsGap - $iDonateResetW
	Local Const $iDonateControlsY = $yStart + 225 - 20 - 24 ; right above the panel
	$g_hBtnAllSelected = GUICtrlCreateButton("All", $iDonateControlsX, $iDonateControlsY, $iDonateAllW, 22)
		_GUICtrlSetTip(-1, "Donate every troop, spell and siege")
		GUICtrlSetOnEvent(-1, "BtnAllSelected")
	$g_hBtnResetSelected = GUICtrlCreateButton("Reset", $iDonateControlsX + $iDonateAllW + $iDonateControlsGap, $iDonateControlsY, $iDonateResetW, 22)
		_GUICtrlSetTip(-1, "Donate nothing (uncheck all)")
		GUICtrlSetOnEvent(-1, "BtnResetSelected")
	$g_hCmbDonateCategory = GUICtrlCreateCombo("", $iDonateControlsX + $iDonateAllW + $iDonateControlsGap + $iDonateResetW + $iDonateControlsGap, $iDonateControlsY, $iDonateCmbW, 22, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		GUICtrlSetData(-1, "Troops|Spells|Sieges", "Troops")
		_GUICtrlSetTip(-1, "Show only this donation group")
		GUICtrlSetOnEvent(-1, "cmbDonateCategory")
	cmbDonateCategory()

	Local $Offy = $yStart + 225 ; every troop / spell / siege panel: All / Reset / drop down above it, Extra Alphabet below
	$x = $xStart
	$y = $yStart + 185
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "LblExtraAlphabets", "Extra Alphabet Recognitions:"), $x - 15, $y + 153, -1, -1)
		$g_hChkExtraAlphabets = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraAlphabets", "Cyrillic"), $x + 127 , $y + 149, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraAlphabets_Info_01", "Check this to enable the Cyrillic Alphabet."))
		$g_hChkExtraChinese = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraChinese", "Chinese"), $x + 191, $y + 149, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraChinese_Info_01", "Check this to enable the Chinese Alphabet."))
		$g_hChkExtraKorean = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraKorean", "Korean"), $x + 265, $y + 149, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraKorean_Info_01", "Check this to enable the Korean Alphabet."))
		$g_hChkExtraPersian = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraPersian", "Persian"), $x + 340, $y + 149, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "ChkExtraPersian_Info_01", "Check this to enable the Persian Alphabet."))

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopBarbarian] = GUICtrlCreateGroup($sTxtBarbarians, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonBarbarian, $x + 215, $y, 64, 64, $BS_ICON)
		$g_ahChkDonateTroop[$eTroopBarbarian] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBarbarians, $x + 285, $y, -1, -1)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBarbarians & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBarbarians & ":", $x - 5, $y + 5, -1, -1)
		$g_ahTxtDonateTroop[$eTroopBarbarian] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_01", "barbarians\r\nbarb")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBarbarians)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopArcher] = GUICtrlCreateGroup($sTxtArchers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonArcher, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopArcher] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtArchers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtArchers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtArchers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopArcher] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_02", "archers\r\narch")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtArchers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopGiant] = GUICtrlCreateGroup($sTxtGiants, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonGiant, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopGiant] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtGiants, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtGiants & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtGiants & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopGiant] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_03", "giants\r\ngiant\r\nany\r\nreinforcement")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtGiants)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopGoblin] = GUICtrlCreateGroup($sTxtGoblins, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonGoblin, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopGoblin] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtGoblins, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtGoblins & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtGoblins & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopGoblin] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_04", "goblins\r\ngoblin")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtGoblins)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopWallBreaker] = GUICtrlCreateGroup($sTxtWallBreakers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonWallBreaker, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopWallBreaker] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtWallBreakers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtWallBreakers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtWallBreakers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopWallBreaker] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_05", "wall breakers\r\nbreaker")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtWallBreakers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopBalloon] = GUICtrlCreateGroup($sTxtBalloons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonBalloon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopBalloon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBalloons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBalloons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBalloons & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopBalloon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_06", "balloons\r\nballoon")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBalloons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopWizard] = GUICtrlCreateGroup($sTxtWizards, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonWizard, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopWizard] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtWizards, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtWizards & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtWizards & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopWizard] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_07", "wizards\r\nwizard\r\nwiz")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtWizards)
		GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopHealer] = GUICtrlCreateGroup($sTxtHealers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonHealer, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopHealer] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtHealers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtHealers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtHealers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopHealer] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_08", "healer")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtHealers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopDragon] = GUICtrlCreateGroup($sTxtDragons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonDragon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopDragon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtDragons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtDragons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtDragons & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopDragon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_09", "dragon")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtDragons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopPekka] = GUICtrlCreateGroup($sTxtPekkas, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonPekka, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopPekka] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtPekkas, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtPekkas & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtPekkas & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopPekka] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_10", "PEKKA\r\npekka")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtPekkas)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopBabyDragon] = GUICtrlCreateGroup($sTxtBabyDragons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonBabyDragon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopBabyDragon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBabyDragons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBabyDragons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBabyDragons & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopBabyDragon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_11", "baby dragon\r\nbaby")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBabyDragons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopMiner] = GUICtrlCreateGroup($sTxtMiners, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonMiner, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopMiner] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtMiners, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtMiners & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtMiners & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopMiner] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_12", "miner|mine")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtMiners)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopElectroDragon] = GUICtrlCreateGroup($sTxtElectroDragons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElectroDragon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopElectroDragon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtElectroDragons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtElectroDragons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtElectroDragons & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopElectroDragon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_31", "electro dragon\r\nelectrodrag\r\nedrag")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtElectroDragons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopYeti] = GUICtrlCreateGroup($sTxtYetis, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnYeti, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopYeti] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtYetis, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtYetis & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtYetis & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopYeti] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_37", "Yeti\r\nYetis")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtYetis)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopDragonRider] = GUICtrlCreateGroup($sTxtDragonRiders, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDragonRider, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopDragonRider] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtDragonRiders, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtDragonRiders & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtDragonRiders & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopDragonRider] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_54", "Dragon Rider\r\nDragon Riders")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtDragonRiders)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopElectroTitan] = GUICtrlCreateGroup($sTxtElectroTitans, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElectroTitan, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopElectroTitan] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtElectroTitans, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtElectroTitans & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtElectroTitans & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopElectroTitan] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_61", "Electro Titan\r\nElectro Titans")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtElectroTitans)
	GUICtrlCreateGroup("", -99, -99, 1, 1)


	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopMinion] = GUICtrlCreateGroup($sTxtMinions, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonMinion, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopMinion] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtMinions, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtMinions & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtMinions & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopMinion] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_18", "minions\r\nminion")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtMinions)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopHogRider] = GUICtrlCreateGroup($sTxtHogRiders, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonHogRider, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopHogRider] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtHogRiders, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtHogRiders & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtHogRiders & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopHogRider] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_19", "hogriders\r\nhogs\r\nhog")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtHogRiders)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopValkyrie] = GUICtrlCreateGroup($sTxtValkyries, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonValkyrie, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopValkyrie] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtValkyries, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtValkyries & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtValkyries & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopValkyrie] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_20", "valkyries\r\nvalkyrie\r\nvalk")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtValkyries)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopGolem] = GUICtrlCreateGroup($sTxtGolems, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonGolem, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopGolem] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtGolems, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtGolems & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtGolems & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopGolem] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_21", "golem")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtGolems)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopWitch] = GUICtrlCreateGroup($sTxtWitches, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonWitch, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopWitch] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtWitches, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtWitches & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtWitches & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopWitch] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_22", "witches\r\nwitch")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtWitches)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopLavaHound] = GUICtrlCreateGroup($sTxtLavaHounds, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonLavaHound, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopLavaHound] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtLavaHounds, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtLavaHounds & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtLavaHounds & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopLavaHound] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_23", "lavahound\r\nlava\r\nhound")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtLavaHounds)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopBowler] = GUICtrlCreateGroup($sTxtBowlers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonBowler, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopBowler] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBowlers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBowlers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBowlers & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopBowler] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_24", "bowler\r\nbowlers\r\nbowl")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBowlers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopIceGolem] = GUICtrlCreateGroup($sTxtIceGolems, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnIceGolem, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopIceGolem] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtIceGolems, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtIceGolems & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtIceGolems & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopIceGolem] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_36", "ice golem\r\nice golems")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtIceGolems)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopHeadhunter] = GUICtrlCreateGroup($sTxtHeadhunters, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnHeadhunter, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopHeadhunter] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtHeadhunters, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtHeadhunters & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtHeadhunters & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopHeadhunter] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_39", "headhunter\r\nhunt")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtHeadhunters)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	;Super Troops
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperBarbarian] = GUICtrlCreateGroup($sTxtSuperBarbarians, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperBarbarian, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperBarbarian] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperBarbarians, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperBarbarians & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperBarbarians & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperBarbarian] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_42", "Super Barbarians\r\nSuper Barb")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperBarbarians)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperArcher] = GUICtrlCreateGroup($sTxtSuperArchers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperArcher, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperArcher] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperArchers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperArchers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperArchers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperArcher] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_43", "super archers\r\nsuper arch")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperArchers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperGiant] = GUICtrlCreateGroup($sTxtSuperGiants, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperGiant, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperGiant] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperGiants, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperGiants & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperGiants & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperGiant] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_44", "super giants\r\nsuper giant")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperGiants)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSneakyGoblin] = GUICtrlCreateGroup($sTxtSneakyGoblins, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSneakyGoblin, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSneakyGoblin] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSneakyGoblins, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSneakyGoblins & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSneakyGoblins & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSneakyGoblin] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_45", "SneakyGoblins\r\nSneakyGoblin")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSneakyGoblins)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperWallBreaker] = GUICtrlCreateGroup($sTxtSuperWallBreakers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperWallBreaker, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperWallBreaker] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperWallBreakers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperWallBreakers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperWallBreakers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperWallBreaker] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_46", "super wall breakers\r\nsuper  breaker")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperWallBreakers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopRocketBalloon] = GUICtrlCreateGroup($sTxtRocketBalloons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnRocketBalloon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopRocketBalloon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtRocketBalloons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtRocketBalloons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtRocketBalloons & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopRocketBalloon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_55", "Rocket Balloon\r\nRocket Balloons")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtRocketBalloons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperWizard] = GUICtrlCreateGroup($sTxtSuperWizards, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperWizard, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperWizard] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperWizards, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperWizards & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperWizards & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperWizard] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_47", "SuperWizards\r\nSuperWizard\r\nsuper wiz")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperWizards)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopInfernoDragon] = GUICtrlCreateGroup($sTxtInfernoDragons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnInfernoDragon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopInfernoDragon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtInfernoDragons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtInfernoDragons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtInfernoDragons & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopInfernoDragon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_48", "inferno dragon\r\ninferno baby")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtInfernoDragons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Super Miner
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperMiner] = GUICtrlCreateGroup($sTxtSuperMiners, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperMiner, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperMiner] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperMiners, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperMiners & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperMiners & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperMiner] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_SuperMiner", "superminers\r\nsuperminer\r\nsminer\r\nsmine")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperMiners)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperMinion] = GUICtrlCreateGroup($sTxtSuperMinions, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperMinion, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperMinion] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperMinions, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperMinions & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperMinions & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperMinion] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_49", "SuperMinions\r\nSuperMinion")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperMinions)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperValkyrie] = GUICtrlCreateGroup($sTxtSuperValkyries, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperValkyrie, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperValkyrie] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperValkyries, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperValkyries & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperValkyries & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperValkyrie] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_50", "SuperValkyries\r\nSuperValkyrie\r\nsvalk")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperValkyries)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperWitch] = GUICtrlCreateGroup($sTxtSuperWitches, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperWitch, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperWitch] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperWitches, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperWitches & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperWitches & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperWitch] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_51", "SuperWitches\r\nSuperWitch")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperWitches)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopIceHound] = GUICtrlCreateGroup($sTxtIceHounds, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnIceHound, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopIceHound] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtIceHounds, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtIceHounds & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtIceHounds & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopIceHound] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_52", "IceHound\r\nice")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtIceHounds)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperBowler] = GUICtrlCreateGroup($sTxtSuperBowlers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperBowler, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperBowler] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperBowlers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperBowlers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperBowlers & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperBowler] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_56", "Super Bowler\r\nSuper Bowlers\r\nSBowl")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperBowlers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperDragon] = GUICtrlCreateGroup($sTxtSuperDragons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperDragon, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperDragon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperDragons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperDragons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperDragons & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperDragon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_59", "Super Dragon\r\nSDrag")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperDragons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Spells
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellLightning] = GUICtrlCreateGroup($sTxtLightningSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnLightSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellLightning] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtLightningSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtLightningSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtLightningSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellLightning] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_13", "lightning")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtLightningSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellHeal] = GUICtrlCreateGroup($sTxtHealSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnHealSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellHeal] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtHealSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtHealSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		 GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtHealSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellHeal] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_14", "heal")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtHealSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellRage] = GUICtrlCreateGroup($sTxtRageSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnRageSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellRage] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtRageSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtRageSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtRageSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellRage] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_15", "rage")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtRageSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellJump] = GUICtrlCreateGroup($sTxtJumpSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnJumpSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellJump] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtJumpSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtJumpSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtJumpSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellJump] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_16", "jump")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtJumpSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellFreeze] = GUICtrlCreateGroup($sTxtFreezeSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnFreezeSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellFreeze] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtFreezeSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtFreezeSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtFreezeSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellFreeze] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_17", "freeze")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtFreezeSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellInvisibility] = GUICtrlCreateGroup($sTxtInvisibilitySpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnInvisibilitySpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellInvisibility] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtInvisibilitySpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtInvisibilitySpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtInvisibilitySpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellInvisibility] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_40", "Invisibility")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtInvisibilitySpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Recall Spell
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellRecall] = GUICtrlCreateGroup($sTxtRecallSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnRecallSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellRecall] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtRecallSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtRecallSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtRecallSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellRecall] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_62", "Recall")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtRecallSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellClone] = GUICtrlCreateGroup($sTxtCloneSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnCloneSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellClone] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtCloneSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtCloneSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtCloneSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellClone] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_53", "Clone")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtCloneSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellPoison] = GUICtrlCreateGroup($sTxtPoisonSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonPoisonSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellPoison] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtPoisonSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtPoisonSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtPoisonSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellPoison] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_25", "poison")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtPoisonSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellEarthquake] = GUICtrlCreateGroup($sTxtEarthQuakeSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonEarthQuakeSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellEarthquake] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtEarthQuakeSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtEarthQuakeSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtEarthQuakeSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellEarthquake] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_26", "earthquake\r\nquake")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtEarthQuakeSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellHaste] = GUICtrlCreateGroup($sTxtHasteSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonHasteSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellHaste] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtHasteSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtHasteSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtHasteSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellHaste] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_27", "haste")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtHasteSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellSkeleton] = GUICtrlCreateGroup($sTxtSkeletonSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDonSkeletonSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellSkeleton] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSkeletonSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSkeletonSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSkeletonSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellSkeleton] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_28", "skeleton|skel")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSkeletonSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellBat] = GUICtrlCreateGroup($sTxtBatSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBatSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellBat] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBatSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBatSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBatSpells & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellBat] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_34", "Bat")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBatSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Siege Machines
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeWallWrecker] = GUICtrlCreateGroup($sTxtWallWreckers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnWallW, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeWallWrecker] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtWallWreckers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtWallWreckers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtWallWreckers & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeWallWrecker] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_32", "wall wreckers\r\nsieges\r\nwreckers")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtWallWreckers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeBattleBlimp] = GUICtrlCreateGroup($sTxtBattleBlimps, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBattleB, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeBattleBlimp] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBattleBlimps, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBattleBlimps & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBattleBlimps & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeBattleBlimp] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_33", "battle blimps\r\nsieges\r\nblimps")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBattleBlimps)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeStoneSlammer] = GUICtrlCreateGroup($sTxtStoneSlammers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnStoneS, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeStoneSlammer] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtStoneSlammers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtStoneSlammers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtStoneSlammers & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeStoneSlammer] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_35", "stone slammers\r\nsieges\r\nslammers")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtStoneSlammers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeBarracks] = GUICtrlCreateGroup($sTxtSiegeBarracks, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSiegeB, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeBarracks] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSiegeBarracks, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSiegeBarracks & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSiegeBarracks & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeBarracks] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_38", "Siege Barracks\r\nsieges\r\nbarracks")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSiegeBarracks)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeLogLauncher] = GUICtrlCreateGroup($sTxtLogLaunchers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnLogL, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeLogLauncher] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtLogLaunchers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtLogLaunchers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtLogLaunchers & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeLogLauncher] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_41", "Log Launcher\r\nsieges\r\nlauncher")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtLogLaunchers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeFlameFlinger] = GUICtrlCreateGroup($sTxtFlameFlingers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnFlameF, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeFlameFlinger] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtFlameFlingers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtFlameFlingers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtFlameFlingers & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeFlameFlinger] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_60", "Flame Flinger\r\nsieges\r\nFlame")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtFlameFlingers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Battle Drill
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeBattleDrill] = GUICtrlCreateGroup($sTxtBattleDrills, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBattleD, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeBattleDrill] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtBattleDrills, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtBattleDrills & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtBattleDrills & ":" , $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeBattleDrill] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_63", "Battle Drill\r\nsieges\r\nDrill")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtBattleDrills)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopRootRider] = GUICtrlCreateGroup($sTxtRootRiders, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnRootRider, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopRootRider] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtRootRiders, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtRootRiders & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtRootRiders & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopRootRider] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_70", "Root Rider\r\nroot")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtRootRiders)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopAppWard] = GUICtrlCreateGroup($sTxtAppWards, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnAppWard, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopAppWard] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtAppWards, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtAppWards & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtAppWards & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopAppWard] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_71", "Apprentice Warden\r\nwarden")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtAppWards)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopSuperHogRider] = GUICtrlCreateGroup($sTxtSuperHogRiders, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperHogRider, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopSuperHogRider] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperHogRiders, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperHogRiders & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperHogRiders & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopSuperHogRider] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_72", "Super Hog Rider\r\nshog")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperHogRiders)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$eSpellOverGrowth] = GUICtrlCreateGroup($sTxtOvergrowthSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnOverGrowthSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$eSpellOverGrowth] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtOvergrowthSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtOvergrowthSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtOvergrowthSpells & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$eSpellOverGrowth] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateSpell_Item_20", "overgrowth")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtOvergrowthSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeTroopLauncher] = GUICtrlCreateGroup($sTxtTroopLaunchers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTroopL, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeTroopLauncher] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtTroopLaunchers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtTroopLaunchers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtTroopLaunchers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeTroopLauncher] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_73", "Troop Launcher\r\nsieges\r\nLauncher")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtTroopLaunchers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$eTroopCount + $eSiegeSkyWagon] = GUICtrlCreateGroup($sTxtSkyWagons, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSkyW, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$eTroopCount + $eSiegeSkyWagon] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSkyWagons, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSkyWagons & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSkyWagons & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$eTroopCount + $eSiegeSkyWagon] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_74", "Sky Wagon\r\nsieges\r\nWagon")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSkyWagons)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$g_iDonExTroopBase + $eDonExThrower] = GUICtrlCreateGroup($sTxtThrowers, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnThrower, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$g_iDonExTroopBase + $eDonExThrower] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtThrowers, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtThrowers & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtThrowers & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$g_iDonExTroopBase + $eDonExThrower] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_75", "thrower")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtThrowers)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$g_iDonExTroopBase + $eDonExMeteorGolem] = GUICtrlCreateGroup($sTxtMeteorGolems, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnMeteorGolem, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$g_iDonExTroopBase + $eDonExMeteorGolem] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtMeteorGolems, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtMeteorGolems & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtMeteorGolems & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$g_iDonExTroopBase + $eDonExMeteorGolem] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_76", "meteor golem\r\nmeteor")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtMeteorGolems)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$g_iDonExTroopBase + $eDonExDruid] = GUICtrlCreateGroup($sTxtDruids, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDruid, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$g_iDonExTroopBase + $eDonExDruid] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtDruids, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtDruids & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtDruids & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$g_iDonExTroopBase + $eDonExDruid] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_77", "druid")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtDruids)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$g_iDonExTroopBase + $eDonExFurnace] = GUICtrlCreateGroup($sTxtFurnaces, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnFurnace, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$g_iDonExTroopBase + $eDonExFurnace] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtFurnaces, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtFurnaces & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtFurnaces & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$g_iDonExTroopBase + $eDonExFurnace] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_78", "furnace")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtFurnaces)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$g_iDonExTroopBase + $eDonExRuinWitch] = GUICtrlCreateGroup($sTxtRuinWitches, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnRuinWitch, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$g_iDonExTroopBase + $eDonExRuinWitch] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtRuinWitches, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtRuinWitches & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtRuinWitches & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$g_iDonExTroopBase + $eDonExRuinWitch] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_79", "ruin witch\r\nruin")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtRuinWitches)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateTroop[$g_iDonExTroopBase + $eDonExSuperYeti] = GUICtrlCreateGroup($sTxtSuperYetis, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnSuperYeti, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateTroop[$g_iDonExTroopBase + $eDonExSuperYeti] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtSuperYetis, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtSuperYetis & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateTroop")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtSuperYetis & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateTroop[$g_iDonExTroopBase + $eDonExSuperYeti] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateTroop_Item_80", "super yeti\r\nsyeti")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtSuperYetis)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$g_iDonExSpellBase + $eDonExRevive] = GUICtrlCreateGroup($sTxtReviveSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnReviveSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$g_iDonExSpellBase + $eDonExRevive] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtReviveSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtReviveSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtReviveSpells & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$g_iDonExSpellBase + $eDonExRevive] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateSpell_Item_21", "revive")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtReviveSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$g_iDonExSpellBase + $eDonExTotem] = GUICtrlCreateGroup($sTxtTotemSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnTotemSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$g_iDonExSpellBase + $eDonExTotem] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtTotemSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtTotemSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtTotemSpells & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$g_iDonExSpellBase + $eDonExTotem] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateSpell_Item_22", "totem")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtTotemSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$g_iDonExSpellBase + $eDonExIceBlock] = GUICtrlCreateGroup($sTxtIceBlockSpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnIBSpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$g_iDonExSpellBase + $eDonExIceBlock] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtIceBlockSpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtIceBlockSpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtIceBlockSpells & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$g_iDonExSpellBase + $eDonExIceBlock] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateSpell_Item_23", "ice block")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtIceBlockSpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = $xStart
	$y = $Offy
	$g_ahGrpDonateSpell[$g_iDonExSpellBase + $eDonExAngry] = GUICtrlCreateGroup($sTxtAngrySpells, $x - 20, $y - 20, $g_iSizeWGrpTab3, 125)
	$x -= 10
	$y -= 4
		GUICtrlSetState(-1, $GUI_HIDE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnAngrySpell, $x + 215, $y, 64, 64, $BS_ICON)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahChkDonateSpell[$g_iDonExSpellBase + $eDonExAngry] = GUICtrlCreateCheckbox($sTxtDonate & " " & $sTxtAngrySpells, $x + 285, $y, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
			_GUICtrlSetTip(-1, $sTxtDonateTip & " " & $sTxtAngrySpells & " " & $sTxtDonateTipTroop)
			GUICtrlSetOnEvent(-1, "chkDonateSpell")
		GUICtrlCreateLabel($sTxtKeywords & " " & $sTxtAngrySpells & ":", $x - 5, $y + 5, -1, -1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_ahTxtDonateSpell[$g_iDonExSpellBase + $eDonExAngry] = GUICtrlCreateEdit("", $x - 5, $y + 20, 205, 80, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Village - Donate", "TxtDonateSpell_Item_24", "angry")))
			_GUICtrlSetTip(-1, $sTxtKeywords & " " & $sTxtAngrySpells)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>CreateDonateSubTab
#EndRegion

