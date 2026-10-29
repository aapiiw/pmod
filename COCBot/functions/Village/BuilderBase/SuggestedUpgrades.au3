; #FUNCTION# ====================================================================================================================
; Name ..........: AutoUpgradeBB()
; Description ...: Goes to Builders Island and Upgrades buildings with 'suggested upgrades window'.
; Syntax ........: AutoUpgradeBB()
; Parameters ....:
; Return values .: None
; Author ........: xbebenk (04-2024)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_iXFindUpgradeBB = 340





Func DoUpgradeBB($CostType = "Gold", $Cost = 0, $bTest = False)
	If _Sleep(1000) Then Return
	For $i = 1 To 3
		Local $aBuildingName = BuildingInfo(242, 479)
		If $aBuildingName[0] = "" Then
			SetLog("[" & $i & "] Trying to get upgrade name and level...", $COLOR_ACTION)
			If _Sleep(1000) Then Return
			ContinueLoop
		Else
			ExitLoop
		EndIf
		If Not $g_bRunState Then Return
		If _Sleep(500) Then Return
	Next
	
	;check ignore BuilderHall
	If StringInStr($aBuildingName[1], "Hall") And $g_bChkAutoUpgradeBBIgnoreHall Then
		SetLog("Ups! Builder Hall is not to Upgrade!", $COLOR_ERROR)
		Return False
	EndIf
	;check ignore Wall
	If StringInStr($aBuildingName[1], "Wall") And $g_bChkAutoUpgradeBBIgnoreWall Then
		SetLog("Ups! Wall is not to Upgrade!", $COLOR_ERROR)
		Return False
	EndIf
	
	;check BOB Building
	Select
		Case $aBuildingName[1] = "Archer Tower" And $aBuildingName[2] >= 6
			SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to BOB Control", $COLOR_SUCCESS)
			Return False
		Case StringInStr($aBuildingName[1], "Double") And $aBuildingName[2] >= 6
			SetLog("Upgrade for Double Cannon Level: " & $aBuildingName[2] & " skipped due to BOB Control", $COLOR_SUCCESS)
			Return False
		;Case StringInStr($aBuildingName[1], "Multi") And $aBuildingName[2] >= 8
		;	SetLog("Upgrade for " & $aBuildingName[1] & " Level: " & $aBuildingName[2] & " skipped due to BOB Control", $COLOR_SUCCESS)
		;	Return False
	EndSelect
	
	If Not $g_bRunState Then Return
	If StringInStr($aBuildingName[1], "Gem") And $aBuildingName[2] = "" Then $CostType = "Rebuild" 
	If StringInStr($aBuildingName[1], "Battle") And $aBuildingName[2] = "" Then $CostType = "Rebuild"
	If StringInStr($aBuildingName[1], "Clock") And $aBuildingName[2] = "" Then $CostType = "Rebuild"	
	
	If QuickMIS("BFI", $g_sImgAutoUpgradeBtnBB & $CostType & "*", 240, 480, 650, 580) Then
		Click($g_iQuickMISX, $g_iQuickMISY)
		If Not $bTest Then
			If WaitBBUpgradeWindow() Then
				If _Sleep(1000) Then Return
				If QuickMIS("BC1", $g_sImgBBUpgradeWindowButton, 340, 400, 800, 600) Then
					Click($g_iQuickMISX - 50, $g_iQuickMISY + 10)
					If _Sleep(1000) Then Return
					If isGemOpen(True) Then
						SetLog("Upgrade stopped due to insufficient loot", $COLOR_ERROR)
						ClickAway("Left")
						If _Sleep(500) Then Return
						ClickAway("Left")
						Return False
					Else
						SetLog($aBuildingName[1] & " Upgrading!", $COLOR_INFO)
						AutoUpgradeLog(False, "BB " & $aBuildingName[1], $aBuildingName[2], $Cost)
						If _Sleep(500) Then Return
						ClickAway("Left")
						Return True
					EndIf
				Else
					SetLog("Cannot Find Upgrade Button on Upgrade Window", $COLOR_ERROR)
				EndIf
			EndIf
		Else
			SetLog("Only for Test!", $COLOR_ERROR)
			ClickAway("Left")
			ClickBBBuilder()
			Return True
		EndIf
	Else
		SetLog("Cannot Find " & $CostType & " Button", $COLOR_ERROR)
	EndIf

	Return False
EndFunc   ;==>DoUpgradeBB




