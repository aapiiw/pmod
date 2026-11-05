; #FUNCTION# ====================================================================================================================
; Name ..........: Blacksmith
; Description ...: Hero Equipment upgrade from Build menu, tab 3 "Blacksmith" (no Blacksmith location needed)
; Author ........:
; Modified ......: xbebenk (Feb 2024)
; Remarks .......: This file is part of MyBot Copyright 2015-2024
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: Returns True when at least one equipment was upgraded
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......:
; ===============================================================================================================================

; Equipment Upgrade order of the GUI is kept: enabled equipments are tried in that order, up to 5 upgrades per run.
Func Blacksmith($bTest = False)
	If Not $g_bRunState Then Return False
	If $g_iTownHallLevel > 0 And $g_iTownHallLevel < 8 Then Return False
	If Not $g_bChkCustomEquipmentOrderEnable Then Return False
	Local $aWanted = BlacksmithWantedList()
	If UBound($aWanted) = 0 Then
		SetLog("No Equipment enabled in Equipment Upgrade order, check Hero Equipment settings!", $COLOR_ERROR)
		Return False
	EndIf

	checkMainScreen(False)
	SetLog("Checking for Equipment upgrade", $COLOR_INFO)
	Local $iUpgraded = 0
	For $iTry = 1 To 5
		If Not $g_bRunState Then ExitLoop
		If $iTry > 1 Then CloseBuildMenu() ; list back on top after an upgrade
		If Not BlacksmithOpenTab() Then ExitLoop
		Local $iShiny = OresReport()
		If $g_bChkMinOreUpgrade And $iShiny < Number($g_sTxtMinOreUpgrade) Then
			SetLog("Shiny Ore " & _NumberFormat($iShiny) & " < " & _NumberFormat($g_sTxtMinOreUpgrade) & ", skip Equipment upgrade", $COLOR_INFO)
			ExitLoop
		EndIf
		Local $aRow = BlacksmithFindWanted($aWanted)
		If Not IsArray($aRow) Then
			If $iUpgraded = 0 Then SetLog("No Equipment of the order to upgrade (not found / not enough ores)", $COLOR_INFO)
			ExitLoop
		EndIf
		If $bTest Then
			SetLog("[test] Equipment to upgrade: " & $aRow[0] & ", not clicked", $COLOR_DEBUG)
			ExitLoop
		EndIf
		If Not BlacksmithUpgradeRow($aRow) Then ExitLoop
		$iUpgraded += 1
	Next
	If IsBuildMenuOpen() Then BlacksmithSetFilter("") ; game keeps the hero filter: leave the list unfiltered
	CloseBuildMenu()
	Return $iUpgraded > 0
EndFunc   ;==>Blacksmith

; open Build menu tab 3 and check the Blacksmith title
Func BlacksmithOpenTab()
	If Not OpenBuildMenu(3) Then Return False
	If QuickMIS("BC1", $g_sImgEquipmentMenu, 650, 13, 680, 30) Then Return True
	SetLog("Blacksmith tab not found in Build menu", $COLOR_WARNING)
	CloseBuildMenu()
	Return False
EndFunc   ;==>BlacksmithOpenTab

; names of the enabled equipments, in GUI order
Func BlacksmithWantedList()
	Local $aRet[0]
	For $i = 0 To UBound($g_bChkCustomEquipmentOrder) - 1
		If Not $g_bChkCustomEquipmentOrder[$i] Or $g_aiCmbCustomEquipmentOrder[$i] < 0 Then ContinueLoop
		If _ArraySearch($aRet, $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0]) >= 0 Then ContinueLoop
		_ArrayAdd($aRet, $g_asEquipmentOrderList[$g_aiCmbCustomEquipmentOrder[$i]][0])
	Next
	Return $aRet
EndFunc   ;==>BlacksmithWantedList

