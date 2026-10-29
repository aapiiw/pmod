; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseReport()
; Description ...: Make Resources report of Builders Base
; Syntax ........: BuilderBaseReport()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (05-2017)
; Modified ......: xbebenk (08-2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BuilderBaseReport($bBypass = False, $bSetLog = True); $CheckBH = True)
	Switch $bBypass
		Case False
			If $bSetLog Then SetLog("Builder Base Report", $COLOR_INFO)
		Case True
			If $bSetLog Then SetLog("Updating Builder Base Resource Values", $COLOR_INFO)
	EndSwitch

	getBuilderCount($bSetLog, True) ; update builder data
	If _Sleep($DELAYRESPOND) Then Return

	$g_aiCurrentLootBB[$eLootTrophyBB] = getTrophyBB(70, 135)
	$g_aiCurrentLootBB[$eLootGoldBB] = getResourcesMainScreen(690, 22)
	$g_aiCurrentLootBB[$eLootElixirBB] = getResourcesMainScreen(690, 59)
	If $bSetLog Then SetLog("[B]:" & $g_iFreeBuilderCountBB & "/" & $g_iTotalBuilderCountBB & " [G]:" & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]) & " [E]:" & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]) & "[T]: " & _NumberFormat($g_aiCurrentLootBB[$eLootTrophyBB]), $COLOR_SUCCESS)

	If Not $bBypass Then ; update stats
		UpdateStats()
	EndIf
	
EndFunc   ;==>BuilderBaseReport



Func isGoldFullBB()
	$g_bGoldStorageFullBB = False
	$g_bGoldStorage50BB = False
	Local $aIsGoldFullBB[4] = [666, 40 , 0xD9B40C, 20] ; BB Gold Resource bar is 90% Full
	If _CheckPixel($aIsGoldFullBB, True) Then ;Hex if color of gold (orange)
		SetLog("Builder Base Gold Storages are > 90% : " & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]), $COLOR_SUCCESS)
		$g_bGoldStorageFullBB = True
	ElseIf $g_bDebugSetlog Then
		Local $colorRead = _GetPixelColor($aIsGoldFullBB[0], $aIsGoldFullBB[1], True)
		SetDebugLog("Builder Base Gold Storages are not > 90%", $COLOR_ACTION)
		SetDebugLog("expected in (" & $aIsGoldFullBB[0] & "," & $aIsGoldFullBB[1] & ")  = " & Hex($aIsGoldFullBB[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf
	
	Local $aIsGold50BB[4] = [740, 40 , 0xD9B40C, 20] ; BB Gold Resource bar is 50%
	If _CheckPixel($aIsGold50BB, True) Then ;Hex if color of gold (orange)
		SetLog("Builder Base Gold Storages are > 50%", $COLOR_ACTION)
		$g_bGoldStorage50BB = True ;only use it for wall upgrade
	Else
		SetDebugLog("Builder Base Gold Storages are not > 50%", $COLOR_ACTION)
	EndIf
	
	Return $g_bGoldStorageFullBB
EndFunc   ;==>isGoldFull

Func isElixirFullBB()
	$g_bElixirStorageFullBB = False
	Local $aIsElixirFullBB[4] = [666, 75 , 0x8027FF, 10] ; Main Screen Elixir Resource bar is 90% Full
	If _CheckPixel($aIsElixirFullBB, True) Then ;Hex if color of Elixir (orange)
		SetLog("Builder Base Elixir Storages are > 90% : " & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]), $COLOR_SUCCESS)
		$g_bElixirStorageFullBB = True
	ElseIf $g_bDebugSetlog Then
		Local $colorRead = _GetPixelColor($aIsElixirFullBB[0], $aIsElixirFullBB[1], True)
		SetLog("Builder Base Elixir Storages are not > 90%", $COLOR_ACTION)
		SetLog("expected in (" & $aIsElixirFullBB[0] & "," & $aIsElixirFullBB[1] & ")  = " & Hex($aIsElixirFullBB[2], 6) & " - Found " & $colorRead, $COLOR_ACTION)
	EndIf
	
	Return $g_bElixirStorageFullBB
EndFunc   ;==>isElixirFull



