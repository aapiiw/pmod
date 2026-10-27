; #FUNCTION# ====================================================================================================================
; Name ..........: UpgradeWall
; Description ...: This file checks if enough resources to upgrade walls, and upgrades them
; Syntax ........: UpgradeWall()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (2015), HungLe (2015)
; Modified ......: Sardo (08-2015), KnowJack (08-2015), MonkeyHunter(06-2016) , trlopes (07-2016)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2021
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkwall.au3
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func UpgradeWall($bTest = False)

	If Not $g_bAutoUpgradeWallsEnable Then Return
	If Not $g_bRunState Then Return
	If _Sleep(50) Then Return
	Local $GoUpgrade = False, $bWallUpgraded = True
	
	SetLog("Checking Upgrade Walls", $COLOR_INFO)
	checkMainScreen(False, $g_bStayOnBuilderBase, "UpgradeWall")
	VillageReport(True, True) ;update village resource capacity
	If Not WallUpgradeCheckBuilder() And Not $bTest Then
		SetLog("No builder available, Upgrade Walls skipped", $COLOR_DEBUG2)
		Return
	EndIf
	If _Sleep(50) Then Return
	If Not $g_bRunState Then Return
	
	If $g_iFreeBuilderCount > 0 Then $GoUpgrade = True
	If $g_bChkOnly1Builder And $g_iFreeBuilderCount > 1 And Not $bTest Then
		SetLog("Have more than 1 builder, Upgrade Walls skipped", $COLOR_DEBUG2)
		Return
	EndIf
	If _Sleep(50) Then Return
	If Not $g_bRunState Then Return
	If $GoUpgrade And Not $bTest And Not WallLootEnough() Then Return

	If $GoUpgrade Then 
		Local $iLoop = 1
		If $g_iUpgradeWallLootType = 2 Then $iLoop = 2
		For $i = 1 To $iLoop
			SetDebugLog("$iLoop = " & $i & "/" & $iLoop)
			$bWallUpgraded = -1
			$bWallUpgraded = UpgradeWallBuildMenu()
			; -1 = Build menu not usable. Never compare a Bool with -1: in AutoIt True = -1 is True (any non zero number),
			; every Build menu upgrade ran the old village search after it (zone/qath 27 Oct)
			Local $bMenuFailed = (Not IsBool($bWallUpgraded) And $bWallUpgraded = -1)
			; old way (search wall image on village, ~30 s) only when the Build menu was not usable on the first try: after a
			; Build menu wall upgrade, the 2nd loop (Elixir then Gold) went there 18 times in one night, 15 times not enough resource
			If $bMenuFailed And $i > 1 Then ExitLoop
			If $bMenuFailed Then $bWallUpgraded = DoUpgradeWall()
			If Not $bWallUpgraded Then ExitLoop
			If _Sleep(1000) Then Return
		Next
	EndIf
	
	VillageReport(True, True)
	CheckMainScreen(False, $g_bStayOnBuilderBase, "UpgradeWall")
	Return $bWallUpgraded
EndFunc   ;==>UpgradeWall

; select a wall from Build menu tab 1 ("Wall x N", any level) then upgrade it (with Upgrade More)
; Return True/False = upgrade result, -1 = no wall row found (use old way)
Func UpgradeWallBuildMenu()
	; no Type filter: "Permanent" holds almost every building, it does not shorten the list
	Local $sFilter = ""
	If Not OpenBuildMenu(1) Then
		SetLog("Wall: Build menu not opened (village: " & (isOnMainVillage() ? "main" : "not main") & ", menu open: " & IsBuildMenuOpen() & ")", $COLOR_DEBUG1)
		Return -1
	EndIf
	Local $aStop[1] = ["Wall"] ; stop scrolling when the wall row is seen
	Local $aList = BuildMenuCollect($g_sImgResourceIcon, $g_iXFindUpgrade, -22, "building", $aStop, 12, "Build menu list (wall search)")
	Local $iRow = -1
	For $i = 0 To UBound($aList) - 1
		If $aList[$i][7] And ($aList[$i][3] = "Wall" Or $aList[$i][3] = "Walls") And $aList[$i][0] <> "DE" Then
			; a misread name gives "Wall" to another row (zone, Oct 2026: "Wall 1 200 000 Gold" was an Elixir Collector,
			; the 1 builder kept for walls was used): the cost must be a wall cost
			If Number($aList[$i][5]) > 0 And _ArraySearch($g_aiWallCost, Number($aList[$i][5]), 1) < 1 Then
				SetLog("Wall row cost " & _NumberFormat($aList[$i][5]) & " is not a wall cost, row ignored", $COLOR_WARNING)
				ContinueLoop
			EndIf
			$iRow = $i
			ExitLoop
		EndIf
	Next
	If $iRow < 0 Then
		CloseBuildMenu()
		; list read (red rows are not returned): the wall row is red (not enough resource) or not there.
		; The old village search (slow, ~20 s) can not do better, it is only used when the menu can not be opened
		SetLog("No affordable wall in Build menu, skip", $COLOR_INFO)
		Return False
	EndIf
	If Number($aList[$iRow][5]) > 0 And Number($aList[$iRow][5]) <> $g_iLastWallCost Then
		$g_iLastWallCost = Number($aList[$iRow][5])
		WallAutoAdjustMinSave() ; Elixir Min Save uses the wall cost
	EndIf
	SetLog("Wall from Build menu: x" & $aList[$iRow][4] & ", cost " & _NumberFormat($aList[$iRow][5]) & " " & $aList[$iRow][0], $COLOR_INFO)
	; resource check before the wall is selected (camera move + wall window cost ~10 s): same rule as DoUpgradeWall,
	; loot minus wall Min Save, resource type of the GUI (0 Gold, 1 Elixir, 2 Elixir then Gold).
	; loot read again now (shown top center while the menu is open): the value read at the start can be old or unread (0),
	; builders keep upgrading between routines. Unread loot = no early skip, DoUpgradeWall checks after its own report.
	BuildMenuReadLoot(False, False)
	If Number($g_aiCurrentLoot[$eLootGold]) > 0 Or Number($g_aiCurrentLoot[$eLootElixir]) > 0 Then
		Local $iCost = Number($aList[$iRow][5])
		Local $iCanGold = Number($g_aiCurrentLoot[$eLootGold]) - $g_iUpgradeWallMinGold
		Local $iCanElix = Number($g_aiCurrentLoot[$eLootElixir]) - $g_iUpgradeWallMinElixir
		Local $bGoldOk = ($g_iUpgradeWallLootType <> 1 And $iCanGold >= $iCost)
		Local $bElixOk = ($g_iUpgradeWallLootType <> 0 And $iCanElix >= $iCost)
		If $iCost > 0 And Not $bGoldOk And Not $bElixOk Then
			SetLog("Wall cost " & _NumberFormat($iCost) & ", can use Gold " & _NumberFormat($iCanGold) & " / Elixir " & _NumberFormat($iCanElix) & _
					" (after Min Save): not enough, skip", $COLOR_INFO)
			CloseBuildMenu()
			Return False
		EndIf
	EndIf
	Local $aCoord = BuildMenuGoToItem(1, $aList[$iRow][3], $aList[$iRow][8], $g_sImgResourceIcon, $g_iXFindUpgrade, -22, "building", $sFilter)
	If Not IsArray($aCoord) Then
		SetLog("Wall: row not found again after scrolling", $COLOR_DEBUG1)
		CloseBuildMenu()
		Return -1
	EndIf
	ClickP($aCoord) ; camera moves to one wall and selects it
	If _Sleep(1500) Then Return False
	; the upgrade button is the same for every building: never upgrade what is not a wall
	; Build menu stays open on the right: name and buttons move left, the wall name sits above 2 button rows
	; (Oct 2026 screen: "Wall (Level 16)" at x 160-340, y 438-461, the default read at 242,477 was always empty)
	Local $aInfo = BuildingInfo(60, 435)
	If $aInfo[1] = "" Then $aInfo = BuildingInfo(60, 477)
	If $aInfo[1] <> "Wall" Then
		SetLog("Wall: selected building is '" & $aInfo[1] & "', not a wall, skip", $COLOR_WARNING)
		ClickAway()
		Return False
	EndIf
	Local $iWallCost = Number($aList[$iRow][5])
	If $iWallCost = 0 Then ; cost not read in the list: cost of the selected wall level
		Local $iLevel = Number($aInfo[2])
		If $iLevel < 1 Or $iLevel > UBound($g_aiWallCost) - 1 Then
			SetLog("Wall: cost and level not read, skip", $COLOR_WARNING)
			ClickAway()
			Return False
		EndIf
		$iWallCost = $g_aiWallCost[$iLevel]
		$g_iLastWallCost = $iWallCost
		SetLog("Wall level " & $iLevel & ", cost " & _NumberFormat($iWallCost), $COLOR_INFO)
		; cost was not readable in the list, so the loot check before the click was skipped: do it now
		If Not WallLootEnough() Then
			ClickAway()
			Return False
		EndIf
	EndIf
	Return DoUpgradeWall($iWallCost)
EndFunc   ;==>UpgradeWallBuildMenu

; loot (village report) minus wall Min Save, before the Build menu is opened (Oct 2026: menu opened with loot under
; Min Save when the last builder was kept for walls). Auto Adjust Min Save is applied first.
Func WallLootEnough()
	WallAutoAdjustMinSave()
	Local $iGold = Number($g_aiCurrentLoot[$eLootGold]), $iElix = Number($g_aiCurrentLoot[$eLootElixir])
	If $iGold <= 0 And $iElix <= 0 Then Return True ; loot not read: let the Build menu check decide
	Local $iCanGold = $g_iUpgradeWallLootType <> 1 ? $iGold - $g_iUpgradeWallMinGold : 0
	Local $iCanElix = $g_iUpgradeWallLootType <> 0 ? $iElix - $g_iUpgradeWallMinElixir : 0
	Local $iCost = $g_iLastWallCost ; saved in building.ini, survives a bot restart
	If $iCost < 1 Then $iCost = 1
	If $iCanGold < $iCost And $iCanElix < $iCost Then
		SetLog("Wall: loot after Min Save (Gold " & _NumberFormat($iCanGold) & ", Elixir " & _NumberFormat($iCanElix) & ") below wall cost " & _
				_NumberFormat($iCost) & ", skip", $COLOR_INFO)
		Return False
	EndIf
	Return True
EndFunc   ;==>WallLootEnough

