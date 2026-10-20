; #FUNCTION# ====================================================================================================================
; Name ..........: PetHouse
; Description ...: Upgrade Pets
; Author ........: GrumpyHog (2021-04)
; Modified ......:
; Remarks .......: This file is part of MyBot Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Returns True or False
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......:
; ===============================================================================================================================

; Pet upgrade from Build menu, tab 4 "Hero Pets"
Func PetUpgrade($bTest = False)
	If $g_iTownHallLevel > 0 And $g_iTownHallLevel < 14 Then Return False
	Local $bAnyEnabled = False
	For $i = 0 To $ePetCount - 1
		If $g_bUpgradePetsEnable[$i] Then $bAnyEnabled = True
	Next
	If Not $bAnyEnabled Then Return False
	If Not $bTest And $g_sPetUpgradeTime <> "" And _DateDiff("n", _NowCalc(), $g_sPetUpgradeTime) > 0 Then
		SetLog("Pet upgrade in progress, next check after " & $g_sPetUpgradeTime, $COLOR_INFO)
		Return False
	EndIf

	checkMainScreen(False)
	SetLog("Checking for Pet upgrade", $COLOR_INFO)
	If Not OpenBuildMenu(4) Then Return False
	BuildMenuReadLoot()
	If $g_aiBuildMenuCounter[4][0] = 0 And Not $bTest Then
		PetSaveBusyTime(BuildMenuBusyTime())
		CloseBuildMenu()
		Return False
	EndIf

	Local $aList = BuildMenuCollect($g_sImgResIcon, 597, -23, "pet")
	If UBound($aList) = 0 Then
		SetLog("No pet upgrade found in Build menu", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf

	Local $iSave = $g_bChkSyncSaveDE ? $g_iTxtSmartMinDark : 0
	Local $iDE = Number($g_aiCurrentLoot[$eLootDarkElixir]), $iPick = -1
	SetLog("Pet Upgrade List (DE: " & _NumberFormat($iDE) & ", save: " & _NumberFormat($iSave) & "):", $COLOR_INFO)
	For $i = 0 To UBound($aList) - 1
		SetLog(" - " & ($aList[$i][7] ? $aList[$i][3] : "? '" & $aList[$i][3] & "'") & " : " & _NumberFormat($aList[$i][5]) & ($iDE >= $aList[$i][5] + $iSave ? "" : " (not enough)"), $COLOR_DEBUG)
	Next

	; selected pets first (pet order, or lowest cost when sort by cost is enabled), then any pet
	For $iPass = 1 To 2
		For $i = 0 To UBound($aList) - 1
			If Not $aList[$i][7] Or $iDE < $aList[$i][5] + $iSave Then ContinueLoop
			Local $iPet = _ArraySearch($g_asPetGameNames, $aList[$i][3])
			If $iPass = 1 And ($iPet < 0 Or Not $g_bUpgradePetsEnable[$iPet]) Then ContinueLoop
			If $iPick < 0 Then
				$iPick = $i
			ElseIf $g_bChkSortPetUpgrade And $g_iCmbSortPetUpgrade = 0 And $aList[$i][5] > $aList[$iPick][5] Then
				$iPick = $i ; higher cost
			ElseIf $g_bChkSortPetUpgrade And $g_iCmbSortPetUpgrade = 1 And $aList[$i][5] < $aList[$iPick][5] Then
				$iPick = $i ; lower cost
			EndIf ; Assigned / no sort: first in list
		Next
		If $iPick >= 0 Then ExitLoop
		If $iPass = 1 Then SetLog("Selected pets not available, try any pet", $COLOR_DEBUG1)
	Next
	If $iPick < 0 Then
		SetLog("Not enough Dark Elixir for pet upgrade", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf

	Local $sPet = $aList[$iPick][3]
	Local $aCoord = BuildMenuGoToItem(4, $sPet, $aList[$iPick][8], $g_sImgResIcon, 597, -23, "pet")
	If Not IsArray($aCoord) Then
		CloseBuildMenu()
		Return False
	EndIf
	SetLog("Upgrade " & $sPet & ", cost: " & _NumberFormat($aList[$iPick][5]) & " DE", $COLOR_ACTION)
	ClickP($aCoord)
	If _Sleep(1500) Then Return False
	If $bTest Then
		SetLog("[test] " & $sPet & " upgrade window should be open now, not confirmed", $COLOR_DEBUG)
		ClickAway()
		CloseBuildMenu()
		Return True
	EndIf

	If Not ClickB("UpgradePet") Then Click(625, 545, 1, 0, "Upgrade " & $sPet)
	If _Sleep(1000) Then Return False
	If isGemOpen(True) Then
		SetLog($sPet & " upgrade failed, gem window popped up", $COLOR_ERROR)
		ClickAway()
		CloseBuildMenu()
		Return False
	EndIf
	SetLog("Started upgrade for: " & $sPet, $COLOR_SUCCESS)
	GUICtrlSetState($g_hPicPetGray, $GUI_HIDE)
	GUICtrlSetState($g_hPicPetRed, $GUI_HIDE)
	GUICtrlSetState($g_hPicPetGreen, $GUI_SHOW)
	PetSaveBusyTime($aCoord[2])
	ClickAway()
	CloseBuildMenu()
	Return True
EndFunc   ;==>PetUpgrade

; remember when pet house should be free again ($iMin = lower bound read in Build menu, 0 = unknown)
Func PetSaveBusyTime($iMin)
	If $iMin <= 0 Then $iMin = 120
	$g_sPetUpgradeTime = _DateAdd("n", $iMin, _NowCalc())
	GUICtrlSetData($g_hLbLPetTime, $g_sPetUpgradeTime)
	SetLog("Pet House busy, next check after " & $g_sPetUpgradeTime, $COLOR_INFO)
EndFunc   ;==>PetSaveBusyTime
