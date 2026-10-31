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

Global $g_asPetAssigned[0] ; names of assigned pets seen by PetAssignedMark

; Pet upgrade from Build menu, tab 4 "Hero Pets"
Func PetUpgrade($bTest = False)
	If $g_iTownHallLevel > 0 And $g_iTownHallLevel < 14 Then Return False
	Local $bAnyEnabled = False
	For $i = 0 To $ePetCount - 1
		If $g_bUpgradePetsEnable[$i] Then $bAnyEnabled = True
	Next
	If Not $bAnyEnabled Then Return False
	; saved time is a guess (a pet finished 19 h early on qiralle, 26 Oct 2026): counters just read in the Build menu
	; (Laboratory check) showing a free Pet House win over it
	Local $bPetFree = BuildMenuCountersFresh(False) And $g_aiBuildMenuCounter[4][0] > 0
	; Pet Potion due (not tried in the last hour): the Build menu is opened to use it while the Pet House is busy
	Local $bPotion = $g_bUsePetPotion And ($g_ahPotionTimer[CurAccountIndex()][2] = 0 Or __TimerDiff($g_ahPotionTimer[CurAccountIndex()][2]) >= 3600000)
	If Not $bTest And Not $bPetFree And Not $bPotion And $g_sPetUpgradeTime <> "" And _DateDiff("n", _NowCalc(), $g_sPetUpgradeTime) > 0 Then
		SetLog("Pet upgrade in progress, next check after " & $g_sPetUpgradeTime, $COLOR_INFO)
		Return False
	EndIf

	; Pet House free but every pet locked ("Upgrade Pet House to Level N") or maxed: the list was read for nothing every cycle
	Local $hNoPet = $g_ahRoutineTimer[CurAccountIndex()][2]
	If Not $bTest And $hNoPet <> 0 And __TimerDiff($hNoPet) < $g_aiNoUpgradeWaitMin[CurAccountIndex()][1] * 60000 Then
		SetDebugLog("No pet to upgrade " & Round(__TimerDiff($hNoPet) / 60000) & " min ago, next check after " & $g_aiNoUpgradeWaitMin[CurAccountIndex()][1] & " min")
		Return False
	EndIf

	If Not IsBuildMenuOpen() Then checkMainScreen(False) ; menu left open by the Laboratory check: only the tab changes
	SetLog("Checking for Pet upgrade", $COLOR_INFO)
	If Not OpenBuildMenu(4) Then Return False
	Local $iOldDE = Number($g_aiCurrentLoot[$eLootDarkElixir])
	BuildMenuReadLoot()
	; DE read '' with the menu open (1 of 4 pet checks 28-29 Oct, quazzy test): keep the village report value
	If Number($g_aiCurrentLoot[$eLootDarkElixir]) <= 0 And $iOldDE > 0 Then $g_aiCurrentLoot[$eLootDarkElixir] = $iOldDE
	; counter not read (-1) right after the tab change: Pet House busy was missed, the upgrade click opened the gem window
	; (qurlk 28 Oct 21:14 'Pet:-1/-1', read again 0/1 a moment later)
	If $g_aiBuildMenuCounter[4][0] < 0 Then
		If _Sleep(500) Then Return False
		ReadBuildMenuCounters(False)
	EndIf
	If $g_aiBuildMenuCounter[4][0] = 0 And Not $bTest Then
		PetSaveBusyTime(BuildMenuBusyTime())
		If $g_bUsePetPotion And BuildMenuUsePotion(2) Then $g_sPetUpgradeTime = "" ; 1 h faster: read the time again next check
		CloseBuildMenu()
		Return False
	EndIf

	; sort "Assigned" (2): only pets assigned to a hero (hero portrait left of the pet, unassigned = grey slot)
	Local $bAssignedOnly = $g_bChkSortPetUpgrade And $g_iCmbSortPetUpgrade = 2
	Local $aNone[0]
	$g_asPetAssigned = $aNone
	Local $aList = BuildMenuCollect($g_sImgResIcon, 597, -23, "pet", Default, 12, "", $bAssignedOnly ? "PetAssignedMark" : "")
	If UBound($aList) = 0 Then
		; all locked ("Upgrade Pet House to Level N") or max: 6 h; red cost (not enough DE yet): 1 h
		$g_aiNoUpgradeWaitMin[CurAccountIndex()][1] = $g_bBuildMenuRedSeen ? 60 : 360
		SetLog("No pet upgrade found in Build menu (" & ($g_bBuildMenuRedSeen ? "not enough Dark Elixir" : "locked: upgrade Pet House, or max") & _
				"), next check in " & $g_aiNoUpgradeWaitMin[CurAccountIndex()][1] / 60 & " h", $COLOR_INFO)
		$g_ahRoutineTimer[CurAccountIndex()][2] = __TimerInit()
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
			If $bAssignedOnly And _ArraySearch($g_asPetAssigned, $aList[$i][3]) < 0 Then ContinueLoop
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
		If $iPass = 1 Then SetLog("Selected pets not available, try any " & ($bAssignedOnly ? "assigned " : "") & "pet", $COLOR_DEBUG1)
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
	; "Upgrade only when done before": the pet list is short, a pet upgrade that ends too late = no pet upgrade now
	If Not UpgradeDeadlineOk($sPet, $aCoord[2]) Then
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

	; DE Confirm button only (area of "UpgradePets"): the Hammer of Heroes button is left of it
	If Not ClickB("UpgradePets", "UpgradePet*") Then Click(625, 545, 1, 0, "Upgrade " & $sPet)
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
	; new pet upgrade of 1 day or more: potion right away (row 1 of tab 4 shows the running upgrade)
	If $g_bUsePetPotion And $aCoord[2] >= 1440 And OpenBuildMenu(4) Then
		If BuildMenuUsePotion(2) Then $g_sPetUpgradeTime = ""
	EndIf
	CloseBuildMenu()
	Return True
