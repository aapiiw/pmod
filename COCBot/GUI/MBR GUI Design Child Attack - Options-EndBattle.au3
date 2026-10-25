; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "End Battle" tab under the "Options" tab under the "Search & Attack" tab under the "Attack Plan" tab
;                  (one Exit Battle setting for Dead Base and Active Base, Share Replay on the right)
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hChkStopAtkNoLoot1 = 0, $g_hTxtStopAtkNoLoot1 = 0, $g_hChkStopAtkNoLoot2 = 0, $g_hTxtStopAtkNoLoot2 = 0, _
		$g_hTxtMinGoldStopAtk2 = 0, $g_hTxtMinElixirStopAtk2 = 0, $g_hTxtMinDarkElixirStopAtk2 = 0, _
		$g_hChkEndNoResources = 0, $g_hCmbEndBattleStars = 0, _
		$g_hChkEndPercentHigher = 0, $g_hTxtPercentHigher = 0, $g_hChkEndPercentChange = 0, $g_hTxtPercentChange = 0
Global $g_hGrpEndBattle = 0, $g_hLblTimeStopAtk = 0, $g_hLblStopAtkNoLoot2 = 0, $g_hLblTimeStopAtk2 = 0, _
		$g_hLblMinRerourcesAtk2 = 0, $g_hPicMinGoldStopAtk2 = 0, $g_hPicMinElixirStopAtk2 = 0, $g_hPicMinDarkElixirStopAtk2 = 0, _
		$g_hLblPercentHigherSec = 0, $g_hLblPercentChangeSec = 0

Global $g_hChkShareAttack = 0, $g_hLblShareMinLoot = 0, $g_hTxtShareMinGold = 0, $g_hTxtShareMinElixir = 0, $g_hTxtShareMinDark = 0, $g_hTxtShareMessage = 0, _
		$g_hChkTakeLootSS = 0, $g_hChkScreenshotLootInfo = 0
Global $g_hLblShareMinGold = 0, $g_hLblShareMinElixir = 0, $g_hLblShareMinDark = 0