; Auto Adjust Min Save for walls, capacity of one storage at this TH ($g_aiMaxStorage, max storage level = TH + 1), 4 storages:
; TH 9+: keep 2 storages of Gold, Elixir 3.5 storages minus the wall cost (Elixir wall when Elixir reaches 3.5 storages:
; a Min Save of 3.5 storages + wall cost was above the full capacity, Elixir was never used, qath TH16 Oct 2026)
; TH 7-8 rushing: Gold 2 storages, Elixir Hero Hall cost + 1 storage; TH 1-6 rushing: Gold 2, Elixir 3 storages
Func WallAutoAdjustMinSave()
	If Not $g_bAutoAdjustSaveWall Then Return
	Local $iTH = Number($g_iTownHallLevel)
	If $iTH < 1 Or $iTH > UBound($g_aiMaxStorage) - 1 Then Return
	Local $iCap = $g_aiMaxStorage[$iTH], $iGold = 0, $iElix = 0
	If $iTH >= 9 Then
		$iGold = Int($iCap * 2)
		$iElix = Int($iCap * 3.5) - ($g_iLastWallCost > 0 ? $g_iLastWallCost : 0)
	ElseIf IsTHLevelAchieved() Then
		Return
	ElseIf $iTH >= 7 Then
		$iGold = $iCap * 2
		$iElix = $g_aiHeroHallCost[$iTH - 7] + $iCap
	Else
		$iGold = $iCap * 2
		$iElix = $iCap * 2.5
	EndIf
	If $iGold = $g_iUpgradeWallMinGold And $iElix = $g_iUpgradeWallMinElixir Then Return
	$g_iUpgradeWallMinGold = $iGold
	$g_iUpgradeWallMinElixir = $iElix
	SetLog("Auto Adjust wall Min Save (TH" & $iTH & "): Gold " & _NumberFormat($iGold) & ", Elixir " & _NumberFormat($iElix), $COLOR_INFO)
	ApplyConfig()
	SaveConfig()
EndFunc   ;==>WallAutoAdjustMinSave

Func WallUpgradeCheckBuilder($bTest = False)
	Local $bRet = False
	getBuilderCount(True)
	If $bTest Then
		$bRet = True
	Else
		$bRet = $g_iFreeBuilderCount >= 1 ; Goblin Builder already left out by getBuilderCount
		If Not $bRet Then SetDebugLog("WallUpgradeCheckBuilder: no free builder")
	EndIf
	Return $bRet
EndFunc


; $iSelectedWallCost > 0: a wall is already selected (from Build menu), skip wall search and use this cost per wall
Func DoUpgradeWall($iSelectedWallCost = 0)
	If Not $g_bRunState Then Return
	Local $bCanUseElix = False, $bCanUseGold = False
	Local $aBtnCoord[4] = [150, 500, 750, 600]
	Local $bRet = True

	WallAutoAdjustMinSave()
	
	; wall selected from the Build menu: loot read with the menu open. VillageReport closed the menu (checkObstacles
	; "FullScreenWindow"), the buttons moved back to the center and Gold (x ~508) was outside the left area (zone 27 Oct)
	If $iSelectedWallCost > 0 And IsBuildMenuOpen() Then
		BuildMenuReadLoot(False, False)
	Else
		VillageReport(True, True)
	EndIf
	; Build menu open: buttons shifted left (Gold icon ~186,571, Upgrade More plus ~366,500)
	If IsBuildMenuOpen() Then
		$aBtnCoord[0] = 100
		$aBtnCoord[1] = 470
		$aBtnCoord[2] = 500
		$aBtnCoord[3] = 640
	EndIf
	Local $iCanUseGold = $g_aiCurrentLoot[$eLootGold] - $g_iUpgradeWallMinGold
	Local $iCanUseElix = $g_aiCurrentLoot[$eLootElixir] - $g_iUpgradeWallMinElixir

	If $iCanUseGold < 1 Then
		SetLog("Skip using Gold, not enough resource", $COLOR_INFO)
	Else
		SetDebugLog("Can use Gold upto : " & _NumberFormat($iCanUseGold), $COLOR_INFO)
		$bCanUseGold = True
	EndIf

	If $iCanUseElix < 1 Then
		SetLog("Skip using Elix, not enough resource", $COLOR_INFO)
	Else
		SetDebugLog("Can use Elix upto : " & _NumberFormat($iCanUseElix), $COLOR_INFO)
		$bCanUseElix = True
	EndIf

	If Not $bCanUseGold And Not $bCanUseElix Then
		SetLog("Both Gold and Elix are low, or not enough to save after upgrade", $COLOR_INFO)
		Return False
	EndIf

	Local $aDel[1] = [0], $x, $y, $bWallFound = False, $aWallLevel, $aButton
	Local $iClickTimesGold = 0, $iClickTimesElix = 0, $iPlus10Gold = 0, $iPlus10Elix = 0, $iPlus1Gold = 0, $iPlus1Elix = 0
	Local $aGoldButton[2], $aElixButton[2], $aPlusButton[2]

	If $iSelectedWallCost > 0 Then
		Local $aSelectedWall[3] = [0, 0, "?"]
		$aWallLevel = $aSelectedWall
		$bWallFound = True
	Else
		$bWallFound = SearchWall($aWallLevel)
	EndIf
	If Not $bWallFound Then Return
	If _Sleep(50) Then Return

	If $bWallFound Then
		Local $bPlusSignFound = False
		$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
		If IsArray($aButton) And UBound($aButton) > 0 Then
			For $i = 0 To UBound($aButton) - 1
				Select
					Case $aButton[$i][0] = "PlusSign"
						$aPlusButton[0] = $aButton[$i][1]
						$aPlusButton[1] = $aButton[$i][2]
						$bPlusSignFound = True
						SetDebugLog("Found Plus Button on " & _ArrayToString($aPlusButton), $COLOR_DEBUG)
					Case $aButton[$i][0] = "Gold"
						$aGoldButton[0] = $aButton[$i][1] - 25
						$aGoldButton[1] = $aButton[$i][2] + 25
						SetDebugLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
					Case $aButton[$i][0] = "Elix"
						$aElixButton[0] = $aButton[$i][1] - 25
						$aElixButton[1] = $aButton[$i][2] + 25
						SetDebugLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
				EndSelect
			Next
		EndIf
		; Build menu layout: the images were made for the old centered buttons (Gold never matched, 27 Oct; none with the Wall
		; Ring button, zone/qurlk/qruel 28 Oct): the cost label scan replaces them when it finds a button
		If IsBuildMenuOpen() Then
			Local $aGoldC[2], $aElixC[2]
			If WallButtonsByColor($aElixC, $aGoldC) Then
				$aGoldButton = $aGoldC
				$aElixButton = $aElixC
			EndIf
		EndIf
		If $aElixButton[0] = "" And $aGoldButton[0] <> "" Then $bCanUseElix = False ; Gold only wall level

		If _Sleep(50) Then Return
		Local $iWallCost = $iSelectedWallCost > 0 ? $iSelectedWallCost : $g_aiWallCost[Number($aWallLevel[2])]
		; cost 0 (level not read) divided the loot by 0: "Can upgrade = 9223372036854775807", Min Save ignored (qath 27 Oct)
		If $iWallCost < 1 Then
			SetLog("Wall: cost unknown (level '" & $aWallLevel[2] & "'), skip", $COLOR_WARNING)
			ClickAway()
			Return False
		EndIf
		If $iWallCost < $g_aiWallCost[4] Then $bCanUseElix = False ; to level 2-4 Gold only, Elixir from level 5
		Local $iWallCanUpgradeGold = ($bCanUseGold ? Floor($iCanUseGold / $iWallCost) : 0)
		Local $iWallCanUpgradeElix = ($bCanUseElix ? Floor($iCanUseElix/ $iWallCost) : 0)
		SetDebugLog("iWallCanUpgradeGold: " & $iWallCanUpgradeGold & ", iWallCanUpgradeElix : " & $iWallCanUpgradeElix)
		If $iWallCanUpgradeGold < 1 Then $bCanUseGold = False
		If $iWallCanUpgradeElix < 1 Then $bCanUseElix = False
		SetLog("CanUseGold = " & String($bCanUseGold), $COLOR_DEBUG)
		SetLog("CanUseElix = " & String($bCanUseElix), $COLOR_DEBUG)
		If $bCanUseGold Then SetLog("Can upgrade = " & $iWallCanUpgradeGold & " wall Level " & $aWallLevel[2] & " (cost " & _NumberFormat($iWallCost) & ") with Gold", $COLOR_INFO)
		If $bCanUseElix Then SetLog("Can upgrade = " & $iWallCanUpgradeElix & " wall Level " & $aWallLevel[2] & " (cost " & _NumberFormat($iWallCost) & ") with Elix", $COLOR_INFO)
		
		If Not $bCanUseGold And $g_iUpgradeWallLootType = 0 Then 
			SetLog("Cannot use Gold for upgrade wall", $COLOR_DEBUG2)
			ClickAway()
			Return False
		ElseIf Not $bCanUseElix And $g_iUpgradeWallLootType = 1 Then 
			SetLog("Cannot use Elix for upgrade wall", $COLOR_DEBUG2)
			ClickAway()
			Return False
		ElseIf $iWallCanUpgradeGold < 1 And $iWallCanUpgradeElix < 1 Then
			SetLog("Cannot upgrade wall, not enough resource", $COLOR_DEBUG2)
			ClickAway()
			Return False
		EndIf
		; a click on an unset button (0,0) was counted as an upgrade (zone 27 Oct: Gold button outside the search area)
		Local $bUseElix = ($g_iUpgradeWallLootType = 1) Or ($g_iUpgradeWallLootType = 2 And $bCanUseElix And $iWallCanUpgradeElix > 0)
		If ($bUseElix And $aElixButton[0] = "") Or (Not $bUseElix And $aGoldButton[0] = "") Then
			SetLog("Wall: " & ($bUseElix ? "Elixir" : "Gold") & " upgrade button not found, skip", $COLOR_WARNING)
			ClickAway()
			Return False
		EndIf
		
		If $bCanUseGold Or $bCanUseElix Then
			If ($iWallCanUpgradeGold > 1 Or $iWallCanUpgradeElix > 1) And $bPlusSignFound Then
				SetLog("Trying Upgrade More Wall", $COLOR_ACTION)
				ClickP($aPlusButton)
				If _Sleep(1000) Then Return

				If $bCanUseGold Then
					$iClickTimesGold = $iWallCanUpgradeGold / 10 ; can we upgrade 10+ for gold
					$iPlus10Gold = Floor($iClickTimesGold)
					$iPlus1Gold = $iWallCanUpgradeGold
				EndIf
				If $bCanUseElix Then
					$iClickTimesElix = $iWallCanUpgradeElix / 10 ; can we upgrade 10+ for elix
					$iPlus10Elix = Floor($iClickTimesElix)
					$iPlus1Elix = $iWallCanUpgradeElix
				EndIf

				SetDebugLog("Plus10Gold : " & $iPlus10Gold & ", Plus10Elix : " & $iPlus10Elix, $COLOR_DEBUG)
				SetDebugLog("Plus1Gold : " & $iPlus1Gold & ", Plus1Elix : " & $iPlus1Elix, $COLOR_DEBUG)

				$aButton = QuickMIS("CNX", $g_sImgCheckWallDirUpgradeButton, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3])
				If IsArray($aButton) And UBound($aButton) > 0 Then
					For $i = 0 To UBound($aButton) - 1
						Select
							Case $aButton[$i][0] = "Gold"
								$aGoldButton[0] = $aButton[$i][1] - 25
								$aGoldButton[1] = $aButton[$i][2] + 25
								SetDebugLog("Found Gold Button on " & _ArrayToString($aGoldButton), $COLOR_DEBUG)
							Case $aButton[$i][0] = "Elix"
								$aElixButton[0] = $aButton[$i][1] - 25
								$aElixButton[1] = $aButton[$i][2] + 25
								SetDebugLog("Found Elix Button on " & _ArrayToString($aElixButton), $COLOR_DEBUG)
						EndSelect
					Next
				EndIf
				If _Sleep(50) Then Return

				Local $iCount = 1, $bPlusButtonFound = False, $iCostUpgrade = 0
				If $iPlus10Gold > 0 Or $iPlus10Elix > 0 Then
					;UpWallElixir($iWallCost = $g_aiWallCost[$g_iTownHallLevel - 1], $iCountPlus = 1, $UpType = "+10", $aElixButton)
					
					SetLog("Looking for +10 Button", $COLOR_DEBUG)
					Switch $g_iUpgradeWallLootType
						Case 0 ;Gold
							If $iWallCanUpgradeGold > 10 Then Return UpWallGold($iWallCost, $iPlus10Gold, "+10", $aGoldButton)
							
						Case 1 ;Elixir
							Return UpWallElixir($iWallCost, $iPlus10Elix, "+10", $aElixButton)
							
						Case 2 ;Elixir Then Gold
							If $bCanUseElix = True And $iPlus10Elix > 0 Then
								Return UpWallElixir($iWallCost, $iPlus10Elix, "+10", $aElixButton)
							EndIf
							If $bCanUseGold = True And $iPlus10Gold > 0 Then
								Return UpWallGold($iWallCost, $iPlus10Gold, "+10", $aGoldButton)
							EndIf
					EndSwitch
				EndIf

				If _Sleep(50) Then Return
				If $iPlus1Gold > 1 Or $iPlus1Elix > 1 Then
					SetLog("Looking for +1 Button", $COLOR_DEBUG)
					Switch $g_iUpgradeWallLootType
						Case 0 ;Gold
							Return UpWallGold($iWallCost, $iPlus1Gold - 1, "+1", $aGoldButton)
						Case 1 ;Elix
							Return UpWallElixir($iWallCost, $iPlus1Elix - 1, "+1", $aElixButton)
						Case 2 ;Elix Then Gold
							If $bCanUseElix = True And $iPlus1Elix > 1 Then
								Return UpWallElixir($iWallCost, $iPlus1Elix - 1, "+1", $aElixButton)
							EndIf
							If $bCanUseGold = True And $iPlus1Gold > 1 Then
								Return UpWallGold($iWallCost, $iPlus1Gold - 1, "+1", $aGoldButton)
							EndIf
					EndSwitch
				EndIf
			Else
				If Not $g_bRunState Then Return
				SetLog("Going to Upgrade 1 Wall", $COLOR_DEBUG)
				Switch $g_iUpgradeWallLootType
					Case 0 ;Gold
						SetLog("Upgrading 1 Wall for Gold upgrade", $COLOR_ACTION)
						ClickP($aGoldButton)
						PushMsg("UpgradeWithGold")
						$g_iNbrOfWallsUppedGold += 1
						$g_iNbrOfWallsUpped += 1
						$g_iCostGoldWall += $iWallCost
						SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
					Case 1
						SetLog("Upgrading 1 Wall for Elix upgrade", $COLOR_ACTION)
						ClickP($aElixButton)
						PushMsg("UpgradeWithElixir")
						$g_iNbrOfWallsUppedElixir += 1
						$g_iNbrOfWallsUpped += 1
						$g_iCostElixirWall += $iWallCost
						SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
					Case 2
						Select
							Case $bCanUseElix = True And $iWallCanUpgradeElix > 0
								SetLog("Upgrading 1 Wall for Elix upgrade", $COLOR_ACTION)
								ClickP($aElixButton)
								PushMsg("UpgradeWithElixir")
								$g_iNbrOfWallsUppedElixir += 1
								$g_iNbrOfWallsUpped += 1
								$g_iCostElixirWall += $iWallCost
								SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
								$bCanUseGold = False
							Case $bCanUseGold = True And $iWallCanUpgradeGold > 0
								SetLog("Upgrading 1 Wall for Gold upgrade", $COLOR_ACTION)
								ClickP($aGoldButton)
								PushMsg("UpgradeWithGold")
								$g_iNbrOfWallsUppedGold += 1
								$g_iNbrOfWallsUpped += 1
								$g_iCostGoldWall += $iWallCost
								SetLog("Cost : " & _NumberFormat($iWallCost), $COLOR_SUCCESS)
						EndSelect
				EndSwitch
				If _Sleep(1000) Then Return
				If IsUpgradeWindowOpen() Then 
					Click(625, 545, 1, 50, "UpgradeWall")
					If _Sleep(500) Then Return
				EndIf
				ClickAway()
				; the resource button upgrades the wall at once (no confirm window): the result was left unset and the
				; old village search ran after a Build menu upgrade (zone 27 Oct, ~30 s)
				Return True
			EndIf
		EndIf
	Else
		SetLog("Not a wall, looking Next wall", $COLOR_DEBUG)
		Return False
	EndIf
	Return False