; visible rows of Blacksmith tab. A row is found by its corner mark at the right side.
; Return [n][6] = [name, recognized (True/False), click x, click y, enough ores (True/False), equipped (True/False)]
Func BlacksmithReadPage()
	Local $aRet[0][6]
	Static $aNames = 0
	If Not IsArray($aNames) Then
		Local $aTmp[UBound($g_asEquipmentOrderList)]
		For $i = 0 To UBound($g_asEquipmentOrderList) - 1
			$aTmp[$i] = $g_asEquipmentOrderList[$i][0]
		Next
		$aNames = $aTmp
	EndIf
	Local $aCorner = QuickMIS("CNX", $g_sImgEquipmentCorner, 845, 50, 860, 535)
	If Not IsArray($aCorner) Or UBound($aCorner) = 0 Then Return $aRet
	RemoveDupCNX($aCorner, 2, 10)
	For $i = 0 To UBound($aCorner) - 1 ; y as number: sorted as text 93 came after 511
		$aCorner[$i][2] = Number($aCorner[$i][2])
	Next
	_ArraySort($aCorner, 0, 0, 0, 2)
	; corner not matched on some rows (29 Oct: Fireball y 213, Spiky Ball y 392 missing): a gap of N rows
	; (59.7 px each, +-6) between 2 found corners gets the rows in between; section headers break the step, no fill there
	Local $iX = Number($aCorner[0][1]), $aY[0]
	For $i = 0 To UBound($aCorner) - 1
		If $i > 0 Then
			Local $iGap = Number($aCorner[$i][2]) - Number($aCorner[$i - 1][2]), $iRows = Round($iGap / 59.7)
			If $iRows >= 2 And Abs($iGap - $iRows * 59.7) <= 6 Then
				For $k = 1 To $iRows - 1
					_ArrayAdd($aY, Round(Number($aCorner[$i - 1][2]) + $k * $iGap / $iRows))
				Next
			EndIf
		EndIf
		_ArrayAdd($aY, Number($aCorner[$i][2]))
	Next
	For $i = 0 To UBound($aY) - 1
		If Not $g_bRunState Then Return $aRet
		Local $iY = $aY[$i]
		Local $aName = getBuildingName(597, $iY + 6, 180)
		If StringStripWS($aName[0], 8) = "" Then ; new equipment: green name (Vampstache on 29 Oct, ~B4F050)
			$g_bOcrGreenText = True
			$aName = getBuildingName(597, $iY + 6, 180)
			$g_bOcrGreenText = False
		EndIf
		If StringStripWS($aName[0], 8) = "" Then ContinueLoop ; no row there (list end)
		Local $sName = OcrMatchName($aName[0], $aNames)
		Local $bMatched = (@extended = 1)
		; red ore cost text = not enough ores
		Local $bEnough = Not _PixelSearch(823, $iY + 9, 823, $iY + 35, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
		; locked row ("Upgrade Blacksmith to Level N", padlock, no ore cost) also has the corner: no blue Shiny Ore icon (29 Oct)
		If $bEnough And Not _PixelSearch(828, $iY - 5, 852, $iY + 45, Hex(0x18A8E8, 6), 30, True, "OreIcon") Then
			SetDebugLog("Equipment row " & $sName & ": locked (no ore cost)")
			$bEnough = False
		EndIf
		; equipped = colored hero portrait left of the equipment, unequipped = grey (29 Oct: 79-109 / 14 colored px)
		Local $bEquipped = BlacksmithColorCount(512, $iY - 5, 545, $iY + 35) >= 40
		Local $aAdd[1][6] = [[$sName, $bMatched, $iX - 50, $iY + 10, $bEnough, $bEquipped]]
		_ArrayAdd($aRet, $aAdd)
	Next
	Return $aRet
EndFunc   ;==>BlacksmithReadPage

; first equipment of the order that can be upgraded. The in-game hero filter shows only the equipments of one hero
; (1-2 pages instead of 6+ for 43 equipments): each hero of the order is read once, in order of its first equipment.
; Return [name, recognized, x, y, enough, equipped] or 0
Func BlacksmithFindWanted(ByRef $aWanted)
	Local $aAll[0][8], $sHeroNow = "#", $sHeroesRead = "|"
	For $sWant In $aWanted
		If Not $g_bRunState Then Return 0
		Local $sHero = BlacksmithHeroOf($sWant)
		If Not StringInStr($sHeroesRead, "|" & $sHero & "|") Then
			If Not BlacksmithSetFilter($sHero) Then $sHero = "" ; filter not set: whole list
			$sHeroNow = $sHero
			$sHeroesRead &= $sHero & "|"
			BlacksmithReadHero($aAll, $sHero, $sHero = "" ? 8 : 3)
		EndIf
		Local $i = _ArraySearch($aAll, $sWant, 0, 0, 0, 0, 1, 0)
		If $i < 0 Or Not $aAll[$i][1] Then
			SetDebugLog($sWant & ": not in the list (not unlocked yet?)")
			ContinueLoop
		EndIf
		If Not $aAll[$i][4] Then
			SetLog($sWant & ": not enough ores or locked", $COLOR_DEBUG1)
			ContinueLoop
		EndIf
		If $g_bChkEquippedOnly And Not $aAll[$i][5] Then
			SetLog($sWant & ": not equipped, skip (Only Equipped)", $COLOR_DEBUG1)
			ContinueLoop
		EndIf
		SetLog("Equipment priority: " & $sWant, $COLOR_SUCCESS)
		; another hero filtered now: filter this one again (list back on page 1)
		If $sHeroNow <> $aAll[$i][7] Then
			If Not BlacksmithSetFilter($aAll[$i][7]) Then Return 0
			$sHeroNow = $aAll[$i][7]
		EndIf
		While $g_iBuildMenuPage > $aAll[$i][6]
			BuildMenuScrollUp()
		WEnd
		While $g_iBuildMenuPage < $aAll[$i][6]
			BuildMenuScrollDown()
		WEnd
		Local $aPage = BlacksmithReadPage()
		For $j = 0 To UBound($aPage) - 1
			If $aPage[$j][1] And $aPage[$j][0] = $sWant And $aPage[$j][4] Then
				Local $aRet[6] = [$aPage[$j][0], $aPage[$j][1], $aPage[$j][2], $aPage[$j][3], $aPage[$j][4], $aPage[$j][5]]
				Return $aRet
			EndIf
		Next
		SetLog($sWant & ": row not found again", $COLOR_WARNING)
		Return 0
	Next
	Return 0
EndFunc   ;==>BlacksmithFindWanted

; read the (filtered) list from page 1 until it does not move; rows go to $aAll [.., page, hero]
Func BlacksmithReadHero(ByRef $aAll, $sHero, $iMaxPage)
	Local $sLastSig = ""
	For $iPage = 1 To $iMaxPage
		If Not $g_bRunState Then Return
		If $iPage > 1 Then BuildMenuScrollDown()
		Local $aPage = BlacksmithReadPage()
		Local $sSig = ""
		For $i = 0 To UBound($aPage) - 1
			$sSig &= $aPage[$i][0] & "|"
		Next
		If $iPage > 1 And $sSig = $sLastSig Then ExitLoop ; list did not move: end reached
		$sLastSig = $sSig
		SetLog("Equipment List " & ($sHero = "" ? "" : $sHero & " ") & "(page " & $iPage & "):", $COLOR_INFO)
		For $i = 0 To UBound($aPage) - 1
			SetLog(" - " & ($aPage[$i][1] ? $aPage[$i][0] : "? '" & $aPage[$i][0] & "'") & ($aPage[$i][5] ? " (equipped)" : "") & ($aPage[$i][4] ? "" : " (not enough ores / locked)"), $COLOR_DEBUG)
			If _ArraySearch($aAll, $aPage[$i][0], 0, 0, 0, 0, 1, 0) >= 0 Then ContinueLoop
			Local $aAdd[1][8] = [[$aPage[$i][0], $aPage[$i][1], $aPage[$i][2], $aPage[$i][3], $aPage[$i][4], $aPage[$i][5], $g_iBuildMenuPage, $sHero]]
			_ArrayAdd($aAll, $aAdd)
		Next
		If UBound($aPage) < 7 Then ExitLoop ; short page = whole (filtered) list seen
	Next
EndFunc   ;==>BlacksmithReadHero

; hero of an equipment name ("King", "Queen", "Prince", "Warden", "Champion", "Duke"), "" when unknown
Func BlacksmithHeroOf($sName)
	For $i = 0 To UBound($g_asEquipmentOrderList) - 1
		If $g_asEquipmentOrderList[$i][0] = $sName Then Return $g_asEquipmentOrderList[$i][2]
	Next
	Return ""
EndFunc   ;==>BlacksmithHeroOf

; in-game hero filter of the Blacksmith tab ($sHero "" = no filter). Filter button 540,24 opens the hero row (y 167),
; heroes toggle (several can be on, selected = yellow at y 112), the button closes it again. The list goes back to the top.
Func BlacksmithSetFilter($sHero)
	Local $aHero[6][2] = [["King", 181], ["Queen", 250], ["Prince", 318], ["Warden", 386], ["Champion", 454], ["Duke", 522]]
	Local $bActive = _ColorCheck(_GetPixelColor(540, 24, True), Hex(0xF3B52E, 6), 30) ; button yellow = some hero filtered
	If $sHero = "" And Not $bActive Then Return True
	Click(540, 24, 1, 0, "Blacksmith filter")
	If _Sleep(700) Then Return False
	; popup open: every hero slot top is yellow (selected) or brown
	If Not _ColorCheck(_GetPixelColor(181, 112, True), Hex(0xE69F1D, 6), 30) And Not _ColorCheck(_GetPixelColor(181, 112, True), Hex(0x9B724F, 6), 30) Then
		SetLog("Blacksmith hero filter did not open", $COLOR_WARNING)
		Return False
	EndIf
	For $i = 0 To UBound($aHero) - 1
		Local $bOn = _ColorCheck(_GetPixelColor($aHero[$i][1], 112, True), Hex(0xE69F1D, 6), 30)
		If $bOn <> ($aHero[$i][0] = $sHero) Then
			Click($aHero[$i][1], 167, 1, 0, "Filter " & $aHero[$i][0])
			If _Sleep(400) Then Return False
		EndIf
	Next
	Click(540, 24, 1, 0, "Close Blacksmith filter")
	If _Sleep(700) Then Return False
	$g_iBuildMenuPage = 1
	SetDebugLog("Blacksmith filter: " & ($sHero = "" ? "none" : $sHero))
	Return True
EndFunc   ;==>BlacksmithSetFilter

; colored pixels (max - min channel > 60) in a box, step 3, on a fresh capture
Func BlacksmithColorCount($x1, $y1, $x2, $y2)
	_CaptureRegion($x1, $y1, $x2 + 1, $y2 + 1)
	Local $iCount = 0
	For $x = 0 To $x2 - $x1 Step 3
		For $y = 0 To $y2 - $y1 Step 3
			Local $iPx = Dec(_GetPixelColor($x, $y))
			Local $r = BitShift($iPx, 16), $g = BitAND(BitShift($iPx, 8), 0xFF), $b = BitAND($iPx, 0xFF)
			If _Max(_Max($r, $g), $b) - _Min(_Min($r, $g), $b) > 60 Then $iCount += 1
		Next
	Next
	Return $iCount
EndFunc   ;==>BlacksmithColorCount

; click the equipment row, upgrade in the upgrade window
Func BlacksmithUpgradeRow(ByRef $aRow)
	Click($aRow[2], $aRow[3], 1, 0, "Equipment " & $aRow[0])
	If _Sleep(1000) Then Return False
	If Not IsUpgradeWindowOpen() Then
		SetLog($aRow[0] & ": upgrade window not open", $COLOR_WARNING)
		Return False
	EndIf
	Click(700, 540, 1, 0, "Upgrade " & $aRow[0])
	If _Sleep(2000) Then Return False
	If isGemOpen(True) Then
		SetLog($aRow[0] & ": upgrade needs gems, skip", $COLOR_ERROR)
		ClickAway()
		Return False
	EndIf
	Click(795, 460, 1, 0, "Confirm upgrade")
	If _Sleep(2000) Then Return False
	Click(810, 105, 1, 0, "Close upgrade window")
	If _Sleep(1000) Then Return False
	SetLog("Equipment upgraded: " & $aRow[0], $COLOR_SUCCESS)
	Return True
EndFunc   ;==>BlacksmithUpgradeRow

; ores shown top center while the Blacksmith tab is open. Return Shiny Ore
Func OresReport()
	Local $sShiny = getResourcesMainScreen(350, 22)
	Local $sGlowy = getResourcesMainScreen(350, 59)
	Local $sStarry = getResourcesMainScreen(350, 96)
	SetLog("[Shiny]: " & $sShiny & " [Glowy]: " & $sGlowy & " [Starry]: " & $sStarry, $COLOR_DEBUG)
	Return Number(StringReplace($sShiny, " ", ""))
EndFunc   ;==>OresReport