Func CreateAttackSearchOptionsEndBattle()
	Local $sTxtTip = ""
	Local $x = 10, $y = 45
	$g_hGrpEndBattle = GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "Group_01", "Exit Battle"), $x - 5, $y - 20, 200, $g_iSizeHGrpTab4)
	$y -= 5
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblExitLoot", "Loot"), $x, $y, 180, 16)
	$y += 17
		$g_hChkStopAtkNoLoot1 = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkStopAtkNoLoot", "Loot unchanged"), $x, $y, 115, 18)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkStopAtkNoLoot_Info_01", "End Battle if there is no extra loot raided within this No. of seconds.") & @CRLF & _
					GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkStopAtkNoLoot_Info_02", "Countdown is started after all Troops and Royals are deployed in battle.")
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkStopAtkNoLoot1")
			GUICtrlSetState(-1, $GUI_CHECKED)
		$g_hTxtStopAtkNoLoot1 = GUICtrlCreateInput("20", $x + 130, $y + 1, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetLimit(-1, 2)
		$g_hLblTimeStopAtk = GUICtrlCreateLabel(GetTranslatedFileIni("MBR Global GUI Design", "sec.", -1), $x + 165, $y + 3, -1, -1)
	$y += 22
		$g_hChkStopAtkNoLoot2 = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkStopAtkLowLoot", "Loot below limits"), $x, $y, 180, 18)
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkStopAtkNoLoot2")
			GUICtrlSetState(-1, $GUI_UNCHECKED)
	$y += 20
		$g_hLblStopAtkNoLoot2 = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblExitUnchangedFor", "Unchanged for") & ":", $x + 16, $y + 3, 100, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hTxtStopAtkNoLoot2 = GUICtrlCreateInput("5", $x + 130, $y + 1, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetLimit(-1, 2)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hLblTimeStopAtk2 = GUICtrlCreateLabel(GetTranslatedFileIni("MBR Global GUI Design", "sec.", -1), $x + 165, $y + 3, -1, -1)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 20
		$g_hLblMinRerourcesAtk2 = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblExitBelow", "Below") & ":", $x + 16, $y + 2, -1, -1)
			$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblMinRerourcesAtk2_Info_01", "End Battle if below this amount of")
			_GUICtrlSetTip(-1, $sTxtTip & " resources.")
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 20
		$g_hTxtMinGoldStopAtk2 = GUICtrlCreateInput("2000", $x + 75, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, $sTxtTip & " gold.")
			GUICtrlSetLimit(-1, 6)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hPicMinGoldStopAtk2 = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 128, $y, 16, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 20
		$g_hTxtMinElixirStopAtk2 = GUICtrlCreateInput("2000", $x + 75, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, $sTxtTip & " elixir.")
			GUICtrlSetLimit(-1, 6)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hPicMinElixirStopAtk2 = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 128, $y, 16, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 20
		$g_hTxtMinDarkElixirStopAtk2 = GUICtrlCreateInput("50", $x + 75, $y, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, $sTxtTip & " dark elixir.")
			GUICtrlSetLimit(-1, 4)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hPicMinDarkElixirStopAtk2 = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 128, $y, 16, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 22
		$g_hChkEndNoResources = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndNoResources", "No resources left"), $x, $y, 180, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndNoResources_Info_01", "End Battle when all Gold, Elixir and Dark Elixir = 0"))
	$y += 36
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblExitDamage", "Damage"), $x, $y, 180, 16)
	$y += 17
		$g_hChkEndPercentHigher = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndPercentHigher", "Damage above"), $x, $y, 115, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndPercentHigher_Info_01", "End Battle if Overall Damage Percentage is above"))
			GUICtrlSetOnEvent(-1, "chkEndPercentHigher")
		$g_hTxtPercentHigher = GUICtrlCreateInput("60", $x + 130, $y + 1, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndPercentHigher_Info_01", -1))
			GUICtrlSetLimit(-1, 3)
		$g_hLblPercentHigherSec = GUICtrlCreateLabel("%", $x + 165, $y + 3, -1, -1)
	$y += 22
		$g_hChkEndPercentChange = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndPercentChange", "No damage change"), $x, $y, 115, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndPercentChange_Info_01", "End Battle when Percentage doesn't change in"))
			GUICtrlSetOnEvent(-1, "chkEndPercentChange")
		$g_hTxtPercentChange = GUICtrlCreateInput("15", $x + 130, $y + 1, 30, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "ChkEndPercentChange_Info_01", -1))
			GUICtrlSetLimit(-1, 2)
		$g_hLblPercentChangeSec = GUICtrlCreateLabel(GetTranslatedFileIni("MBR Global GUI Design", "sec.", -1), $x + 165, $y + 3, -1, -1)
	$y += 39
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblExitStars", "Stars"), $x, $y, 180, 16)
	$y += 18
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "LblEndBattleAt", "End battle at") & ":", $x, $y + 3, 95, 16)
		$g_hCmbEndBattleStars = GUICtrlCreateCombo("", $x + 98, $y, 87, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "CmbEndBattleStars", "Off|1 Star|2 Stars"))
			_GUICtrlComboBox_SetCurSel(-1, 0)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - EndBattle", "CmbEndBattleStars_Info_01", "Choose the star result that ends the battle."))
			GUICtrlSetOnEvent(-1, "cmbEndBattleStars")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = 230
	$y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "Group_SharedActions", "Replay && Loot Snapshot"), $x - 20, $y - 20, 214, $g_iSizeHGrpTab4)
	$y -= 5
		$g_hChkShareAttack = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ChkShareAttack", "Share replay"), $x - 10, $y, 190, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ChkShareAttack_Info_01", "Check this to share your battle replay in the clan chat."))
			GUICtrlSetOnEvent(-1, "chkShareAttack")
	$y += 25
		$g_hLblShareMinLoot = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "LblShareMinLoot", "Minimum loot") & ":", $x, $y, 180, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 21
		$g_hLblShareMinGold = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "LblShareMinGold", "Gold"), $x, $y + 2, 65, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hTxtShareMinGold = GUICtrlCreateInput("300000", $x + 70, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "TxtShareMinGold_Info_01", "Only Share Replay when the battle loot is more than this amount of Gold."))
			GUICtrlSetLimit(-1, 7)
			GUICtrlSetState(-1, $GUI_DISABLE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 143, $y + 1, 16, 16)
	$y += 22
		$g_hLblShareMinElixir = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "LblShareMinElixir", "Elixir"), $x, $y + 2, 65, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hTxtShareMinElixir = GUICtrlCreateInput("300000", $x + 70, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "TxtShareMinElixir_Info_01", "Only Share Replay when the battle loot is more than this amount of Elixir."))
			GUICtrlSetLimit(-1, 7)
			GUICtrlSetState(-1, $GUI_DISABLE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 143, $y + 1, 16, 16)
	$y += 22
		$g_hLblShareMinDark = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "LblShareMinDark", "Dark Elixir"), $x, $y + 2, 65, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hTxtShareMinDark = GUICtrlCreateInput("0", $x + 70, $y, 70, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "TxtShareMinDark_Info_01", "Only Share Replay when the battle loot is more than this amount of Dark Elixir."))
			GUICtrlSetLimit(-1, 5)
			GUICtrlSetState(-1, $GUI_DISABLE)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 143, $y + 1, 16, 16)
	$y += 26
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "LblRandomMessage", "Message") & ":", $x, $y, 180, 16)
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 19
		$g_hTxtShareMessage = GUICtrlCreateEdit("", $x, $y, 180, 70, BitOR($ES_WANTRETURN, $ES_CENTER, $ES_AUTOVSCROLL))
			GUICtrlSetData(-1, StringFormat(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ListShareMessage_Item_01", "Nice\r\nGood\r\nThanks \r\nWowwww")))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ListShareMessage_Info_01", "Message to send with the Share Replay"))
			GUICtrlSetState(-1, $GUI_DISABLE)
	$y += 85
		$g_hChkTakeLootSS = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "Group_02", "Take loot snapshot"), $x - 10, $y, 190, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ChkTakeLootSS_Info_01", "Check this if you want to save a Loot snapshot of the Village that was attacked."))
			GUICtrlSetOnEvent(-1, "chkTakeLootSS")
	$y += 20
		$g_hChkScreenshotLootInfo = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ChkScreenshotLootInfo", "Include loot info in filename"), $x, $y, 180, 18)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Options-EndBattle", "ChkScreenshotLootInfo_Info_01", "Include loot info in the screenshot filename"))
			GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>CreateAttackSearchOptionsEndBattle