EndFunc

; $aElix / $aGold = click points (icon point - 25, + 25) like the image results
; Wall upgrade buttons with the Build menu open. Grid size, order and button count change per account and state (Upgrade
; More, Wall Ring, < 10 walls left, Gold only levels; zone 28 Oct coin 207,585 / drop 271,585, BB 186,570 / 279,568), so the
; whole button area is scanned for Gold coin / Elixir drop pixels and an icon counts only with cost text on its left (white,
; or red = not enough; text px >= 51 on 6 screenshots, other gold/purple spots <= 16). Click point = icon - 25, + 25.
Func WallButtonsByColor(ByRef $aElix, ByRef $aGold)
	Local $aCl[60][8], $iCl = 0, $iPix, $r, $g, $b, $iType, $bNew
	_CaptureRegion()
	For $x = 110 To 390 Step 2
		For $y = 470 To 640 Step 2
			$iPix = Dec(_GetPixelColor($x, $y, False))
			$r = BitAND(BitShift($iPix, 16), 0xFF)
			$g = BitAND(BitShift($iPix, 8), 0xFF)
			$b = BitAND($iPix, 0xFF)
			If $r > 200 And $g > 150 And $b < 90 Then
				$iType = 0
			ElseIf $r > 150 And $b > 150 And $g < 90 Then
				$iType = 1
			Else
				ContinueLoop
			EndIf
			$bNew = True
			For $i = 0 To $iCl - 1
				If $aCl[$i][0] = $iType And Abs($x - $aCl[$i][4]) <= 12 And Abs($y - $aCl[$i][5]) <= 12 Then
					$aCl[$i][1] += 1
					$aCl[$i][2] += $x
					$aCl[$i][3] += $y
					If $x > $aCl[$i][7] Then $aCl[$i][7] = $x
					$bNew = False
					ExitLoop
				EndIf
			Next
			If $bNew And $iCl < 60 Then
				$aCl[$iCl][0] = $iType
				$aCl[$iCl][1] = 1
				$aCl[$iCl][2] = $x
				$aCl[$iCl][3] = $y
				$aCl[$iCl][4] = $x
				$aCl[$iCl][5] = $y
				$aCl[$iCl][7] = $x
				$iCl += 1
			EndIf
		Next
	Next
	Local $aBest[2] = [0, 0], $iCx, $iCy, $iText
	For $i = 0 To $iCl - 1
		If $aCl[$i][1] < 4 Or $aCl[$i][7] - $aCl[$i][4] > 10 Then ContinueLoop ; icon <= 8 px wide (BB level badge "35": 12)
		$iCx = Round($aCl[$i][2] / $aCl[$i][1])
		$iCy = Round($aCl[$i][3] / $aCl[$i][1])
		$iText = 0
		For $x = $iCx - 50 To $iCx - 8 Step 2
			For $y = $iCy - 4 To $iCy + 4
				$iPix = Dec(_GetPixelColor($x, $y, False))
				$r = BitAND(BitShift($iPix, 16), 0xFF)
				$g = BitAND(BitShift($iPix, 8), 0xFF)
				$b = BitAND($iPix, 0xFF)
				If $r > 230 And (($g > 230 And $b > 230) Or ($g > 90 And $g < 160 And $b > 90 And $b < 160)) Then $iText += 1
			Next
		Next
		If $iText < 30 Or $iText <= $aBest[$aCl[$i][0]] Then ContinueLoop
		$aBest[$aCl[$i][0]] = $iText
		If $aCl[$i][0] = 0 Then
			$aGold[0] = $iCx - 25
			$aGold[1] = $iCy + 25
		Else
			$aElix[0] = $iCx - 25
			$aElix[1] = $iCy + 25
		EndIf
	Next
	SetDebugLog("Wall buttons by color: Gold " & ($aBest[0] ? $aGold[0] & "|" & $aGold[1] : "-") & ", Elix " & ($aBest[1] ? $aElix[0] & "|" & $aElix[1] : "-") & " (text px " & $aBest[0] & "/" & $aBest[1] & ")")
	Return $aBest[0] > 0 Or $aBest[1] > 0
