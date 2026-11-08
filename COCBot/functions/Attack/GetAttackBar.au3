
Func DragAttackBar($iTotalSlot = 20, $bBack = False)
	If $g_iTotalAttackSlot > 10 Then $iTotalSlot = $g_iTotalAttackSlot
	Local $bAlreadyDrag = False

	If Not $bBack Then
		SetDebugLog("Dragging attack troop bar to 2nd page. Distance = " & $iTotalSlot - 9 & " slots")
		ClickDrag(25 + 73 * ($iTotalSlot - 9), 620, 25, 620, 1000)
		If _Sleep(1000 + $iTotalSlot * 25) Then Return
		$bAlreadyDrag = True
	Else
		SetDebugLog("Dragging attack troop bar back to 1st page. Distance = " & $iTotalSlot - 9 & " slots")
		ClickDrag(25, 620, 25 + 73 * ($iTotalSlot - 9), 620, 1000)
		If _Sleep(800 + $iTotalSlot * 25) Then Return
		$bAlreadyDrag = False
	EndIf

	$g_bDraggedAttackBar = $bAlreadyDrag
	$g_iCSVLastTroopPositionDropTroopFromINI = -1 ; after drag attack bar, need to clear last troop selected
	Return $bAlreadyDrag
EndFunc   ;==>DragAttackBar

