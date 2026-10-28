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
; Return [n][5] = [name, recognized (True/False), click x, click y, enough ores (True/False)]
Func BlacksmithReadPage()
	Local $aRet[0][5]
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
	; corner not matched on some rows (quazzy 29 Oct: Fireball y 213, Spiky Ball y 392 missing): a gap of N rows
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
		If StringStripWS($aName[0], 8) = "" Then ContinueLoop ; no row there (list end)
		Local $sName = OcrMatchName($aName[0], $aNames)
		Local $bMatched = (@extended = 1)
		; red ore cost text = not enough ores
		Local $bEnough = Not _PixelSearch(823, $iY + 9, 823, $iY + 35, Hex(0xFF7B72, 6), 20, True, "EnoughOres")
		; locked row ("Upgrade Blacksmith to Level N", padlock, no ore cost) also has the corner: no blue Shiny Ore icon (quazzy 29 Oct)
		If $bEnough And Not _PixelSearch(828, $iY - 5, 852, $iY + 45, Hex(0x18A8E8, 6), 30, True, "OreIcon") Then
			SetDebugLog("Equipment row " & $sName & ": locked (no ore cost)")
			$bEnough = False
		EndIf
		Local $aAdd[1][5] = [[$sName, $bMatched, $iX - 50, $iY + 10, $bEnough]]
		_ArrayAdd($aRet, $aAdd)
	Next
	Return $aRet
EndFunc   ;==>BlacksmithReadPage

; first equipment of the order that can be upgraded. Pages are read until all wanted names are seen (max 3 pages),
; then the best one is searched again on its page. Return [name, recognized, x, y, enough] or 0
Func BlacksmithFindWanted(ByRef $aWanted)
	Local $aAll[0][6], $sLastSig = ""
	For $iPage = 1 To 3
		If Not $g_bRunState Then Return 0
		If $iPage > 1 Then BuildMenuScrollDown()
		Local $aPage = BlacksmithReadPage()
		Local $sSig = ""
		For $i = 0 To UBound($aPage) - 1
			$sSig &= $aPage[$i][0] & "|"
		Next
		If $iPage > 1 And $sSig = $sLastSig Then ExitLoop ; list did not move: end reached
		$sLastSig = $sSig
		SetLog("Equipment List (page " & $iPage & "):", $COLOR_INFO)
		For $i = 0 To UBound($aPage) - 1
			SetLog(" - " & ($aPage[$i][1] ? $aPage[$i][0] : "? '" & $aPage[$i][0] & "'") & ($aPage[$i][4] ? "" : " (not enough ores)"), $COLOR_DEBUG)
			Local $aAdd[1][6] = [[$aPage[$i][0], $aPage[$i][1], $aPage[$i][2], $aPage[$i][3], $aPage[$i][4], $g_iBuildMenuPage]]
			_ArrayAdd($aAll, $aAdd)
		Next
		Local $bAllSeen = True
		For $sWant In $aWanted
			If _ArraySearch($aAll, $sWant, 0, 0, 0, 0, 1, 0) < 0 Then $bAllSeen = False
		Next
		If $bAllSeen Then ExitLoop
	Next

	For $sWant In $aWanted
		For $i = 0 To UBound($aAll) - 1
			If Not $aAll[$i][1] Or $aAll[$i][0] <> $sWant Then ContinueLoop
			If Not $aAll[$i][4] Then
				SetLog($sWant & ": not enough ores", $COLOR_DEBUG1)
				ExitLoop
			EndIf
			SetLog("Equipment priority: " & $sWant, $COLOR_SUCCESS)
			; on another page: go back to it and read the row position again
			While $g_iBuildMenuPage > $aAll[$i][5]
				BuildMenuScrollUp()
			WEnd
			If $g_iBuildMenuPage <> $aAll[$i][5] Then Return 0
			Local $aPage = BlacksmithReadPage()
			For $j = 0 To UBound($aPage) - 1
				If $aPage[$j][1] And $aPage[$j][0] = $sWant And $aPage[$j][4] Then
					Local $aRet[5] = [$aPage[$j][0], $aPage[$j][1], $aPage[$j][2], $aPage[$j][3], $aPage[$j][4]]
					Return $aRet
				EndIf
			Next
			SetLog($sWant & ": row not found again", $COLOR_WARNING)
			Return 0
		Next
	Next
	Return 0
EndFunc   ;==>BlacksmithFindWanted

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