EndFunc   ;==>WallButtonsByColor

Func UpWallElixir($iWallCost, $iCountPlus, $UpType, $aButton)
	Local $sDir = "", $bPlusButtonFound = False, $iCount = 1, $iCostUpgrade = 0
	Local $aBtnCoord = [150, 470, 750, 600], $iPlusWall = 1 ; +10/+1 at y ~495-520 when the Build menu is open
	
	Switch $UpType 
		Case "+10"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus10"
			$iPlusWall = 10
		Case "+1"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
			$aBtnCoord[0] = WallPlus1X()
	EndSwitch
	
	SetLog("Try " & $UpType & " for Elix upgrade", $COLOR_ACTION)
	For $i = 1 To $iCountPlus
		If QuickMIS("BC1", $sDir, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 50, "Click " & $UpType)
			If _Sleep(500) Then Return
			$iCount += $iPlusWall
			$bPlusButtonFound = True
			SetDebugLog("iCount : " & $iCount)
		Else
			If $UpType = "+10" Then ;not found +10 button, fallback to +1
				$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
				$aBtnCoord[0] = WallPlus1X()
				$iPlusWall = 1
				$iCountPlus = 10
				SetLog("Searching +1 Button instead", $COLOR_DEBUG1)
				ContinueLoop
			EndIf
			SetLog("No " & $UpType & " Button Found", $COLOR_DEBUG)
			ExitLoop
		EndIf
	Next
	;click Upgrade button
	If $bPlusButtonFound Then
		WallButtonRefresh("Elix", $aButton)
		ClickP($aButton)
		PushMsg("UpgradeWithElixir")
		$iCostUpgrade = $iCount * $iWallCost
		$g_iNbrOfWallsUppedElixir += $iCount
		$g_iNbrOfWallsUpped += $iCount
		$g_iCostElixirWall += $iCostUpgrade
		SetLog("Upgraded wall with Elix: " & $iCount, $COLOR_SUCCESS)
		SetLog("Cost : " & _NumberFormat($iCostUpgrade), $COLOR_SUCCESS)
		UpdateStats()
		
		If _Sleep(1000) Then Return
		If IsOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
		Return True
	EndIf
EndFunc

Func UpWallGold($iWallCost, $iCountPlus, $UpType, $aButton)
	Local $sDir = "", $bPlusButtonFound = False, $iCount = 1, $iCostUpgrade = 0
	Local $aBtnCoord = [150, 470, 750, 600], $iPlusWall = 1 ; +10/+1 at y ~495-520 when the Build menu is open
	
	Switch $UpType 
		Case "+10"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus10"
			$iPlusWall = 10
		Case "+1"
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
			$aBtnCoord[0] = WallPlus1X()
	EndSwitch
	
	If $UpType = "+10" Then
		If Not QuickMIS("BC1", $sDir, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			SetLog("No " & $UpType & " Button Found", $COLOR_DEBUG)
			SetLog("Change to search +1 instead", $COLOR_DEBUG1)
			$iPlusWall = 1
			$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
			$UpType = "+1"
			$iCountPlus = 9
		EndIf
	EndIf
	
	SetLog("Try " & $UpType & " for Gold upgrade", $COLOR_ACTION)
	For $i = 1 To $iCountPlus
		If QuickMIS("BC1", $sDir, $aBtnCoord[0], $aBtnCoord[1], $aBtnCoord[2], $aBtnCoord[3]) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 50, "Click " & $UpType)
			If _Sleep(500) Then Return
			$iCount += $iPlusWall
			$bPlusButtonFound = True
			SetDebugLog("iCount : " & $iCount)
		Else
			SetLog("No " & $UpType & " Button Found", $COLOR_DEBUG)
			If $UpType = "+10" Then 
				SetLog("Try +1 instead", $COLOR_DEBUG1)
				$UpType = "+1"
				$sDir = $g_sImgCheckWallDirUpgradeButton & "\Plus1"
				$iPlusWall = 1
			Else
				ExitLoop
			EndIf
		EndIf
	Next
	;click Upgrade button
	If $bPlusButtonFound Then
		WallButtonRefresh("Gold", $aButton)
		ClickP($aButton)
		PushMsg("UpgradeWithGold")
		$iCostUpgrade = $iCount * $iWallCost
		$g_iNbrOfWallsUppedGold += $iCount
		$g_iNbrOfWallsUpped += $iCount
		$g_iCostGoldWall += $iCostUpgrade
		SetLog("Upgraded wall with Gold: " & $iCount, $COLOR_SUCCESS)
		SetLog("Cost : " & _NumberFormat($iCostUpgrade), $COLOR_SUCCESS)
		UpdateStats()
		If _Sleep(1000) Then Return
		If IsOKCancelPage() Then ClickP($aConfirmSurrender) ;click confirm upgrade OK button
		Return True
	EndIf
EndFunc

Func SearchWall(ByRef $aWallLevelFound, $bTest = False)
	Local $bWallFound = False, $aWallLevel, $iWallLevel
	Local $aWall, $aDel[1] = [0], $x, $y
	Local $iWallLevelToDelete = $g_iTownHallLevel
	Local $iMaxWallFound = 5, $iLevelFound = 0
	SetLog("Search Wall on Village", $COLOR_DEBUG)
	SetLog("Sort WallLevel: " & String($g_iSearchWallSort), $COLOR_DEBUG)
	If Not $bTest Then ZoomOut()
	
	$aWall = QuickMIS("CNX", $g_sImgCheckWallDir, $g_InnerDiamondLeft, $g_InnerDiamondTop, $g_InnerDiamondRight, $g_InnerDiamondBottom)

	If IsArray($aWall) And UBound($aWall) > 0 Then
		For $i = 0 To UBound($aWall) - 1
			If StringInStr($aWall[$i][3], "A") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "A", ""))
			If StringInStr($aWall[$i][3], "B") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "B", ""))
			If StringInStr($aWall[$i][3], "C") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "C", ""))
			If StringInStr($aWall[$i][3], "D") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "D", ""))
			If StringInStr($aWall[$i][3], "E") Then $aWall[$i][3] = Number(StringReplace($aWall[$i][3], "E", ""))
		Next
		
		If $g_iTownHallLevel >= 9 Then $iWallLevelToDelete = $g_iTownHallLevel + 1
		For $i = 0 To UBound($aWall) - 1
			If $aWall[$i][3] >= $iWallLevelToDelete Then 
				_ArrayAdd($aDel, $i) ;wall level >= TH level, should except this
				SetDebugLog("Level " & $aWall[$i][3] & " wall skipped, delete level : " & $iWallLevelToDelete, $COLOR_DEBUG)
			EndIf
			If $g_bUpgradeSpesificWall And $aWall[$i][3] <> $g_iTargetWallLevel Then 
				_ArrayAdd($aDel, $i)
				SetDebugLog("Level " & $aWall[$i][3] & " wall skipped, target level : " & $g_iTargetWallLevel, $COLOR_DEBUG)
			EndIf
		Next
		
		;If $bTest Then _ArrayDisplay($aWall, "$aWall")
		
		$aDel[0] = UBound($aDel) - 1
		;If $bTest Then _ArrayDisplay($aDel, "$sDel")
		If UBound($aWall) > $aDel[0] Then 
			_ArrayDelete($aWall, $aDel) ;delete wall level which same or higher than TH level
		Else
			SetLog("ERR: THLevel: " & $g_iTownHallLevel, $COLOR_DEBUG2)
			SetLog("ERR: Target Wall Level: " & $g_iTargetWallLevel, $COLOR_DEBUG2)
			SetLog("Total Wall Found on map: " & UBound($aWall), $COLOR_DEBUG2)
			SetLog("Total Wall should skip: " & $aDel[0], $COLOR_DEBUG2)
			SetLog("Please Set Right Wall Level", $COLOR_DEBUG2)
			SetLog("or select Any Level on upgrade wall setting", $COLOR_DEBUG2)
			Return False
		EndIf
		
		_ArraySort($aWall, $g_iSearchWallSort, 0, 0, 3) ;short wall level by setting

		SetDebugLog("Your TownHall Level: " & $g_iTownHallLevel & ", Exluding Wall Level >= " & $iWallLevelToDelete, $COLOR_INFO)
		SetDebugLog("Found " & UBound($aWall) - 1 & " Wall on Village", $COLOR_DEBUG)

		If $bTest Then _ArrayDisplay($aWall, "Final Wall")
		
		Local $tmpLevel = 0
		For $i = 0 To UBound($aWall) - 1
			If _Sleep(50) Then Return
			$x = $aWall[$i][1]
			$y = $aWall[$i][2]
			$iWallLevel = $aWall[$i][3]
			
			If $tmpLevel <> $iWallLevel Then $tmpLevel = $iWallLevel
			If $iLevelFound > $iMaxWallFound And $tmpLevel = $iWallLevel Then
				SetDebugLog("skip, already 5 wall")
				$iLevelFound = 0
				ContinueLoop
			EndIf
			
			$tmpLevel = $iWallLevel 
			$iLevelFound += 1
			If isInsideDiamondXY($x, $y) Then ;prevent click outside village
				SetLog("Verify Wall Level " & $iWallLevel & ", click wall on " & $x & "," & $y, $COLOR_DEBUG)
				Click($x, $y)
				If _Sleep(1000) Then Return
				$aWallLevel = BuildingInfo()
				; level not read ("Wall (Level 1( )"): level of the wall image that was clicked
				If $aWallLevel[1] = "Wall" And Number($aWallLevel[2]) < 1 Then $aWallLevel[2] = $iWallLevel
				If $aWallLevel[1] = "Wall" And $aWallLevel[2] < $iWallLevelToDelete Then
					$bWallFound = True
					ExitLoop
				EndIf
				ClickAway()
				If _Sleep(500) Then Return
			Else
				SetDebugLog("Wrong wall Level " & $iWallLevel & " detected, coord outside diamond:" & $x & "," & $y, $COLOR_DEBUG)
			EndIf
		Next
	EndIf
	If $bWallFound Then
		SetLog("Your Gold : " & _NumberFormat($g_aiCurrentLoot[$eLootGold]), $COLOR_INFO)
		SetLog("Your Elix : " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]), $COLOR_INFO)
		SetLog("Wall Level : " & $aWallLevel[2], $COLOR_SUCCESS)
		SetLog("Wall Cost  : " & _NumberFormat($g_aiWallCost[$aWallLevel[2]]), $COLOR_SUCCESS)
		SetLog("Min Gold Save : " & _NumberFormat($g_iUpgradeWallMinGold), $COLOR_INFO)
		SetLog("Min Elix Save : " & _NumberFormat($g_iUpgradeWallMinElixir), $COLOR_INFO)
		$aWallLevelFound = $aWallLevel
	EndIf
	
	Return $bWallFound
