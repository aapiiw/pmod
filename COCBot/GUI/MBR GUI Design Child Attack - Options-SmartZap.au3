; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design Tab SmartZap
; Description ...: This file creates the "SmartZap" tab under the "Attack Plan" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: LunaEclipse(February, 2016)
; Modified ......: TheRevenor (November, 2016), TheRevenor (Desember, 2017), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

;Global $g_hGUI_NEWSMARTZAP = 0
Global $g_hChkSmartLightSpell = 0, $g_hChkSmartEQSpell = 0, $g_hChkNoobZap = 0, $g_hChkSmartZapDB = 0, $g_hChkSmartZapSaveHeroes = 0, _
	   $g_hTxtSmartZapMinDE = 0, $g_hTxtSmartExpectedDE = 0, $g_hChkDebugSmartZap = 0, $g_hChkSmartZapFTW = 0, $g_hEarlyZap = 0

Global $g_hLblSmartUseLSpell = 0, $g_hLblSmartUseEQSpell = 0,  $g_hLblSmartZap = 0, $g_hLblNoobZap = 0, $g_hLblSmartLightningUsed = 0, $g_hLblSmartEarthQuakeUsed = 0

Func CreateAttackNewSmartZap()
	; right column of Options / Search, one option per row (SmartZap tab removed, Oct 2026)
	Local $T = "MBR GUI Design Child Attack - Options-SmartZap"
	Local $x = 248, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni($T, "Group_01", "SmartZap/NoobZap"), $x - 15, $y - 20, 189, 330)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnLightSpell, $x - 5, $y - 4, 24, 24)
		$g_hChkSmartLightSpell = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkSmartLight_L", "Use Lightning"), $x + 25, $y, 140, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "LblSmartUseLSpell_Info_01", "Check this to drop Lightning Spells on top of Dark Elixir Drills.") & @CRLF & @CRLF & _
							   GetTranslatedFileIni($T, "LblSmartUseLSpell_Info_02", "Remember to go to the tab 'troops' and put the maximum capacity") & @CRLF & _
							   GetTranslatedFileIni($T, "LblSmartUseLSpell_Info_03", "of your spell factory and the number of spells so that the bot can function perfectly."))
			GUICtrlSetOnEvent(-1, "chkSmartLightSpell")
	$y += 30
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnEarthQuakeSpell, $x - 5, $y - 4, 24, 24)
		$g_hChkSmartEQSpell = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkSmartEQ_L", "Use Earthquake"), $x + 25, $y, 140, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "LblSmartUseEQSpell_Info_01", "Check this to drop EarthQuake Castle Spell on any Dark Elixir Drill"))
			GUICtrlSetOnEvent(-1, "chkEarthQuakeZap")
		; hidden labels kept for the control functions
		$g_hLblSmartUseLSpell = GUICtrlCreateLabel("", $x, $y, 1, 1)
			GUICtrlSetState(-1, $GUI_HIDE)
		$g_hLblSmartUseEQSpell = GUICtrlCreateLabel("", $x, $y, 1, 1)
			GUICtrlSetState(-1, $GUI_HIDE)
	$y += 30
		$g_hChkNoobZap = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkNoobZap", "Use NoobZap"), $x, $y, 165, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "ChkNoobZap_Info_01", "Check this to drop lightning spells on any Dark Elixir Drills"))
			GUICtrlSetOnEvent(-1, "chkNoobZap")
	$y += 24
		$g_hChkSmartZapDB = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkSmartZapDB_S", "Only Dead Bases"), $x, $y, 165, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "ChkSmartZapDB_Info_01", "This will only SmartZap a Dead Base (Recommended)"))
			GUICtrlSetOnEvent(-1, "chkSmartZapDB")
			GUICtrlSetState(-1, $GUI_CHECKED)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 24
		$g_hChkSmartZapSaveHeroes = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkSmartZapSaveHeroes_S", "No zap if heroes deployed"), $x, $y, 165, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "ChkSmartZapSaveHeroes_Info_01", "This will stop SmartZap from zapping a base on a Town Hall Snipe if your Heroes were deployed"))
			GUICtrlSetOnEvent(-1, "chkSmartZapSaveHeroes")
			GUICtrlSetState(-1, $GUI_CHECKED)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 24
		$g_hChkSmartZapFTW = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkSmartZapFTW", "Strike For The Win"), $x, $y, 165, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "ChkSmartZapFTW_Info_01", "SmartZap/NoobZap will try to reach 50% Destruction to get the win.") & @CRLF & _
							   GetTranslatedFileIni($T, "ChkSmartZapFTW_Info_02", "It will not zap, if one Star is already reached, or if there is no chance to win."))
			GUICtrlSetOnEvent(-1, "chkSmartZapFTW")
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 24
		$g_hEarlyZap = GUICtrlCreateCheckbox(GetTranslatedFileIni($T, "ChkSmartZapEarly_S", "EarlyZap after 50%"), $x, $y, 165, 17)
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "ChkSmartZapEarly_Info_01", "Enable Early Zap while attacking, after readh 50% Destruction"))
			GUICtrlSetOnEvent(-1, "chkSmartZapEarly")
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 34
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDrill, $x - 5, $y - 2, 24, 24)
		$g_hLblSmartZap = GUICtrlCreateLabel(GetTranslatedFileIni($T, "LblSmartZap_S", "Min. DE in drill") & ":", $x + 25, $y + 2, 85, 16)
		$g_hTxtSmartZapMinDE = GUICtrlCreateInput("350", $x + 112, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "LblSmartZap_Info_01", "Set the Value of the minimum amount of Dark Elixir in the Drills"))
			GUICtrlSetLimit(-1, 3)
			GUICtrlSetOnEvent(-1, "txtMinDark")
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 30
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x - 5, $y - 2, 24, 24)
		$g_hLblNoobZap = GUICtrlCreateLabel(GetTranslatedFileIni($T, "LblNoobZap_S", "Expected DE gain") & ":", $x + 25, $y + 2, 85, 16)
		$g_hTxtSmartExpectedDE = GUICtrlCreateInput("320", $x + 112, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni($T, "LblNoobZap_Info_01", "Set value for expected gain every dark drill") & @CRLF & _
							   GetTranslatedFileIni($T, "LblNoobZap_Info_02", "NoobZap will be stopped if the last zap gained less DE than expected"))
			GUICtrlSetLimit(-1, 3)
			GUICtrlSetOnEvent(-1, "txtExpectedDE")
			GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateAttackNewSmartZap
