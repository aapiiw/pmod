; #FUNCTION# ====================================================================================================================
; Name ..........: TreasuryCollect
; Description ...:
; Syntax ........: TreasuryCollect()
; Parameters ....:
; Return values .: None
; Author ........: MonkeyHunter (09-2016)
; Modified ......: Boju (02-2017), Fliegerfaust(11-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func TreasuryCollect()
	If Not $g_bChkTreasuryCollect Then Return
	SetLog("Check for Treasury collect", $COLOR_INFO)
	If isGoldFull() And IsElixirFull() Then Return
	If _Sleep(50) Then Return
	If Not $g_bRunState Then Return 
	Local $CCFound = False
	Local $TryCCAutoLocate = False
	If Int($g_aiClanCastlePos[0]) < 1 Or Int($g_aiClanCastlePos[1]) < 1 Then
		If Not CheckZoomOut(False, True) Then ZoomOut()
		$TryCCAutoLocate = True
	Else
		; saved position first: a Clan Castle there needs no zoom check (stone search failed after attacks, ~5-20 s with
		; zoom and drag: qruel/qarelith 28 Oct). Another building selected: zoom out, then the saved position again
		Local $BuildingInfo
		For $iTry = 1 To 2
			Click($g_aiClanCastlePos[0], $g_aiClanCastlePos[1])
			If _Sleep(1000) Then Return
			$BuildingInfo = BuildingInfo(290, 477)
			If $BuildingInfo[1] = "Clan Castle" Or $iTry = 2 Then ExitLoop
			ClickAway()
			If _Sleep(300) Then Return
			; ZoomOut also centers the village: CheckZoomOut passed at zoom 1.03 / offset 8,-4 and the 2nd click hit the
			; Wall next to the Clan Castle again (qurlk 28 Oct 19:49, auto locate failed, Treasury skipped 6 h)
			ZoomOut()
		Next
		$TryCCAutoLocate = ($BuildingInfo[1] <> "Clan Castle")
	EndIf
	
	If $TryCCAutoLocate Then
		; TH17+ Clan Castle is not found by the images: ~12 s and 4-5 clicks on other buildings every cycle (Oct 2026), try every 6 h
		Local $hFail = $g_ahCCLocateFailTimer[CurAccountIndex()]
		If $hFail <> 0 And __TimerDiff($hFail) < 6 * 3600000 Then
			SetLog("Clan Castle auto locate failed before, skip Treasury (locate it manually)", $COLOR_DEBUG2)
			ClickAway()
			Return
		EndIf
		If Int($g_aiClanCastlePos[0]) > 0 And Int($g_aiClanCastlePos[1]) > 0 Then $CCFound = NearCCLocate()
		If Not $CCFound Then $CCFound = AutoLocateCC()
		If $CCFound Then
			$g_ahCCLocateFailTimer[CurAccountIndex()] = 0
			applyConfig()
			saveConfig()
		Else
			$g_ahCCLocateFailTimer[CurAccountIndex()] = __TimerInit()
			SetLog("TryCCAutoLocate Failed, please locate manually", $COLOR_DEBUG2)
			Return
		EndIf
	EndIf
	
	If $g_bEnableCCSleep Then
		SetCCSleep()
	EndIf
	
	If Not ClickB("Treasury") Then 
		SetLog("Treasury Button not found!", $COLOR_DEBUG2)
		ClickAway()
		If _Sleep(50) Then Return
		Return
	EndIf
	
	If _Sleep(500) Then Return
	
	If Not _WaitForCheckPixel($aTreasuryWindow, $g_bCapturePixel, Default, "Wait treasury window:") Then
		SetLog("Treasury window not found!", $COLOR_DEBUG2)
		ClickAway()
		If _Sleep(50) Then Return
		Return
	EndIf

	Local $aCollectButton = findButton("Collect", Default, 1, True)
	If IsArray($aCollectButton) And UBound($aCollectButton, 1) = 2 Then
		ClickP($aCollectButton, 1, 0, "#0330")
		If _Sleep(1000) Then Return
		If IsOKCancelPage(True) Then ; Click Okay to confirm collect treasury loot
			Click($aConfirmSurrender[0], $aConfirmSurrender[1])
			SetLog("Treasury collected successfully.", $COLOR_SUCCESS)
		Else
			SetLog("Cannot Click Okay Button on Treasury Collect screen", $COLOR_DEBUG2)
		EndIf
	Else
		SetDebugLog("Error in TreasuryCollect(): Cannot find the Collect Button", $COLOR_DEBUG2)
		ClickAway()
	EndIf
	
	ClickAway()
	If _Sleep(500) Then Return
	ClickAway()
	If _Sleep(500) Then Return
EndFunc   ;==>TreasuryCollect

; saved CC position hits a building next to it (Oct 2026: qurlk saved 426,307 = Wall, CC at 455,340; TH17+ CC is
; not found by the images): try around the saved position, the Clan Castle stays selected when found
Func NearCCLocate()
	Local $aOffset[8][2] = [[30, 30], [-30, -30], [30, -30], [-30, 30], [0, 35], [0, -35], [35, 0], [-35, 0]]
	Local $x, $y, $aInfo
	For $i = 0 To UBound($aOffset) - 1
		$x = $g_aiClanCastlePos[0] + $aOffset[$i][0]
		$y = $g_aiClanCastlePos[1] + $aOffset[$i][1]
		If Not isInsideDiamondXY($x, $y) Then ContinueLoop
		ClickAway()
		If _Sleep(500) Then Return False
		Click($x, $y)
		If _Sleep(1000) Then Return False
		$aInfo = BuildingInfo(290, 477)
		If $aInfo[1] = "Clan Castle" Then
			SetLog("Clan Castle found near saved position, new CC Coords : " & $x & "," & $y, $COLOR_INFO)
			$g_aiClanCastlePos[0] = $x
			$g_aiClanCastlePos[1] = $y
			Return True
		EndIf
	Next
	ClickAway()
	Return False
EndFunc   ;==>NearCCLocate

Func AutoLocateCC()
	Local $CCFound = False
	SetLog("Try to Auto Locate Clan Castle", $COLOR_INFO)
	ClickAway()
	
	Local $ClanCastleCoord = QuickMIS("CNX", $g_sImgClanCastle)
	If IsArray($ClanCastleCoord) And UBound($ClanCastleCoord) > 0 Then
		_ArraySort($ClanCastleCoord, 1, 0, 0, 3)
		For $i = 0 To UBound($ClanCastleCoord) - 1
			SetDebugLog("CC candidate " & $ClanCastleCoord[$i][0] & "_" & $ClanCastleCoord[$i][3] & " at " & $ClanCastleCoord[$i][1] & "," & $ClanCastleCoord[$i][2])
			If Not isInsideDiamondXY($ClanCastleCoord[$i][1], $ClanCastleCoord[$i][2]) Then ContinueLoop
			If StringInStr($ClanCastleCoord[$i][0], "Full") Then 
				Click($ClanCastleCoord[$i][1], $ClanCastleCoord[$i][2] + 30)
			Else
				Click($ClanCastleCoord[$i][1] + 10, $ClanCastleCoord[$i][2] + 10)
			EndIf
			
			If _Sleep(1000) Then Return
			Local $BuildingInfo = BuildingInfo(290, 477)
			If $BuildingInfo[1] = "Clan Castle" Then 
				$g_aiClanCastlePos[0] = $ClanCastleCoord[$i][1] + 10
				$g_aiClanCastlePos[1] = $ClanCastleCoord[$i][2] + 10
				SetLog("Found Clan Castle Lvl " & $BuildingInfo[2] & ", save as CC Coords : " & $g_aiClanCastlePos[0] & "," & $g_aiClanCastlePos[1], $COLOR_INFO)
				$CCFound = True
				ExitLoop
			Else
				SetLog("Not ClanCastle, its a " & $BuildingInfo[1], $COLOR_DEBUG1)
				ClickAway()
			EndIf
			If _Sleep(500) Then Return
		Next
	EndIf
	Return $CCFound
EndFunc

Func SetCCSleep()
	SetDebugLog("Check: Set Clan Castle")
	Local $aCCDefense = findButton("CCGuard")
	If IsArray($aCCDefense) And UBound($aCCDefense, 1) = 2 Then
		SetLog("Set Clan Castle to Sleep Mode", $COLOR_INFO)
		ClickP($aCCDefense)
	Else
		Local $aCCSleep = findButton("CCSleep")
		If IsArray($aCCSleep) And UBound($aCCSleep, 1) = 2 Then
			SetLog("Clan Castle already on Sleep Mode", $COLOR_INFO)
		EndIf
	EndIf
EndFunc