EndFunc

Func imglocFindWalls($walllevel, $searcharea = "DCD", $redline = "", $maxreturn = 0)
	; Will find maxreturn Wall in specified diamond

	;name , level , coords
	Local $FoundWalls[1] = [""] ;

	Local $redLines = $redline
	Local $minLevel = (IsNumber($walllevel) ? $walllevel : 1)
	Local $maxLevel = (IsNumber($walllevel) ? $walllevel : 15)
	Local $maxReturnPoints = $maxreturn

	; Perform the search
	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $g_sImgCheckWallDir, "str", $searcharea, "Int", $maxReturnPoints, "str", $redLines, "Int", $minLevel, "Int", $maxLevel)
	Local $error = @error ; Store error values as they reset at next function call
	Local $extError = @extended

	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		SetLog(" imgloc DLL Error imgloc " & $error & " --- " & $extError, $COLOR_ERROR)
		SetError(2, $extError, $error) ; Set external error code = 2 for DLL error
		Return $FoundWalls
	EndIf

	If checkImglocError($result, "imglocFindWalls", $g_sImgCheckWallDir) = True Then
		Return $FoundWalls
	EndIf

	; Process results
	If $result[0] <> "" Then
		; Get the keys for the dictionary item.
		SetDebugLog(" imglocFindMyWall search returned : " & $result[0])
		Local $aKeys = StringSplit($result[0], "|", $STR_NOCOUNT)
		; Loop through the array
		ReDim $FoundWalls[UBound($aKeys)]
		For $i = 0 To UBound($aKeys) - 1
			; Get the property values
			; Loop through the found object names
			Local $aCoords = RetrieveImglocProperty($aKeys[$i], "objectpoints")
			$FoundWalls[$i] = $aCoords
		Next
	EndIf
	Return $FoundWalls
EndFunc   ;==>imglocFindWalls
; left edge of the +1 search: right of +10 when it is there (Plus1 can match the "+1" of "+10" and add 10 walls),
; else x 150 (fewer than 10 walls of the level: Remove Wall | +1 | Gold upgrade on the top row, +1 at x ~248)
; after Upgrade More / +1 / +10 the cost text gets longer and with < 10 walls left Gold moves to the top row: button found again
Func WallButtonRefresh($sRes, ByRef $aButton)
	If Not IsBuildMenuOpen() Then Return
	Local $aGold[2], $aElix[2]
	If Not WallButtonsByColor($aElix, $aGold) Then Return
	If $sRes = "Elix" And $aElix[0] <> "" Then $aButton = $aElix
	If $sRes = "Gold" And $aGold[0] <> "" Then $aButton = $aGold
EndFunc   ;==>WallButtonRefresh

Func WallPlus1X()
	If QuickMIS("BC1", $g_sImgCheckWallDirUpgradeButton & "\Plus10", 150, 470, 750, 600) Then Return $g_iQuickMISX + 45
	Return 150
EndFunc   ;==>WallPlus1X