Func GetBuildingTypeBB($sUpgrades = "")
	If Not $g_bRunState Then Return
	Local $aArmy[5] = ["Camp", "Healing", "Copter", "Machine", "Control"]
	Local $aResource[3] = ["Collector", "Storage", "Mine"]
	Local $aDefense[12] = ["Wall", "Cannon", "Tower", "Mortar", "FireCrackers", "Air Bombs", "Tesla", "Crusher", "Roaster", "Launcher", "Guard", "Bow"]
	Local $aTrap[5] = ["Bomb", "Trap", "Mine", "Giant", "Mega"]
	Local $sUpgradeType = ""
	
	For $sArmy In $aArmy
		If StringInStr($sUpgrades, $sArmy) Then 
			$sUpgradeType = "Army"
		EndIf
	Next
		
	For $sResource In $aResource
		If StringInStr($sUpgrades, $sResource) Then 
			$sUpgradeType = "Resources"
		EndIf
	Next
	
	For $sDefense In $aDefense
		If StringInStr($sUpgrades, $sDefense) Then 
			$sUpgradeType = "Defenses"
		EndIf
	Next
		
	For $sTrap In $aTrap
		If StringInStr($sUpgrades, $sTrap) Then 
			$sUpgradeType = "Traps"
		EndIf
	Next
	
	If $sUpgrades = "Air Bombs" Then $sUpgradeType = "Defenses"
	If $sUpgrades = "Gold Mine" Or $sUpgrades = "Gem Mine" Then $sUpgradeType = "Resources"
	If $sUpgrades = "Giant Cannon" Then $sUpgradeType = "Defenses"
	
	If $g_bDebugSetLog Then SetLog("Found UpgradeType : " & $sUpgradeType, $COLOR_DEBUG1)
	Return $sUpgradeType
EndFunc ;GetBuildingTypeBB



Func ClickBBBuilder($Counter = 3)
	Local $b_WindowOpened = False
	If Not $g_bRunState Then Return
	
	; open the builders menu
	If Not IsBBBuilderMenuOpen() Then
		SetLog("Opening BB BuilderMenu", $COLOR_ACTION)
		Click(466, 30)
		If _Sleep(1000) Then Return
	EndIf
	
	;check
	If IsBBBuilderMenuOpen() Then
		SetLog("Check BB BuilderMenu, Opened", $COLOR_SUCCESS)
		$b_WindowOpened = True
	Else
		For $i = 1 To $Counter
			If Not $g_bRunState Then Return
			SetLog("BB BuilderMenu Closed, trying again!", $COLOR_DEBUG)
			Click(466, 30)
			If _Sleep(1000) Then Return
			If IsBBBuilderMenuOpen() Then
				$b_WindowOpened = True
				ExitLoop
			EndIf
		Next
	EndIf
	
	If Not $b_WindowOpened Then SetLog("Something wrong with BB BuilderMenu, already tried 3 times!", $COLOR_DEBUG)
	Return $b_WindowOpened
EndFunc ;==>ClickBBBuilder


Func IsBBBuilderMenuOpen()
	Local $bRet = False
	Local $aBorder0[4] = [490, 73, 0xFFFFFF, 40]
	Local $aBorder1[4] = [545, 73, 0xFFFFFF, 40]
	
	If _CheckPixel($aBorder0, True) And _CheckPixel($aBorder1, True) Then
		$bRet = True ;got correct color for border
	Else
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border0 Color Not Matched: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_DEBUG1)
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border1 Color Not Matched: " & _GetPixelColor($aBorder1[0], $aBorder1[1], True), $COLOR_DEBUG1)
	EndIf

	Return $bRet
EndFunc ;IsBBBuilderMenuOpen




Func WaitBBUpgradeWindow()
	Local $bRet = False
	For $i = 1 To 5
		SetLog("Waiting for Upgrade Window #" & $i, $COLOR_ACTION)
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 730, 50, 810, 130) Then
			$bRet = True
			SetLog("** Upgrade Window OK **", $COLOR_ACTION)
			ExitLoop
		EndIf
		If QuickMis("BC1", $g_sImgGeneralCloseButton, 740, 124, 785, 180) Then
			$bRet = True
			SetLog("** Rebuild Window OK **", $COLOR_ACTION)
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return
	Next
	If Not $bRet Then SetLog("Cannot verify Upgrade Window", $COLOR_ERROR)
	Return $bRet
EndFunc