Func GetAttackBar($bRemaining = False, $pMatchMode = $DB, $bDebug = False)
	Local Static $aAttackBar[0][8]
	Local $iAmount = 0, $sColor = "", $xOCR = 0
	
	;Reset variables if GetAttackBar is not for Remaining
	If Not $bRemaining Then
		Local $aDummyArray[0][8]
		$aAttackBar = $aDummyArray
		$g_iLSpellLevel = 1
		$g_iESpellLevel = 1
		$g_iSiegeLevel = 1
	EndIf
	
	Local $sKeepRemainTroops = "(King)|(Queen)|(Warden)|(Champion)|(MinionP)|(Duke)|(WallW)|(BattleB)|(StoneS)|(SiegeB)|(LogL)|(FlameF)|(BattleD)|(TroopL)|(SkyW)"
	Local $sKeepSieges = "(WallW)|(BattleB)|(StoneS)|(SiegeB)|(LogL)|(FlameF)|(BattleD)|(TroopL)|(SkyW)"

	If Not $g_bRunState Then Return
	Local $iStart = __TimerInit()
	If Not $bRemaining Then
		Local $aArmy = QuickMIS("CNX", $g_sImgAttackBarDir, 0, 590, 860, 660); search army image on attackbar
		If IsArray($aArmy) and UBound($aArmy) > 0 Then
			_ArraySort($aArmy, 0, 0, 0, 1)
			For $i = 0 To UBound($aArmy) - 1
				$iAmount = 0
				$sColor = ""
				If StringRegExp($aArmy[$i][0], $sKeepRemainTroops, 0) Then 
					$iAmount = 1
					$xOCR = $aArmy[$i][1]
					$sColor = _GetPixelColor($xOCR - 20, 569, True)
				Else
					If QuickMIS("BFI", $g_sImgAttackBarDir & "\AmountX*", $aArmy[$i][1] - 30, 580, $aArmy[$i][1] + 40, 610) Then ;search x image
						$xOCR = $g_iQuickMISX
						$iAmount = getTroopCount($xOCR, 580)
						; count not read once (Oct 2026: 4 Rage Spells never used): read again, the x is there so at least 1
						If Number($iAmount) < 1 Then $iAmount = getTroopCount($xOCR, 578)
						If Number($iAmount) < 1 Then $iAmount = getTroopCount($xOCR - 2, 582)
						If Number($iAmount) < 1 Then
							SetDebugLog($aArmy[$i][0] & " amount not read, use 1")
							$iAmount = 1
						EndIf
						$sColor = _GetPixelColor($xOCR - 20, 587, True)
					Else
						; no amount x: not a troop slot (image matched something else, e.g. "0 Pumpkin Barbarian")
						SetDebugLog($aArmy[$i][0] & " x not found" & ($aArmy[$i][0] = "Castle" ? "" : ", not added"))
						If $aArmy[$i][0] <> "Castle" Then ContinueLoop
					EndIf
				EndIf
				Local $aTemp[1][8] = [[$aArmy[$i][0], $aArmy[$i][1], $aArmy[$i][2], $i, $iAmount, $xOCR, 580, $sColor]]
				_ArrayAdd($aAttackBar, $aTemp)
			Next
		Else
			SetLog("Error in GetAttackBar(): Search did not return any results!", $COLOR_ERROR)
		EndIf
	EndIf
	
	SetDebugLog("GetAttackBar(): Finished Image Search in: " & StringFormat("%.2f", __TimerDiff($iStart)) & " ms")
	#comments-start
		$aAttackBar[n][8]
		[n][0] = Name of the found Troop/Spell/Hero/Siege
		[n][1] = The X Coordinate of the Troop/Spell/Hero/Siege
		[n][2] = The Y Coordinate of the Troop/Spell/Hero/Siege
		[n][3] = The Slot Number (Starts with 0)
		[n][4] = The Amount
		[n][5] = The X Coordinate of the x beside the Amount
		[n][6] = The Y Coordinate of the x beside the Amount
		[n][7] = The Color on Troop Header
	#comments-end

	Local $aFinalAttackBar[0][9]
	If $bRemaining Then $g_iRemainSiege = -1
	For $i = 0 To UBound($aAttackBar) - 1
		Local $bRemoved = False
		If Not $g_bRunState Then Return
		If _Sleep(10) Then Return
		
		If $bRemaining Then
			If StringRegExp($aAttackBar[$i][0], $sKeepRemainTroops, 0) Then ;Special troops
				$sColor = _GetPixelColor($aAttackBar[$i][5] - 20, 569, True)
				If _ColorCheck($sColor, $aAttackBar[$i][7], 30, Default, $aAttackBar[$i][0]) Then
					$aAttackBar[$i][4] = 1
					SetDebugLog("GetAttackBar(): Special Troop:  " & GetTroopName(TroopIndexLookup($aAttackBar[$i][0], "", True)) & " deploy failed?")
					UpdateSpecialTroops(TroopIndexLookup($aAttackBar[$i][0], "", True), False)
					If StringRegExp($aAttackBar[$i][0], $sKeepSieges, 0) Then $g_iRemainSiege = TroopIndexLookup($aAttackBar[$i][0], "", True)
				Else
					UpdateSpecialTroops(TroopIndexLookup($aAttackBar[$i][0], "", True), True)
					SetDebugLog("GetAttackBar(): Special Troop:  " & GetTroopName(TroopIndexLookup($aAttackBar[$i][0], "", True)) & " deployed successfully")
				EndIf
			Else
				$sColor = _GetPixelColor($aAttackBar[$i][5] - 20, 587, True)
				If _ColorCheck($sColor, $aAttackBar[$i][7], 30, Default, $aAttackBar[$i][0]) Then
					$aAttackBar[$i][4] = getTroopCount($aAttackBar[$i][5], 578)
					If $aAttackBar[$i][4] = "111" Then $aAttackBar[$i][4] = 10
					SetDebugLog("GetAttackBar(): Troop " & GetTroopName(TroopIndexLookup($aAttackBar[$i][0], "", True)) & " already deployed, but stay")
					SetDebugLog($aAttackBar[$i][0] & " update amount: " & $aAttackBar[$i][4])
				Else
					$bRemoved = True
					SetDebugLog("GetAttackBar(): Troop " & GetTroopName(TroopIndexLookup($aAttackBar[$i][0], "", True)) & " already deployed, now removed")
					ContinueLoop
				EndIf
			EndIf
		EndIf
	
		If StringRegExp($aAttackBar[$i][0], $sKeepRemainTroops, 0) Then
			If Not $bRemoved Then $aAttackBar[$i][4] = 1
			If StringRegExp($aAttackBar[$i][0], $sKeepSieges, 0) Then
				$g_iSiegeLevel = Number(getTroopsSpellsLevel(Number($aAttackBar[$i][1]) - 50, 645))
				If $g_iSiegeLevel = "" Then $g_iSiegeLevel = 1
				SetDebugLog($aAttackBar[$i][0] & " Level: " & $g_iSiegeLevel)
			EndIf
		Else
			If StringRegExp($aAttackBar[$i][0], "(LSpell)", 0) And $g_bSmartZapEnable Then
				Local $iLSpellLevel = Number(getTroopsSpellsLevel(Number($aAttackBar[$i][1]) - 30, 645))
				SetDebugLog("LSpell Level:" & $iLSpellLevel)
				If $iLSpellLevel > 0 And $iLSpellLevel <= 9 Then $g_iLSpellLevel = $iLSpellLevel
			ElseIf StringRegExp($aAttackBar[$i][0], "(ESpell)", 0) And $g_bEarthQuakeZap Then
				Local $iESpellLevel = Number(getTroopsSpellsLevel(Number($aAttackBar[$i][1]) - 30, 645))
				SetDebugLog("ESpell Level:" & $iESpellLevel)
				If $iESpellLevel > 0 And $iESpellLevel <= 5 Then $g_iESpellLevel = $iESpellLevel
			EndIf
		EndIf
		; 0: Index, 1: Slot, 2: Amount, 3: X-Coord, 4: Y-Coord, 5: OCR X-Coord, 6: OCR Y-Coord, 7: TroopName, 8: ColorBar
		Local $aTempFinalArray[1][9] = [[TroopIndexLookup($aAttackBar[$i][0], "", True), $aAttackBar[$i][3], $aAttackBar[$i][4], $aAttackBar[$i][1], $aAttackBar[$i][2], _
										$aAttackBar[$i][5], $aAttackBar[$i][6], GetTroopName(TroopIndexLookup($aAttackBar[$i][0], "", True)), $aAttackBar[$i][7]]]
		_ArrayAdd($aFinalAttackBar, $aTempFinalArray)
	Next
	
	_ArraySort($aFinalAttackBar, 0, 0, 0, 1) ; Sort Final Array by Slot Number
	Return $aFinalAttackBar

EndFunc   ;==>GetAttackBar
