; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Train Army" tab under the "Attack Plan" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: GKevinOD (2014)
; Modified ......: DkEd, Hervidero (2015), Boju (11-2016), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_TRAINARMY = 0
Global $g_hGUI_TRAINARMY_TAB = 0, $g_hGUI_TRAINARMY_TAB_ITEM1 = 0, $g_hGUI_TRAINARMY_TAB_ITEM2 = 0, $g_hGUI_TRAINARMY_TAB_ITEM3 = 0, $g_hGUI_TRAINARMY_TAB_ITEM4 = 0

; TrainArmy childs
Global $g_hGUI_TRAINARMY_ARMY = 0, $g_hGUI_TRAINARMY_BOOST = 0, $g_hGUI_TRAINARMY_TRAINORDER = 0, $g_hGUI_TRAINARMY_OPTIONS = 0
Global $g_hGUI_TRAINARMY_ARMY_TAB = 0, $g_hGUI_TRAINARMY_ARMY_TAB_ITEM1 = 0, $g_hGUI_TRAINARMY_ARMY_TAB_ITEM2 = 0
Global $g_hGUI_TRAINARMY_ORDER_TAB = 0, $g_hGUI_TRAINARMY_ORDER_TAB_ITEM1 = 0, $g_hGUI_TRAINARMY_ORDER_TAB_ITEM2 = 0

; Custom train tab & Quick train tab
Global $g_hGUI_TRAINTYPE = 0
Global $g_hGUI_TRAINTYPE_TAB = 0, $g_hGUI_TRAINTYPE_TAB_ITEM1 = 0, $g_hGUI_TRAINTYPE_TAB_ITEM2 = 0, $g_hGUI_TRAINTYPE_TAB_ITEM3 = 0, $g_hGUI_TRAINTYPE_TAB_ITEM4 = 0
Global $g_hBtnElixirTroops = 0, $g_hBtnDarkElixirTroops = 0, $g_hBtnSuperTroops = 0, $g_hBtnSpells = 0, $g_hBtnSieges = 0, $g_hBtnEventTroops = 0