EndFunc   ;==>PetUpgrade

; BuildMenuCollect hook (pet tab): rows of the page on screen with a hero portrait at x 512-545 (colored, >= 15 of 88 px;
; assigned L.A.S.S.I 45, unassigned Diggy 0 on quazzy 29 Oct) -> $g_asPetAssigned. Never stops the scroll
Func PetAssignedMark($aList)
	_CaptureRegion() ; whole screen once, pixels below read from it
	For $i = 0 To UBound($aList) - 1
		If $aList[$i][8] <> $g_iBuildMenuPage Or Not $aList[$i][7] Then ContinueLoop
		If _ArraySearch($g_asPetAssigned, $aList[$i][3]) >= 0 Then ContinueLoop
		Local $iY = Number($aList[$i][2]) - 7, $iColor = 0
		For $x = 512 To 545 Step 3
			For $y = $iY - 12 To $iY + 11 Step 3
				Local $iPx = Dec(_GetPixelColor($x, $y))
				Local $r = BitShift($iPx, 16), $g = BitAND(BitShift($iPx, 8), 0xFF), $b = BitAND($iPx, 0xFF)
				If _Max(_Max($r, $g), $b) - _Min(_Min($r, $g), $b) > 60 Then $iColor += 1
			Next
		Next
		SetDebugLog("Pet " & $aList[$i][3] & " hero slot colored px: " & $iColor)
		If $iColor >= 15 Then _ArrayAdd($g_asPetAssigned, $aList[$i][3])
	Next
	Return False
EndFunc   ;==>PetAssignedMark

; remember when pet house should be free again ($iMin = lower bound read in Build menu, 0 = unknown)
Func PetSaveBusyTime($iMin)
	If $iMin <= 0 Then $iMin = 120
	$g_sPetUpgradeTime = _DateAdd("n", $iMin, _NowCalc())
	GUICtrlSetData($g_hLbLPetTime, $g_sPetUpgradeTime)
	SetLog("Pet House busy, next check after " & $g_sPetUpgradeTime, $COLOR_INFO)
EndFunc   ;==>PetSaveBusyTime
