; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: GkevinOD (2014)
; Modified ......: Hervidero (2015), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

; one Exit Battle setting for Dead Base and Active Base: ApplyConfig_600_30 copies the values to both modes
Func chkStopAtkNoLoot1()
	Local $iState = GUICtrlRead($g_hChkStopAtkNoLoot1) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE
	GUICtrlSetState($g_hTxtStopAtkNoLoot1, $iState)
	GUICtrlSetState($g_hLblTimeStopAtk, $iState)
EndFunc   ;==>chkStopAtkNoLoot1

Func chkStopAtkNoLoot2()
	Local $iState = GUICtrlRead($g_hChkStopAtkNoLoot2) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE
	Local $aControls[] = [$g_hLblStopAtkNoLoot2, $g_hTxtStopAtkNoLoot2, $g_hLblTimeStopAtk2, _
			$g_hLblMinRerourcesAtk2, $g_hTxtMinGoldStopAtk2, $g_hPicMinGoldStopAtk2, _
			$g_hTxtMinElixirStopAtk2, $g_hPicMinElixirStopAtk2, $g_hTxtMinDarkElixirStopAtk2, $g_hPicMinDarkElixirStopAtk2]
	For $hControl In $aControls
		GUICtrlSetState($hControl, $iState)
	Next
EndFunc   ;==>chkStopAtkNoLoot2

Func chkEndPercentHigher()
	Local $iState = GUICtrlRead($g_hChkEndPercentHigher) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE
	GUICtrlSetState($g_hTxtPercentHigher, $iState)
	GUICtrlSetState($g_hLblPercentHigherSec, $iState)
EndFunc   ;==>chkEndPercentHigher

Func chkEndPercentChange()
	Local $iState = GUICtrlRead($g_hChkEndPercentChange) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE
	GUICtrlSetState($g_hTxtPercentChange, $iState)
	GUICtrlSetState($g_hLblPercentChangeSec, $iState)
EndFunc   ;==>chkEndPercentChange

Func cmbEndBattleStars()
	; value read by ApplyConfig_600_30 (Off / 1 Star / 2 Stars)
EndFunc   ;==>cmbEndBattleStars

Func chkTakeLootSS()
	GUICtrlSetState($g_hChkScreenshotLootInfo, GUICtrlRead($g_hChkTakeLootSS) = $GUI_CHECKED ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc   ;==>chkTakeLootSS