; Troops/Spells sub-tab
Global $g_hRadCustomTrain = 0, $g_hRadQuickTrain = 0, $g_ahChkArmy[3] = [0, 0, 0]
Global $g_ahTxtTrainArmyTroopCount[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_ahTxtTrainArmySpellCount[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_ahTxtTrainArmySiegeCount[$eSiegeMachineCount] = [0, 0, 0, 0, 0, 0]
Global $g_hTxtFullTroop = 0, $g_hTxtTotalCampForced = 0, $g_hCmbDBUseSavedArmy = 0
Global $g_hChkDoubleTrain = 0, $g_hChkPreciseArmy = 0

Global $g_hGrpTrainTroops = 0
Global $g_ahPicTrainArmyTroop[$eTroopCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_ahPicTrainArmyTroopTmp[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_ahLblTrainArmyTroopTmp[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_ahPicTrainArmySpell[$eSpellCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_ahPicTrainArmySpellTmp[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_ahLblTrainArmySpellTmp[7] = [0, 0, 0, 0, 0, 0, 0]
Global $g_ahPicTrainArmySiege[$eSiegeMachineCount] = [0, 0, 0, 0, 0, 0]
Global $g_ahPicTrainArmySiegeTmp[3] = [0, 0, 0]
Global $g_ahLblTrainArmySiegeTmp[3] = [0, 0, 0]
Global $g_hLblTotalTimeCamp = 0, $g_hLblElixirCostCamp = 0, $g_hLblDarkCostCamp = 0, $g_hCalTotalTroops = 0, $g_hCalTotalSpells =0, $g_hLblCountTotalSpells = 0, $g_hLblCountTotal = 0, _
		$g_hTxtTotalCountSpell = 0, $g_hLblTotalTimeSpell = 0, $g_hLblElixirCostSpell = 0, $g_hLblDarkCostSpell = 0, _
		$g_hLblTotalTimeSiege = 0, $g_hLblCountTotalSiege = 0, $g_hLblGoldCostSiege = 0

; Boost sub-tab
Global $g_hCmbBoostBarracks = 0, $g_hCmbBoostSpellFactory = 0, $g_hCmbBoostWorkshop = 0, $g_hCmbBoostBarbarianKing = 0, $g_hCmbBoostArcherQueen = 0, $g_hCmbBoostWarden = 0, $g_hCmbBoostChampion = 0, $g_hCmbBoostEverything = 0
Global $g_hCmbBoostMaxSuperTroops = 0
Global $g_hLblBoosthour = 0, $g_ahLblBoosthoursE = 0
Global $g_hLblBoosthours[12] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hChkBoostBarracksHours[24] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], $g_hChkBoostBarracksHoursE1 = 0, $g_hChkBoostBarracksHoursE2 = 0
Global $g_hChkSuperTroops = 0, $g_hChkSkipBoostSuperTroopOnHalt = 0, $g_hChkUsePotion = 0, $g_ahLblSuperTroops[$iMaxSupersTroop] = [0, 0], $g_ahCmbSuperTroops[$iMaxSupersTroop] = [0, 0], $g_ahPicSuperTroops[$iMaxSupersTroop] = [0, 0]

; Train Order sub-tab
Global $g_hChkCustomTrainOrderEnable = 0
Global $g_ahCmbTroopOrder[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $g_ahImgTroopOrder[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hBtnTroopOrderSet = 0, $g_ahImgTroopOrderSet = 0
Global $g_hBtnRemoveTroops
Global $g_hChkCustomBrewOrderEnable = 0
Global $g_ahCmbSpellsOrder[6] = [0, 0, 0, 0, 0, 0]
Global $g_ahImgSpellsOrder[6] = [0, 0, 0, 0, 0, 0]
Global $g_hBtnSpellsOrderSet = 0, $g_ahImgSpellsOrderSet = 0
Global $g_hBtnRemoveSpells

; Options sub-tab
Global $g_hSldTrainITDelay = 0, $g_hChkTrainAddRandomDelayEnable = 0, $g_hTxtAddRandomDelayMin = 0, _
		$g_hTxtAddRandomDelayMax = 0

Global $g_hLblTrainITDelay = 0, $g_hLblTrainITDelayTime = 0, _
		$g_hLblAddDelayIdlePhaseBetween = 0, $g_hLblAddDelayIdlePhaseSec = 0

Func CreateAttackTroops()
	$g_hGUI_TRAINARMY = _GUICreate("", $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_ATTACK)
	GUISetBkColor($COLOR_WHITE, $g_hGUI_TRAINARMY)

	;creating subchilds first!
	CreateTrainArmy()
	CreateTrainOptions()

	GUISwitch($g_hGUI_TRAINARMY)
	$g_hGUI_TRAINARMY_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
	$g_hGUI_TRAINTYPE_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_03_STab_01_STab_01", "Army"))
	$g_hGUI_TRAINTYPE_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_03_STab_01_STab_04", "Options"))

	GUICtrlCreateTabItem("")

EndFunc   ;==>CreateAttackTroops

Func CreateTrainArmy()

	$g_hGUI_TRAINARMY_ARMY = _GUICreate("", $g_iSizeWGrpTab3, $g_iSizeHGrpTab3, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_TRAINARMY)
	GUISetBkColor($COLOR_WHITE, $g_hGUI_TRAINARMY_ARMY)

	; army saved in the game (My Army / Saved Recipes) used for Dead Base and Active Base attacks
	Local $x = 25, $y = 20
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "Group_SavedArmy", "Army"), $x - 20, $y - 20, 415, 50)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "Saved Army", "Use Saved Army :"), $x - 10, $y + 6, 90, -1)
		$g_hCmbDBUseSavedArmy = GUICtrlCreateCombo("", $x + 85, $y + 3, 90, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "cmbDBUseSavedArmy", "Use Army Saved, bot will pick army saved composition before Search DB"))
		GUICtrlSetData(-1, "Army 1|Army 2|Army 3|Army 4", "Army 2")
		GUICtrlSetOnEvent(-1, "cmbDBUseArmy")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	;Local $x = 12
	;Local $y = 5
	;
	;_GUICtrlCreateIcon($g_sLibIconPath, $eIcnResetButton, $x - 12, $y - 6, 28, 28)
	;GUICtrlSetOnEvent(-1, "Removecamp")
	;
	;;$g_hChkTotalCampForced = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "ChkTotalCampForced", "Force Army Camp") & ":", $x + 25, $y, -1, -1)
	;;GUICtrlSetState(-1, $GUI_CHECKED)
	;;GUICtrlSetOnEvent(-1, "chkTotalCampForced")
	;;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "ChkTotalCampForced_Info_01", "If not detected set army camp values (instead ask)"))
	;GUICtrlCreateLabel("Your ArmyCamp Size :", $x + 25, $y + 3, -1, -1)
	;$g_hTxtTotalCampForced = GUICtrlCreateInput("220", $x + 134, $y + 3, 30, 17, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	;GUICtrlSetOnEvent(-1, "SetComboTroopComp")
	;GUICtrlSetLimit(-1, 3)
	;
	;GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "LblFullTroop", "'Full' Camp") & " " & ChrW(8805), $x + 170, $y + 5, 70, 17, $SS_RIGHT)
	;$g_hTxtFullTroop = GUICtrlCreateInput("100", $x + 242, $y + 3, 30, 17, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	;GUICtrlSetOnEvent(-1, "SetComboTroopComp")
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "TxtFullTroop_Info_01", "Army camps are 'Full' when reaching this %, then start attack."))
	;GUICtrlSetLimit(-1, 3)
	;GUICtrlCreateLabel("%", $x + 273, $y + 5, -1, 17)
	;
	;GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "SpellCapacity", "Spell Capacity") & ":", $x + 285, $y + 5, 90, 17, $SS_RIGHT)
	;$g_hTxtTotalCountSpell = GUICtrlCreateCombo("", $x + 380, $y + 1, 36, 16, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	;_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Troops", "TxtTotalCountSpell_Info_01", "Enter the No. of Spells Capacity."))
	;GUICtrlSetData(-1, "0|2|4|6|7|8|9|10|11", "0")
	;
	;CreateCustomTrainSubTab()
	;
EndFunc   ;==>CreateTrainArmy
	
Func CreateTrainOptions()

	$g_hGUI_TRAINARMY_OPTIONS = _GUICreate("", $g_iSizeWGrpTab3, $g_iSizeHGrpTab3, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_TRAINARMY)
	GUISetBkColor($COLOR_WHITE, $g_hGUI_TRAINARMY_OPTIONS)

	; Training Idle Time (close while training / healing) removed Oct 2026: no training or healing time in the game anymore
	Local $sTxtTip = ""
	Local $T = "MBR GUI Design Child Attack - Troops_Options"
	Local $x = 25, $y = 20
	GUICtrlCreateGroup(GetTranslatedFileIni($T, "Group_03", "Training Add Random Delay"), $x - 20, $y - 20, 205, 75)
	$g_hChkTrainAddRandomDelayEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkTrainAddRandomDelayEnable", "Add Random Delay"), $x + 18, $y + 4, 130, -1)
	$sTxtTip = GetTranslatedFileIni($T, "ChkTrainAddRandomDelayEnable_Info_01", "Add random delay between two calls of train army.") & @CRLF & _
			GetTranslatedFileIni($T, "ChkTrainAddRandomDelayEnable_Info_02", "This option reduces the calls to the training window  humanizing the bot spacing calls each time with a causal interval chosen between the minimum and maximum values indicated below.")
	GUICtrlSetState(-1, $GUI_UNCHECKED)
	_GUICtrlSetTip(-1, $sTxtTip)
	GUICtrlSetOnEvent(-1, "chkAddDelayIdlePhaseEnable")
	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDelay, $x - 13, $y + 2, 24, 24)
	_GUICtrlSetTip(-1, $sTxtTip)
	$g_hLblAddDelayIdlePhaseBetween = GUICtrlCreateLabel(GetTranslatedFileIni($T, "LblAddDelayIdlePhaseBetween", "Between"), $x + 18, $y + 32, 50, -1)
	$g_hTxtAddRandomDelayMin = GUICtrlCreateInput($g_iTrainAddRandomDelayMin, $x + 68, $y + 30, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	GUICtrlSetLimit(-1, 999)
	GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Search", "TxtWaitForCastleSpell", "And"), $x + 102, $y + 32, 22, -1)
	$g_hTxtAddRandomDelayMax = GUICtrlCreateInput($g_iTrainAddRandomDelayMax, $x + 126, $y + 30, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	GUICtrlSetLimit(-1, 999)
	$g_hLblAddDelayIdlePhaseSec = GUICtrlCreateLabel(GetTranslatedFileIni("MBR Global GUI Design", "sec.", "sec."), $x + 160, $y + 32, 20, -1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = 235
	GUICtrlCreateGroup(GetTranslatedFileIni($T, "Group_02", "Train Click Timing"), $x - 20, $y - 20, 205, 75)
	$g_hLblTrainITDelay = GUICtrlCreateLabel(GetTranslatedFileIni($T, "LblTrainITDelay", "delay"), $x - 10, $y + 8, 37, -1)
	$sTxtTip = GetTranslatedFileIni($T, "LblTrainITDelay_Info_01", "Increase the delay if your PC is slow or to create human like training click speed")
	_GUICtrlSetTip(-1, $sTxtTip)
	$g_hLblTrainITDelayTime = GUICtrlCreateLabel("100 ms", $x - 10, $y + 25, 45, -1)
	_GUICtrlSetTip(-1, $sTxtTip)
	$g_hSldTrainITDelay = GUICtrlCreateSlider($x + 38, $y + 8, 140, 25, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS))
	_GUICtrlSetTip(-1, $sTxtTip)
	_GUICtrlSlider_SetTipSide(-1, $TBTS_BOTTOM)
	_GUICtrlSlider_SetTicFreq(-100, 100)
	GUICtrlSetLimit(-1, 500, 1) ; change max/min value
	GUICtrlSetData(-1, 100) ; default value
	GUICtrlSetBkColor(-1, $COLOR_WHITE)
	GUICtrlSetOnEvent(-1, "sldTrainITDelay")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Boost Super Troops (moved from the removed Boost tab), full width
	Local $TB = "MBR GUI Design Child Attack - Troops_Boost"
	$x = 25
	$y = 105
	GUICtrlCreateGroup(GetTranslatedFileIni($TB, "Group_05", "Boost Super Troops"), $x - 20, $y - 20, 415, 95)
	$g_hChkSuperTroops = GUICtrlCreateCheckbox(GetTranslatedFileIni($TB, "ChkSuperTroops", "Enable Super Troops"), $x - 12, $y + 2, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSuperTroops")
	$g_hChkSkipBoostSuperTroopOnHalt = GUICtrlCreateCheckbox(GetTranslatedFileIni($TB, "ChkSkipBoostSuperTroopOnHalt", "Skip Boost on Halt"), $x + 188, $y - 6, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSuperTroops")
		_GUICtrlSetTip(-1, GetTranslatedFileIni($TB, "Group_05", "Will Skip boost If Enabled Halt Attack and Account got on HaltAttack Mode"))
	$g_hChkUsePotion = GUICtrlCreateCheckbox(GetTranslatedFileIni($TB, "ChkusePotion", "Use Potion if no DE"), $x + 188, $y + 14, -1, -1)
		GUICtrlSetOnEvent(-1, "chkSuperTroops")
	Local $sCmbTroopList = GetTranslatedFileIni("MBR Global GUI Design Names Troops", "TxtListOfSuperTroops", "Disabled|" & _ArrayToString($g_asSuperTroopNames))
	For $i = 0 To $iMaxSupersTroop - 1
		$g_ahLblSuperTroops[$i] = GUICtrlCreateLabel($i + 1 & ":", $x - 12 + $i * 200, $y + 45, 12, -1)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_ahCmbSuperTroops[$i] = GUICtrlCreateCombo("", $x + 2 + $i * 200, $y + 42, 140, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetData(-1, $sCmbTroopList, "Disabled")
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "cmbSuperTroops")
		$g_ahPicSuperTroops[$i] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 146 + $i * 200, $y + 36, 32, 32)
			GUICtrlSetState(-1, $GUI_HIDE)
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateTrainOptions
