; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the bottom panel
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: GKevinOD (2014)
; Modified ......: DkEd, Hervidero (2015), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hBtnStart = 0, $g_hBtnStop = 0, $g_hBtnPause = 0, $g_hBtnResume = 0, $g_hBtnSearchMode = 0, $g_hBtnMakeScreenshot = 0, $g_hBtnHide = 0, $g_hBtnEmbed = 0, _
	   $g_hChkBackgroundMode = 0, $g_hBtnAttackNowDB = 0, $g_hBtnAttackNowLB = 0, $g_hBtnControl = 0
Global $g_hPicTwoArrowShield = 0, $g_hPicArrowLeft = 0, $g_hPicArrowRight = 0
Global $g_hGrpVillage = 0, $g_hBtnDirectAttack = 0, $g_hBtnRushAttack = 0, $g_hBtnBBSpam = 0, $g_hBtnCCSpam = 0
Global $g_hLblResultGoldNow = 0, $g_hLblResultGoldHourNow = 0, $g_hPicResultGoldNow = 0, $g_hPicResultGoldTemp = 0
Global $g_hLblResultElixirNow = 0, $g_hLblResultElixirHourNow = 0, $g_hPicResultElixirNow = 0, $g_hPicResultElixirTemp = 0
Global $g_hLblResultDENow = 0, $g_hLblResultDEHourNow = 0, $g_hPicResultDENow = 0, $g_hPicResultDETemp = 0
Global $g_hLblResultTrophyNow = 0, $g_hPicResultTrophyNow = 0, $g_hLblResultRuntimeNow = 0, $g_hPicResultRuntimeNow = 0, $g_hLblResultBuilderNow = 0, $g_hPicResultBuilderNow = 0
Global $g_hLblResultAttackedHourNow = 0, $g_hPicResultAttackedHourNow = 0, $g_hLblResultGemNow = 0, $g_hPicResultGemNow = 0, $g_hLblResultSkippedHourNow = 0, $g_hPicResultSkippedHourNow = 0
Global $g_hLblVillageReportTemp = 0

; GLOBALS FOR NEW GAME STATUS DISPALY
Global $g_hlblKing = 0, $g_hPicKingGray = 0, $g_hPicKingBlue = 0, $g_hPicKingRed = 0, $g_hPicKingGreen = 0
Global $g_hlblQueen = 0, $g_hPicQueenGray = 0, $g_hPicQueenBlue = 0, $g_hPicQueenRed = 0, $g_hPicQueenGreen = 0
Global $g_hlblWarden = 0, $g_hPicWardenGray = 0, $g_hPicWardenBlue = 0, $g_hPicWardenRed = 0, $g_hPicWardenGreen = 0
Global $g_hlblChampion = 0, $g_hPicChampionGray = 0, $g_hPicChampionBlue = 0, $g_hPicChampionRed = 0, $g_hPicChampionGreen = 0
Global $g_hlblPrince = 0, $g_hPicPrinceGray = 0, $g_hPicPrinceBlue = 0, $g_hPicPrinceRed = 0, $g_hPicPrinceGreen = 0
Global $g_hlblDuke = 0, $g_hPicDukeGray = 0, $g_hPicDukeBlue = 0, $g_hPicDukeRed = 0, $g_hPicDukeGreen = 0
Global $g_hlblLab = 0, $g_hPicLabGray = 0, $g_hPicLabRed = 0, $g_hPicLabGreen = 0, $g_hLbLLabTime = 0

; Pet House
Global $g_hlblPet = 0, $g_hPicPetGray = 0, $g_hPicPetRed = 0, $g_hPicPetGreen = 0, $g_hLbLPetTime = 0

Func CreateBottomPanel()
	Local $sTxtTip = ""
	;~ ------------------------------------------------------
	;~ Lower part visible on all Tabs
	;~ ------------------------------------------------------

	;~ Buttons
	Local $y_bottom = 0 ; 515
	Local $x = 10, $y = $y_bottom + 10
	GUICtrlCreateGroup("https://mybot.run", $x - 5, $y - 10, 160, 100)
		$g_hBtnStart = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnStart", "Start Bot"), $x, $y + 2 +5, 75, 30)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnStart_Info_01", "Use this to START the bot."))
			If $g_bBtnColor then GUICtrlSetBkColor(-1, 0x5CAD85)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hBtnStop = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnStop", "Stop Bot"), -1, -1, 75, 30)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnStop_Info_01", "Use this to STOP the bot (or ESC key)."))
			If $g_bBtnColor then GUICtrlSetBkColor(-1, 0xDB4D4D)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hBtnPause = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnPause", "Pause"), $x + 75, -1, 75, 30)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnPause_Info_01", "Use this to PAUSE all actions of the bot until you Resume (or Pause/Break key)."))
			If $g_bBtnColor then GUICtrlSetBkColor(-1,  0xFFA500)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hBtnResume = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnResume", "Resume"), -1, -1, 75, 30)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnResume_Info_01", "Use this to RESUME a paused Bot (or Pause/Break key)."))
			If $g_bBtnColor then GUICtrlSetBkColor(-1,  0xFFA500)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hBtnSearchMode = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnSearchMode", "Search Mode"), -1, -1, 75, 30)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnSearchMode_Info_01", "Does not attack. Searches for a Village that meets conditions."))
			GUICtrlSetOnEvent(-1, "btnSearchMode")
			If $g_bBtnColor then GUICtrlSetBkColor(-1,  0xFFA500)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hBtnMakeScreenshot = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnMakeScreenshot", "Photo"), $x , $y + 40, 35, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnMakeScreenshot_Info_01", "Click here to take a snaphot of your village and save it to a file."))
			If $g_bBtnColor then GUICtrlSetBkColor(-1, 0x5CAD85)
		$g_hBtnHide = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnHide", "Hide"), $x + 35, $y + 40, 40, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnHide_Info_01", "Use this to move the Android Window out of sight.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Bottom", "BtnHide_Info_02", "(Not minimized, but hidden)"))
			If $g_bBtnColor Then GUICtrlSetBkColor(-1, 0x22C4F5)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hBtnEmbed = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Bottom", "BtnEmbed", "Dock"), $x + 75, $y + 40, 75, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "BtnEmbed_Info_01", "Use this to embed the Android Window into Bot."))
			If $g_bBtnColor Then GUICtrlSetBkColor(-1, 0x22C4F5)
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "btnEmbed")
		$g_hChkBackgroundMode = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Bottom", "ChkBackgroundMode", "Background Mode"), $x + 1, $y + 65, -1, -1)
			GUICtrlSetFont(-1, 7)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Bottom", "ChkBackgroundMode_Info_01", "Check this to ENABLE the Background Mode of the Bot.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Bottom", "ChkBackgroundMode_Info_02", "With this you can also hide the Android Emulator window out of sight."))
			If $g_bGuiRemote Then GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkBackground")
			GUICtrlSetState(-1, (($g_bAndroidAdbScreencap = True) ? ($GUI_CHECKED) : ($GUI_UNCHECKED)))
		
		$g_hBtnControl = GUICtrlCreateButton("Edit", $x + 245, $y + 70, 35, 20)
			GUICtrlSetState(-1, $GUI_HIDE)
			GUICtrlSetOnEvent(-1, "ToggleControl")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	If $g_bAndroidAdbScreencap Then chkBackground() ; update background mode GUI

    $g_hPicArrowLeft = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnArrowLeft, $x + 273, $y + 40, 16, 16)
	  $sTxtTip = GetTranslatedFileIni("MBR GUI Design Bottom", "GrpVillage_Info_01", "Switch between village info and stats")
	  _GUICtrlSetTip(-1, $sTxtTip)
    $g_hPicArrowRight = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnArrowRight, $x + 247 + 198, $y + 40, 16, 16)
	  _GUICtrlSetTip(-1, $sTxtTip)
	  GUICtrlSetState(-1, $GUI_SHOW)



;New section for royal and lab status: K Q P W C D shields, Lab and Pet House icons with remaining time (Mod PH layout)
	Local $x = 174, $y = $y_bottom + 5
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Bottom", "GrpStatus_Info_01", "Gray - N/A" & @CRLF & "Green - Ready" & @CRLF & "Blue - Healing" & @CRLF & "Red - Upgrading")
		BottomHeroShield($g_hPicKingGray, $g_hPicKingBlue, $g_hPicKingGreen, $g_hPicKingRed, $g_hlblKing, GetTranslatedFileIni("MBR Global GUI Design Names Troops", "King_K", "K"), $x, $y, $sTxtTip)
	$x += 19
		BottomHeroShield($g_hPicQueenGray, $g_hPicQueenBlue, $g_hPicQueenGreen, $g_hPicQueenRed, $g_hlblQueen, GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Queen_Q", "Q"), $x, $y, $sTxtTip)
	$x += 19
		BottomHeroShield($g_hPicPrinceGray, $g_hPicPrinceBlue, $g_hPicPrinceGreen, $g_hPicPrinceRed, $g_hlblPrince, GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Prince_P", "P"), $x, $y, $sTxtTip)
	$x += 19
		BottomHeroShield($g_hPicWardenGray, $g_hPicWardenBlue, $g_hPicWardenGreen, $g_hPicWardenRed, $g_hlblWarden, GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Warden_W", "W"), $x, $y, $sTxtTip)
	$x += 19
		BottomHeroShield($g_hPicChampionGray, $g_hPicChampionBlue, $g_hPicChampionGreen, $g_hPicChampionRed, $g_hlblChampion, GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Champion_C", "C"), $x, $y, $sTxtTip)
	$x += 19
		BottomHeroShield($g_hPicDukeGray, $g_hPicDukeBlue, $g_hPicDukeGreen, $g_hPicDukeRed, $g_hlblDuke, GetTranslatedFileIni("MBR Global GUI Design Names Troops", "Duke_D", "D"), $x, $y, $sTxtTip)

	; Lab display (Gray, Green, Red created one after the other: SwitchAccountVariablesReload loops over their IDs)
	Local $x = 174, $y = $y_bottom + 43
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Bottom", "GrpStatus_Info_02", "Gray - N/A" & @CRLF & "Green - Lab is Running" & @CRLF & "Red - Lab Has Stopped")
		$g_hPicLabGray = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnLaboratory, $x - 1, $y - 1, 18, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
		$g_hPicLabGreen = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnLaboratory, $x - 1, $y - 1, 18, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hPicLabRed = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnLaboratory, $x - 1, $y - 1, 18, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hlblLab = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Bottom", "Lab_L", "L"), $x + 4, $y + 17, 10, 16, $SS_LEFT)
			_GUICtrlSetTip(-1, $sTxtTip)
		$g_hLbLLabTime = GUICtrlCreateLabel("", $x + 20, $y + 2, 70, 16, $SS_LEFT)

	; Pet House display
	Local $x = 174, $y = $y_bottom + 76
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Bottom", "GrpStatus_Info_03", "Gray - N/A" & @CRLF & "Green - Pet House is Running" & @CRLF & "Red - Pet House Has Stopped")
		$g_hPicPetGray = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetHouse, $x - 1, $y - 1, 18, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
		$g_hPicPetGreen = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetHouse, $x - 1, $y - 1, 18, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hPicPetRed = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnPetHouse, $x - 1, $y - 1, 18, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hlblPet = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Bottom", "Pet_P", "P"), $x + 4, $y + 17, 10, 16, $SS_LEFT)
			_GUICtrlSetTip(-1, $sTxtTip)
		$g_hLbLPetTime = GUICtrlCreateLabel("", $x + 20, $y + 2, 70, 16, $SS_LEFT)

   ;~ Village
   Local $x = 295, $y = $y_bottom + 20
   $g_hGrpVillage = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Bottom", "GrpVillage", "Village"), $x - 0, $y - 20, 160, 85)
	   $g_hLblResultGoldNow = GUICtrlCreateLabel("", $x + 10, $y + 2, 60, 15, $SS_RIGHT)
	   $g_hLblResultGoldHourNow = GUICtrlCreateLabel("", $x + 10, $y + 2, 60, 15, $SS_RIGHT)
		   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultGoldNow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnGold, $x + 71, $y, 16, 16)
		   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultGoldTemp = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnGold, $x + 15, $y, 16, 16)

	   $g_hLblResultElixirNow = GUICtrlCreateLabel("", $x + 10, $y + 22, 60, 15, $SS_RIGHT)
	   $g_hLblResultElixirHourNow = GUICtrlCreateLabel("", $x + 10, $y + 22, 60, 15, $SS_RIGHT)
		   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultElixirNow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnElixir, $x + 71, $y + 20, 16, 16)
		   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultElixirTemp = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnElixir, $x + 15, $y + 20, 16, 16)

	   $g_hLblResultDENow = GUICtrlCreateLabel("", $x + 10, $y + 42, 60, 15, $SS_RIGHT)
	   $g_hLblResultDEHourNow = GUICtrlCreateLabel("", $x + 10, $y + 42, 60, 15, $SS_RIGHT)
		   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultDENow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnDark, $x + 71, $y + 40, 16, 16)
		   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultDETemp = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnDark, $x + 15, $y + 40, 16, 16)
	   $x += 75

	   ;trophy / runtime
	   $g_hLblResultTrophyNow = GUICtrlCreateLabel("", $x + 13, $y + 2, 43, 15, $SS_RIGHT)
	   $g_hPicResultTrophyNow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnTrophy, $x + 59, $y , 16, 16)
	   $g_hLblResultRuntimeNow = GUICtrlCreateLabel("00:00:00", $x + 13, $y + 2, 43, 15, $SS_RIGHT)
	   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultRuntimeNow = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnHourGlass, $x +57, $y, 16, 16)
	   GUICtrlSetState(-1, $GUI_HIDE)

	   ;builders/attacked
	   $g_hLblResultBuilderNow = GUICtrlCreateLabel("", $x + 13, $y + 22, 43, 15, $SS_RIGHT)
	   $g_hPicResultBuilderNow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnBuilder, $x + 59, $y + 20, 16, 16)
	   $g_hLblResultAttackedHourNow = GUICtrlCreateLabel("0", $x + 13, $y + 22, 43, 15, $SS_RIGHT)
	   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultAttackedHourNow = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnBldgTarget, $x +59, $y + 20, 16, 16)
	   GUICtrlSetState(-1, $GUI_HIDE)

	   ;gems/skipped
	   $g_hLblResultGemNow = GUICtrlCreateLabel("", $x + 13, $y + 42, 43, 15, $SS_RIGHT)
	   $g_hPicResultGemNow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnGem, $x + 59, $y + 40, 16, 16)
	   $g_hLblResultSkippedHourNow = GUICtrlCreateLabel("0", $x + 13, $y + 42, 43, 15, $SS_RIGHT)
	   GUICtrlSetState(-1, $GUI_HIDE)
	   $g_hPicResultSkippedHourNow = GUICtrlCreateIcon ($g_sLibIconPath, $eIcnBldgX, $x + 59, $y + 40, 16, 16)
	   GUICtrlSetState(-1, $GUI_HIDE)

	   $x = 335
	   $g_hLblVillageReportTemp = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Bottom", "LblVillageReportTemp_01", "Village Report") & @CRLF & GetTranslatedFileIni("MBR GUI Design Bottom", "LblVillageReportTemp_02", "will appear here") & @CRLF & GetTranslatedFileIni("MBR GUI Design Bottom", "LblVillageReportTemp_03", "on first run."), $x , $y + 5, 80, 45, BITOR($SS_CENTER, $BS_MULTILINE))

   GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Direct | Rush | BBSpam | CCSpam under the Village group (SpecialModes.au3)
	Local $aBtn[4][4] = [["Direct", 38, "DirectAttack", "Direct attack: attack the village on screen now (Dead / Live Base: Train Army > Options)"], _
			["Rush", 36, "ToggleRushAttack", "Rush Attack: attack again and again, no donate, request or upgrades, until Halt Attack. Click again = off"], _
			["BBSpam", 43, "ToggleBBSpam", "Builder Base attacks until both BB storages are full. Click again = off"], _
			["CCSpam", 43, "ToggleCCSpam", "Donate every CC Spam Min..Max s (Train Army > Options). Click again = off"]]
	$x = 295
	For $i = 0 To 3
		Local $hBtn = GUICtrlCreateButton($aBtn[$i][0], $x, $y_bottom + 84, $aBtn[$i][1], 20)
		GUICtrlSetFont(-1, 7)
		_GUICtrlSetTip(-1, $aBtn[$i][3])
		GUICtrlSetOnEvent(-1, $aBtn[$i][2])
		Switch $i
			Case 0
				$g_hBtnDirectAttack = $hBtn
			Case 1
				$g_hBtnRushAttack = $hBtn
			Case 2
				$g_hBtnBBSpam = $hBtn
			Case 3
				$g_hBtnCCSpam = $hBtn
		EndSwitch
		$x += $aBtn[$i][1]
	Next

EndFunc   ;==>CreateBottomPanel

; one hero status shield (Gray shown, Blue / Green / Red hidden) and its letter below
Func BottomHeroShield(ByRef $hGray, ByRef $hBlue, ByRef $hGreen, ByRef $hRed, ByRef $hLbl, $sLetter, $x, $y, $sTip)
	$hGray = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnGrayShield, $x, $y, 16, 16)
	_GUICtrlSetTip(-1, $sTip)
	$hBlue = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlueShield, $x, $y, 16, 16)
	_GUICtrlSetTip(-1, $sTip)
	GUICtrlSetState(-1, $GUI_HIDE)
	$hGreen = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnGreenShield, $x, $y, 16, 16)
	_GUICtrlSetTip(-1, $sTip)
	GUICtrlSetState(-1, $GUI_HIDE)
	$hRed = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnRedShield, $x, $y, 16, 16)
	_GUICtrlSetTip(-1, $sTip)
	GUICtrlSetState(-1, $GUI_HIDE)
	$hLbl = GUICtrlCreateLabel($sLetter, $x + 4, $y + 21, 10, 16, $SS_LEFT)
	_GUICtrlSetTip(-1, $sTip)
EndFunc   ;==>BottomHeroShield
