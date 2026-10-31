; #FUNCTION# ====================================================================================================================
; Name ..........:
; Description ...:
; Syntax ........:
; Parameters ....:
; Return values .:
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBotRun. Copyright 2015-2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

Global $g_iXFindUpgrade = 560

Func AutoUpgrade($bTest = False, $bUpgradeLowCost = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $Result = SearchUpgrade($bTest, $bUpgradeLowCost)
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc

Func AutoUpgradeCheckResource()
	
	Local $sBuilderInfo = getBuildersOnMenu()
	If StringInStr($sBuilderInfo, "#") > 0 Then ; check for valid OCR read
		Local $aGetBuilders = StringSplit($sBuilderInfo, "#", $STR_NOCOUNT) ; Split into free and total builder strings
		$g_iFreeBuilderCount = Int($aGetBuilders[0]) ; update global values
		$g_iTotalBuilderCount = Int($aGetBuilders[1])
	ElseIf $g_iFreeBuilderCount > 0 Then
		; one bad read of the small "free/total" text (read fine a moment before) must not stop the search before the
		; next page: keep the last known count
		SetLog("Fail to read builder count, use last count " & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount, $COLOR_DEBUG1)
	Else
		SetLog("Fail to read builder count", $COLOR_DEBUG1)
		Return False
	EndIf
	
	; event Goblin Builder (gems) counted in the Build menu counter: not used
	If GoblinBuilderAdjust($g_iFreeBuilderCount, $g_iTotalBuilderCount, "MenuBuilder") Then
		SetLog("Goblin Builder not used, real free builder: " & $g_iFreeBuilderCount, $COLOR_DEBUG2)
		If $g_iFreeBuilderCount = 0 Then Return False
	EndIf
	
	; loot shown top center while the menu is open: read again once when it is not read (menu still opening)
	For $i = 1 To 2
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(350, 22)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(350, 59)
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(350, 96)
		If Number($g_aiCurrentLoot[$eLootGold]) > 0 And Number($g_aiCurrentLoot[$eLootElixir]) > 0 Then ExitLoop
		If $i = 1 And _Sleep(700) Then Return False
	Next

	SetLog("[Builder]:" & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount, $COLOR_SUCCESS)
	SetLog("[G]:" & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [E]:" & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [D]:" & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]), $COLOR_SUCCESS)
	
	Return True
	
EndFunc

; Builder's Apprentice: icon left of Build menu tab 1 (see BuildMenuAssignHelper). Works with or without free builder:
; the apprentice speeds up an ongoing upgrade. Opens tab 1 when needed (checked once per hour per account)
Func CheckBuilderApprentice()
	If Not $g_bRunState Then Return False
	If Not BuildMenuHelperDue(0) Then Return False
	If Not OpenBuildMenu(1) Then Return False
	Return BuildMenuAssignHelper(0, 1)
EndFunc   ;==>CheckBuilderApprentice

Func AutoUpgradeCheckBuilder($bTest = False)
	Local $bRet = False

	If Not AutoUpgradeCheckResource() Then Return $bRet ;check available builder and resource (Gold,Elix,DE)
	If Not $g_bRunState Then Return
	; stop only when no resource is above its Min Save (many army upgrades cost elixir / DE, not gold)
	If Number($g_aiCurrentLoot[$eLootGold]) < $g_iTxtSmartMinGold And Number($g_aiCurrentLoot[$eLootElixir]) < $g_iTxtSmartMinElixir And _
			Number($g_aiCurrentLoot[$eLootDarkElixir]) < $g_iTxtSmartMinDark Then
		SetLog("Every resource is below its Min Save, skip Auto Upgrade", $COLOR_INFO)
		Return $bRet
	EndIf
	
	;Check if there is a free builder for Auto Upgrade
	If $g_iFreeBuilderCount > 0 Then $bRet = True ;builder available

	Local $iWallReserve = WallReservedBuilder()
	If $g_iFreeBuilderCount - $iWallReserve - ReservedBuildersForHeroes() < 1 Then ;check builder reserve on wall and hero upgrade
		SetLog("FreeBuilder=" & $g_iFreeBuilderCount & ", kept for wall " & $iWallReserve, $COLOR_INFO)
		If Not $g_bSkipWallReserve And Not $g_bUpgradeLowCost Then
			SetLog("No builder available. Skipping Auto Upgrade!", $COLOR_DEBUG2)
			$bRet = False
		EndIf
	EndIf

	If ($g_bSkipWallReserve Or $g_bUpgradeLowCost) And $g_iFreeBuilderCount > 0 Then
		SetLog("CheckBuilder: " & ($g_bUpgradeLowCost ? "Upgrade remain time > 1day" : "Upgrade remain time < 24h"), $COLOR_DEBUG2)
		$bRet = True
	EndIf
	
	If Not $g_bRunState Then Return
	If $bTest Then ;for testing, bypass
		$g_iFreeBuilderCount = 1
		$bRet = True
	EndIf
	
	;If CheckPlaceBuilder() Then 
	;	SetLog("Have enough gems to place new builder!", $COLOR_SUCCESS)
	;	$bRet = True ;have enough gem
	;EndIf
	
	If $g_bDebugSetLog Then SetLog("AutoUpgradeCheckBuilder() Free Builder : " & $g_iFreeBuilderCount, $COLOR_DEBUG)
	Return $bRet
EndFunc

Func SearchUpgrade($bTest = False, $bUpgradeLowCost = False)
	SetLog("Check for Auto Upgrade", $COLOR_INFO)
	If Not $g_bAutoUpgradeEnabled Then Return
	If Not $g_bRunState Then Return
	$g_bSkipWallReserve = False ;reset first
	$g_bUpgradeLowCost = False ;reset first
	$g_bGearUpDone = False
	If _Sleep(50) Then Return
	CheckMainScreen()
	VillageReport(False, True)
	If Not $bTest And AutoUpgradeListEmpty() Then
		SetLog("Build menu had nothing to upgrade at TH" & $g_iTownHallLevel & ", skip Auto Upgrade", $COLOR_INFO)
		Return False
	EndIf
	; builders read on main screen by VillageReport: no free builder = no need to open the Build menu
	; free builders minus the ones kept for wall / hero (same rule as AutoUpgradeCheckBuilder, which ran after the menu was
	; opened: 74 menu opens for nothing in one night). Low cost / wall reserve builder use comes with $bUpgradeLowCost
	If Not $bTest And Not $bUpgradeLowCost And $g_iTotalBuilderCount > 0 And $g_iFreeBuilderCount - WallReservedBuilder() - ReservedBuildersForHeroes() < 1 Then
		SetLog("No free builder (free " & $g_iFreeBuilderCount & ", kept for wall " & WallReservedBuilder() & "), skip Auto Upgrade", $COLOR_INFO)
		If CheckBuilderApprentice() Or IsBuildMenuOpen() Then CloseBuildMenu() ; apprentice speeds up an ongoing upgrade
		; all builders busy: Builder Potion when the first running upgrade has 1 day or more left
		If $g_bUseBuilderPotion And $g_iFreeBuilderCount = 0 And Not $bTest Then
			Local $h = $g_ahPotionTimer[CurAccountIndex()][1]
			If ($h = 0 Or __TimerDiff($h) >= 3600000) And OpenBuildMenu(1) Then
				BuildMenuUsePotion(1)
				CloseBuildMenu()
			EndIf
		EndIf
		Return False
	EndIf
	PlaceUnplacedBuilding()
	If $bUpgradeLowCost And $g_iFreeBuilderCount = 1 And WallReservedBuilder() = 1 Then
		; Use Wall Reserve Builder: the upgrade in progress that ends first (top row of Build menu tab 1, lists are sorted by
		; time left) decides: ends in 12 h or less = the wall builder is back soon, any upgrade; later = low cost only
		; (Gold / Elixir <= 500 000, DE <= 50 000, see AutoUpgradeLowCostOk)
		If OpenBuildMenu(1) Then
			Local $iMin = BuildMenuBusyTime()
			SetLog("Wall reserve builder: first upgrade ends in " & ($iMin > 0 ? Int($iMin / 60) & "h " & Mod($iMin, 60) & "m" : "?"), $COLOR_INFO)
			If $iMin > 0 And $iMin <= 720 Then
				$g_bSkipWallReserve = True
			ElseIf $iMin > 720 Then
				$g_bUpgradeLowCost = True
			EndIf
		EndIf
	ElseIf $bUpgradeLowCost And Not $bTest Then ;Trying LowCost Upgrade but other criterias are not met
		SetLog("AutoUpgrade Lowcost, Builder:" & $g_iFreeBuilderCount & ", RushTH:" & String($g_bChkRushTH), $COLOR_DEBUG2)
		Return False
	EndIf

	;skip search new on first page
	Local $bSkip1st = $g_bUpgradeLowCost Or $g_bSkipWallReserve
	OpenBuildMenu(1) ; also sets the village of the menu (OpenMainBuilder left it unknown: menu closed and opened again)
	CheckBuilderApprentice()
	If Not AutoUpgradeCheckBuilder() Then 
		If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then
			Click(835, 35, 1, 0, "Click Close Builder Menu")
		EndIf
		Return
	EndIf
	
	If _Sleep(50) Then Return
	; Upgrade Other Defenses needs the scored full list (old search). Rush TH (Town Hall pass first) and the wall reserve
	; builder (low cost limit in AutoUpgradeFindRow) use the order
	Local $bByOrder = Not $g_bUpgradeOtherDefenses
	If $bByOrder Then
		AutoUpgradeByOrder($bTest)
		If Not $g_bRunState Then Return
		ZoomOut(True)
		Return False
	EndIf
	SetLog("_SearchUpgrade(bTest=" & String($bTest) & ", bSkip1st=" & String($bSkip1st) & ", LowCost=" & String($g_bUpgradeLowCost) & ", UseWallReserve=" & String($g_bSkipWallReserve) & ")", $COLOR_DEBUG)
	Local $aPass = AutoUpgradeFilterPasses($g_bUpgradeLowCost Or $g_bSkipWallReserve Or $bSkip1st)
	If UBound($aPass) = 1 And $aPass[0] = "" Then
		_SearchUpgrade($bTest, $bSkip1st, $g_bUpgradeLowCost, $g_bSkipWallReserve) ;search upgrade for existing building
	ElseIf UBound($aPass) = 0 Then
		SetLog("Auto Upgrade: every group of Upgrades to ignore is ignored, nothing to search", $COLOR_INFO)
	Else
		; whole groups ignored (ex: all defenses): search only the wanted types with the Build menu filter, Town Hall (no filter
		; button) on page 1 without filter. The filter is reset at the end, also when the search stops early
		For $iPass = 0 To UBound($aPass) - 1
			If Not $g_bRunState Then ExitLoop
			If Not BuildMenuSetFilter($aPass[$iPass]) Then
				SetLog("Auto Upgrade: Build menu filter failed, search without filter", $COLOR_WARNING)
				BuildMenuSetFilter("")
				_SearchUpgrade($bTest, $bSkip1st, $g_bUpgradeLowCost, $g_bSkipWallReserve)
				ExitLoop
			EndIf
			If $iPass > 0 And Not AutoUpgradeCheckBuilder() Then ExitLoop ; builders used by the previous pass
			SetLog("Auto Upgrade filter: " & ($aPass[$iPass] = "" ? "none (page 1, Town Hall)" : $aPass[$iPass]), $COLOR_INFO)
			_SearchUpgrade($bTest, $bSkip1st, $g_bUpgradeLowCost, $g_bSkipWallReserve, $aPass[$iPass] = "" ? 1 : 15, True)
		Next
		If $g_bRunState Then
			BuildMenuSetFilter("")
			CloseBuildMenu()
		EndIf
	EndIf
	If _Sleep(2000) Then Return

	If Not $g_bRunState Then Return
	ZoomOut(True)
	Return False
EndFunc

Func _SearchUpgrade($bTest = False, $bSkip1st = False, $bLowCost = False, $bUseWallReserve = False, $iMaxPage = 15, $bFiltered = False)
	If Not $g_bRunState Then Return
	SetLog("Search For Upgrade", $COLOR_DEBUG)
	Local $Upgrades, $ZoomedIn = False, $bDoScroll = True, $bNew = False
	Local $TmpUpgradeCost, $UpgradeCost, $sameCost = 0
	Local $bAffordSeen = False, $bCheckNext = False ; scroll rule, see BuildMenuStopScroll
	; list empty check: only a full search (no low cost / wall reserve filter) with the Build menu open can say "nothing to upgrade"
	Local $bCanBeEmpty = Not $bSkip1st And Not $bLowCost And Not $bUseWallReserve And Not $bTest And Not $bFiltered, $bMenuSeen = False, $bNotEmpty = False

	;Local $bSkipNew = FindTHInUpgradeProgress()
	Local $bSkipNew = True
	
	For $z = 1 To $iMaxPage ;for do scroll (15 times without filter)
		If Not $g_bRunState Then Return
		If _Sleep(50) Then Return
		SetLog("Search For Upgrade #" & $z, $COLOR_ACTION)
		If Not $g_bRunState Then Return
		If $bSkip1st Then 
			ClickDragAUpgrade() ;do scroll up
			If _Sleep(500) Then Return
			$bSkip1st = False
			ContinueLoop
		EndIf
		
		$bNew = False ;reset
		$TmpUpgradeCost = getMostBottomCost() ;check most bottom upgrade cost
		If $UpgradeCost = $TmpUpgradeCost Then
			$sameCost += 1
		Else
			$sameCost = 0
			$UpgradeCost = $TmpUpgradeCost
		EndIf
		SetLog("[" & $z & "] SameCost=" & $sameCost & " [" & $UpgradeCost & "]", $COLOR_DEBUG1)

		If $sameCost > 1 Then
			SetLog("Detected SameCost 3 times, exit!", $COLOR_DEBUG)
			If WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) Then
				Click(835, 35, 1, 0, "Click Close Builder Menu")
			EndIf
			ExitLoop
		EndIf
		
		If $bSkipNew Then ;Townhall on upgrade, enable lowcost upgrade
			$bUseWallReserve = False
		EndIf
		
		SetLog("FindUpgrade(bTest=" & String($bTest) & ", bSkipNew=" & String($bSkipNew) & ", bLowCost=" & String($bLowCost) & ", bUseWallReserve=" & String($bUseWallReserve), $COLOR_DEBUG)
		If $z = 1 And IsBuildMenuOpen() Then $bMenuSeen = True
		$Upgrades = FindUpgrade($bTest, $bSkipNew, $bLowCost, $bUseWallReserve)
		Local $iFlags = @extended
		; a not ignored row or a red row (resource can come later) = list not empty
		If (IsArray($Upgrades) And UBound($Upgrades) > 0) Or BitAND($iFlags, 4) = 4 Then $bNotEmpty = True
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			If $bLowCost Or $g_bUpgradeOtherDefenses Then
				_ArraySort($Upgrades, 0, 0, 0, 5)
				SetLog("UpgradeList scoring by : LowCost", $COLOR_INFO)
			Else
				_ArraySort($Upgrades, 1, 0, 0, 6)
				SetLog("UpgradeList scoring by : Highest Priority", $COLOR_INFO)
			EndIf
			

			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][6] = "Disabled" Then ContinueLoop
				;If $Upgrades[$i][7] = "0" Then ContinueLoop
				SetLog("[" & $Upgrades[$i][7] & "] " & $Upgrades[$i][3] & ", Cost:" & $Upgrades[$i][5] & " " & $Upgrades[$i][0] & ", Score: [" & ($Upgrades[$i][4] = "New" ? $Upgrades[$i][4] : $Upgrades[$i][6]) & "]", $COLOR_DEBUG1)
			Next

			;For $i = 0 To UBound($Upgrades) - 1
			;	If $Upgrades[$i][4] = "New" Then ;new building
			;		If CheckResourceForDoUpgrade($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then
			;			If PlaceNewBuildingFromShop($Upgrades[$i][3], $ZoomedIn, $Upgrades[$i][5]) Then
			;				$g_bSkipWallReserve = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
			;				$g_bUpgradeLowCost = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
			;				$ZoomedIn = True
			;				$sameCost = 0
			;				$bNew = True
			;
			;				If _Sleep(2000) Then Return
			;			Else
			;				If IsFullScreenWindow() Then Click(820, 37) ;close shop window
			;				ExitLoop
			;			EndIf
			;		EndIf
			;	EndIf
			;Next
			If $bNew Then ContinueLoop
			If _Sleep(50) Then Return

			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][6] = "Disabled" Then ContinueLoop
				;If $Upgrades[$i][7] = "0" Then ContinueLoop
				If $Upgrades[$i][7] = "Essential" And $g_bChkRushTH Then
					SetLog("RushTH Found Essential Building : " & $Upgrades[$i][3] & "[" & $Upgrades[$i][5] & "] Disabled, skip!", $COLOR_ACTION)
					ContinueLoop
				EndIf

				If CheckResourceForDoUpgrade($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then ;($BuildingName, $Cost, $CostType)
					If Not $g_bRunState Then Return
					Click($Upgrades[$i][1], $Upgrades[$i][2])
					If _Sleep(1000) Then Return
					Local $aHeroes[6] = ["Barbarian", "Queen", "Warden", "Champion", "Prince", "Duke"]
					For $j In $aHeroes
						If StringInStr($Upgrades[$i][3], $j) Then
							SetLog("Upgrade : " & $Upgrades[$i][3] & ", checking Hero Hall Window", $COLOR_ACTION)							
							If DoUpgradeHero($Upgrades[$i][3], $Upgrades[$i][5], $Upgrades[$i][0]) Then ExitLoop 2
							ClickAway()
						EndIf
					Next
					If DoUpgrade($bTest, $bLowCost, $Upgrades[$i][3]) Then
						$g_bSkipWallReserve = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
						$g_bUpgradeLowCost = False ;reset to false to prevent bot wrong check on AutoUpgradeCheckBuilder()
						$sameCost = 0
						$bAffordSeen = False
						$bCheckNext = False
						$bDoScroll = False
						ContinueLoop 2
					EndIf
				EndIf
			Next
		Else
			SetLog("No Upgrade found!", $COLOR_INFO)
		EndIf

		If Not $g_bRunState Then Return
		If BuildMenuStopScroll($iFlags, $bAffordSeen, $bCheckNext) Then
			SetLog("No affordable upgrade after red cost rows, stop search", $COLOR_INFO)
			ExitLoop
		EndIf
		If $bCheckNext Then SetLog("Red cost rows reached, check one more page", $COLOR_DEBUG1)
		If Not AutoUpgradeCheckBuilder() Then Return
		If $bDoScroll Then ClickDragAUpgrade() ;do scroll up
		$bDoScroll = True
		If _Sleep(100) Then Return
	Next
	If $bCanBeEmpty And $bMenuSeen And Not $bNotEmpty And $g_iTownHallLevel > 0 And $g_bRunState Then
		Local $iAcc = CurAccountIndex()
		$g_aiAutoUpgradeEmpty[$iAcc][0] = $g_iTownHallLevel
		$g_aiAutoUpgradeEmpty[$iAcc][1] = $g_iFreeBuilderCount
		SetLog("Nothing to upgrade in Build menu (empty / all ignored), Auto Upgrade paused until TH level changes or a builder is free", $COLOR_INFO)
	EndIf
EndFunc

; Build menu filter types to search for Auto Upgrade, from the Upgrades to ignore list and $g_asUpgradeIgnoreFilter:
; [""] = one search without filter (no group fully ignored, or ignore can be bypassed), [] = everything ignored,
; else "" first (page 1 for groups without filter button = Town Hall) when needed, then each type with something to upgrade
Func AutoUpgradeFilterPasses($bNoFilter = False)
	Local $aNone[1] = [""], $aPass[0]
	; ignored rows can still be upgraded with these options: the full list is needed
	If $bNoFilter Or $g_bUpgradeOtherDefenses Then Return $aNone
	If $g_bChkRushTH Then
		For $k = 0 To UBound($g_aichkEssentialUpgrade) - 1
			If $g_aichkEssentialUpgrade[$k] = 1 Then Return $aNone
		Next
		If $g_bUpgradeOnlyTHLevelAchieve And IsTHLevelAchieved() Then Return $aNone
	EndIf
	Local $bNeedNone = False, $aNeed[UBound($g_asUpgradeIgnoreFilter)], $iTypes = 0, $iNeeded = 0
	For $i = 0 To UBound($g_asUpgradeIgnore) - 1
		If $g_iChkUpgradesToIgnore[$i] = 1 Then ContinueLoop
		For $g = 0 To UBound($g_asUpgradeIgnoreFilter) - 1
			If $g_asUpgradeIgnoreFilter[$g][0] <> $g_asUpgradeIgnore[$i][3] Then ContinueLoop
			If $g_asUpgradeIgnoreFilter[$g][1] = "" Then
				$bNeedNone = True
			Else
				$aNeed[$g] = True
			EndIf
		Next
	Next
	For $g = 0 To UBound($g_asUpgradeIgnoreFilter) - 1
		If $g_asUpgradeIgnoreFilter[$g][1] = "" Then ContinueLoop
		$iTypes += 1
		If $aNeed[$g] Then $iNeeded += 1
	Next
	If $iNeeded = $iTypes Then Return $aNone ; nothing fully ignored: the filter would not shorten the list
	If $bNeedNone Then _ArrayAdd($aPass, "")
	For $g = 0 To UBound($g_asUpgradeIgnoreFilter) - 1
		If $g_asUpgradeIgnoreFilter[$g][1] <> "" And $aNeed[$g] Then _ArrayAdd($aPass, $g_asUpgradeIgnoreFilter[$g][1])
	Next
	Return $aPass
EndFunc   ;==>AutoUpgradeFilterPasses

; current switch account index for the per account arrays (16 rows), 0 without switch account
; True (and timer restarted) when routine $iRoutine of $g_ahRoutineTimer did not run on this account for $iMinutes.
; Oct 2026 logs, every cycle: CleanYard ~15 s (0 Gem Box / obstacle in 74 runs), TreasuryCollect ~5 s (empty 45/68)
Func RoutineIntervalDue($iRoutine, $iMinutes)
	Local $iAcc = CurAccountIndex(), $h = $g_ahRoutineTimer[$iAcc][$iRoutine]
	If $h <> 0 And __TimerDiff($h) < $iMinutes * 60000 Then
		SetDebugLog("Routine " & $iRoutine & " ran " & Round(__TimerDiff($h) / 60000) & " min ago on this account, skip")
		Return False
	EndIf
	$g_ahRoutineTimer[$iAcc][$iRoutine] = __TimerInit()
	Return True
EndFunc   ;==>RoutineIntervalDue

Func CurAccountIndex()
	Local $i = Number($g_iCurAccount)
	If $i < 0 Or $i > 15 Then $i = 0
	Return $i
EndFunc   ;==>CurAccountIndex

; per account skip timer ($g_ahBBSkipTimer column $iTimer): True while less than $iMinutes since BBSkipTimerStart
Func BBSkipTimerActive($iTimer, $iMinutes)
	Local $iAcc = CurAccountIndex()
	Local $h = $g_ahBBSkipTimer[$iAcc][$iTimer]
	Return $h <> 0 And __TimerDiff($h) < $iMinutes * 60000
EndFunc   ;==>BBSkipTimerActive

Func BBSkipTimerStart($iTimer, $bStart = True)
	Local $iAcc = CurAccountIndex(), $h = 0
	If $bStart Then $h = __TimerInit()
	$g_ahBBSkipTimer[$iAcc][$iTimer] = $h
EndFunc   ;==>BBSkipTimerStart

; True = Build menu had nothing to upgrade at this TH level and no more builder is free since then: skip Auto Upgrade
; (a finished builder can show the next level of that building, a new TH level unlocks more upgrades)
Func AutoUpgradeListEmpty()
	Local $i = CurAccountIndex()
	If $g_aiAutoUpgradeEmpty[$i][0] = 0 Then Return False
	If $g_aiAutoUpgradeEmpty[$i][0] = $g_iTownHallLevel And $g_iFreeBuilderCount <= $g_aiAutoUpgradeEmpty[$i][1] Then Return True
	$g_aiAutoUpgradeEmpty[$i][0] = 0 ; TH level changed or a builder finished: check the list again
	Return False
EndFunc   ;==>AutoUpgradeListEmpty

; Auto Upgrade by type order ($g_asAutoUpgradeOrder, GUI combo): Build menu Type filter for each type, the first affordable
; row (white cost) from the top is upgraded. Name OCR only for the row to upgrade (Upgrades to ignore),
; cost OCR only when a Min Save is set for its resource. Return number of upgrades started
Func AutoUpgradeByOrder($bTest = False)
	Local $iStarted = 0, $bNotEmpty = False, $bStop = False, $bNoFilter = False, $iRet, $iExt, $aOrder[0]
	; Rush TH until the wanted TH level: Town Hall first (no filter button for it), then the order (Upgrades to ignore,
	; Essential buildings and the max levels of the Rush TH settings are checked for each row)
	; Rush TH: Town Hall, then Hero Hall and Laboratory (unlock heroes / research levels), then the order.
	; Prioritizes Hero Upgrade: Hero before Army
	If AutoUpgradeRushActive() Then
		_ArrayAdd($aOrder, "TH")
		; buildings the next Town Hall needs (Eagle / Inferno Artillery, Guardians): rows below pricier defenses (Inferno
		; Artillery 10 000 000 on page 3-4 at TH17, adb 31 Oct) and in no Type filter (user): whole list without filter.
		; Not found (max for this TH level) = not searched again for 6 h on this account
		Local $hGate = $g_ahRoutineTimer[CurAccountIndex()][6]
		If Number($g_iTownHallLevel) >= 16 And Number($g_iTownHallLevel) <= 18 And ($hGate = 0 Or __TimerDiff($hGate) > 6 * 3600000) Then _ArrayAdd($aOrder, "Gate")
		_ArrayAdd($aOrder, "Key")
	EndIf
	If $g_bHeroPriority Then _ArrayAdd($aOrder, "Hero")
	For $p = 0 To UBound($g_asAutoUpgradeOrder) - 1
		If $g_bHeroPriority And $g_asAutoUpgradeOrder[$p] = "Hero" Then ContinueLoop
		_ArrayAdd($aOrder, $g_asAutoUpgradeOrder[$p])
	Next
	For $p = 0 To UBound($aOrder) - 1
		If Not $g_bRunState Then Return $iStarted
		Local $sType = $aOrder[$p]
		If $sType <> "" And $sType <> "TH" And $sType <> "Key" And $sType <> "Gate" And $bNoFilter Then ContinueLoop ; filter failed once: the rest of the list is read without filter
		If $sType <> "" And $sType <> "TH" And $sType <> "Key" And $sType <> "Gate" And Not AutoUpgradeTypeWanted($sType) Then
			SetDebugLog("Auto Upgrade " & $sType & ": every building of this type is ignored, skip")
			ContinueLoop
		EndIf
		$iRet = AutoUpgradeTypePass($sType, $bTest)
		$iExt = @extended
		If BitAND($iExt, 1) Then $bNotEmpty = True
		If BitAND($iExt, 4) Then $bNoFilter = True
		$iStarted += $iRet
		If BitAND($iExt, 2) Or ($bTest And $iStarted > 0) Then
			$bStop = True
			ExitLoop
		EndIf
	Next
	If Not $g_bRunState Then Return $iStarted
	BuildMenuSetFilter("")
	CloseBuildMenu()
	; nothing left to wait for (no red row, every affordable row ignored): skip until TH level changes or a builder is free
	If Not $bTest And Not $bStop And $iStarted = 0 And Not $bNotEmpty And $g_iTownHallLevel > 0 Then
		Local $iAcc = CurAccountIndex()
		$g_aiAutoUpgradeEmpty[$iAcc][0] = $g_iTownHallLevel
		$g_aiAutoUpgradeEmpty[$iAcc][1] = $g_iFreeBuilderCount
		SetLog("Nothing to upgrade in Build menu (empty / all ignored), Auto Upgrade paused until TH level changes or a builder is free", $COLOR_INFO)
	EndIf
	If $iStarted = 0 Then SetLog("Auto Upgrade: no upgrade started", $COLOR_INFO)
	Return $iStarted
EndFunc   ;==>AutoUpgradeByOrder

; True when a building of Build menu Type $sType is not ignored in "Upgrades to ignore" (group -> type: $g_asUpgradeIgnoreFilter).
; "Resource" pass is for storages (and Builder's Hut) only
Func AutoUpgradeTypeWanted($sType)
	For $i = 0 To UBound($g_asUpgradeIgnore) - 1
		If $g_iChkUpgradesToIgnore[$i] = 1 Then ContinueLoop
		If $sType = "Resource" And Not (StringInStr($g_asUpgradeIgnore[$i][1], "Storage") Or StringInStr($g_asUpgradeIgnore[$i][1], "Builder")) Then ContinueLoop
		For $g = 0 To UBound($g_asUpgradeIgnoreFilter) - 1
			If $g_asUpgradeIgnoreFilter[$g][0] = $g_asUpgradeIgnore[$i][3] And $g_asUpgradeIgnoreFilter[$g][1] = $sType Then Return True
		Next
	Next
	Return False
EndFunc   ;==>AutoUpgradeTypeWanted

; Rush TH setting on and the Town Hall level of the Rush TH settings not reached yet
Func AutoUpgradeRushActive()
	Return $g_bChkRushTH And Not IsTHLevelAchieved()
EndFunc   ;==>AutoUpgradeRushActive

; one type of the order: set the filter, upgrade affordable rows from the top until no builder is left or no row can be
; upgraded (scroll only while the page had affordable rows that were all skipped, see BuildMenuStopScroll).
; Return number of upgrades started, @extended: 1 = a row to wait for (not ignored, or red cost), 2 = stop (no builder)
Func AutoUpgradeTypePass($sType, $bTest = False)
	Local $sFilter = ($sType = "TH" Or $sType = "Key") ? "" : $sType ; Town Hall (Rush TH) has no filter button
	; gate buildings (user 31 Oct): TH16 Eagle Artillery = Defense filter, TH17 Inferno Artillery = no filter, TH18 Guardians = Hero
	If $sType = "Gate" Then $sFilter = Number($g_iTownHallLevel) = 16 ? "Defense" : (Number($g_iTownHallLevel) = 18 ? "Hero" : "")
	; wall reserve builder low cost mode: cheapest first (Cost Min sorting), the cheap rows are on the first page
	If $g_bUpgradeLowCost Then $sFilter &= "|CostMin"
	SetLog("Auto Upgrade: " & ($sType = "TH" ? "Town Hall (Rush TH)" : ($sType = "Key" ? "Hero Hall / Laboratory (Rush TH)" : ($sType = "Gate" ? "buildings the next Town Hall needs (Rush TH)" : ($sType = "" ? "rest of the list (no filter)" : $sType & " (filter)")))), $COLOR_INFO)
	If Not OpenBuildMenu(1, False, $sFilter) Then ; tab 1 (the menu opens on the last used tab) with the filter
		SetLog("Build menu " & ($sType = "" ? "" : "filter " & $sType & " ") & "failed, skip", $COLOR_WARNING)
		; 4 = filter not usable (no filter button while the Town Hall is upgrading). Not 1 (row to wait for): the "" pass reads
		; the whole list after this, an empty list there pauses Auto Upgrade (macia, Oct 2026: tried every loop while TH upgraded)
		Return SetExtended(4, 0)
	EndIf
	BuildMenuReadLoot(False)
	Local $iStarted = 0, $iExt = 0, $aSkip[0], $bAffordSeen = False, $bCheckNext = False, $iScroll = 0, $sSig = "", $sLastSig = "", $bGateSeen = False
	While $g_bRunState
		Local $aRow = AutoUpgradeFindRow($sType, $aSkip, $sSig)
		Local $iFlags = @extended
		If BitAND($iFlags, 16) Then $bGateSeen = True
		If BitAND($iFlags, 8) Then $iExt = BitOR($iExt, 1)
		If IsArray($aRow) Then
			Local $iRet = AutoUpgradeRow($aRow, $bTest)
			If $iRet = 1 Then
				$iStarted += 1
				If $bTest Then ExitLoop
				If Not IsBuildMenuOpen() And Not OpenBuildMenu(1, False, $sFilter) Then Return SetExtended(BitOR($iExt, 2), $iStarted) ; after Hero Hall window
				If Not AutoUpgradeCheckBuilder() Then Return SetExtended(BitOR($iExt, 2), $iStarted)
				ContinueLoop ; list changed: read this page again
			EndIf
			If $iRet < 0 Then Return SetExtended(BitOR($iExt, 2), $iStarted) ; upgrade not confirmed: stop, builders unknown
			_ArrayAdd($aSkip, $aRow[5])
			If Not IsBuildMenuOpen() Then ; row opened something else and it was closed with the menu
				If Not OpenBuildMenu(1, False, $sFilter) Then ExitLoop
				$iScroll = 0
				$bAffordSeen = False
				$bCheckNext = False
			EndIf
			ContinueLoop
		EndIf
		If $iScroll = 0 And $sSig = "" Then ExitLoop ; no row with a cost (only upgrades in progress, e.g. Town Hall upgrading)
		If $sType = "TH" And $iScroll >= 2 Then ExitLoop ; Town Hall cost is one of the highest: on top of the affordable rows
		If $sType = "Key" And $iScroll >= 3 Then ExitLoop ; Hero Hall / Laboratory costs are high too
		If $g_bUpgradeLowCost And $iScroll >= 2 Then ExitLoop ; Cost Min: rows below are more expensive
		If $sType = "Gate" Then ; whole list: the red / skipped rows above it say nothing about it
			If BitAND($iFlags, 16) Then ExitLoop ; gate row seen (not affordable now)
			If $iScroll >= 8 Then ExitLoop
		ElseIf BuildMenuStopScroll($iFlags, $bAffordSeen, $bCheckNext) Or $iScroll >= 6 Then
			ExitLoop
		EndIf
		If $iScroll > 0 And $sSig = $sLastSig Then ExitLoop ; list did not move: end reached
		$sLastSig = $sSig
		BuildMenuScrollDown()
		$iScroll += 1
	WEnd
	If $sType = "Gate" And Not $bGateSeen And $g_bRunState Then
		$g_ahRoutineTimer[CurAccountIndex()][6] = __TimerInit()
		SetLog("Rush TH: no building the next Town Hall needs in the Build menu (done / max), next search in 6 h", $COLOR_INFO)
	EndIf
	Return SetExtended($iExt, $iStarted)
EndFunc   ;==>AutoUpgradeTypePass

; first row of the visible page that can be upgraded: white cost, not "New", resource not ignored, name not in the
; ignore list ($aSkip = rows tried before, "name|resource"), Min Save kept. Rows above it are checked first (list order).
; Return [resource, icon x, icon y, name, cost (0 = not read), key] or 0. @extended = page flags of BuildMenuStopScroll,
; + 8 when a row to wait for was seen (not ignored, or red cost). $sSig = icons of the page (end of list check)
Func AutoUpgradeFindRow($sType, ByRef $aSkip, ByRef $sSig)
	Local $iFlags = 0
	$sSig = ""
	Local $aIcon = QuickMIS("CNX", $g_sImgResourceIcon, 830, 60, 850, 575)
	If Not IsArray($aIcon) Or UBound($aIcon) = 0 Then Return SetExtended(0, 0)
	RemoveDupCNX($aIcon, 2, 5)
	_ArraySort($aIcon, 0, 0, 0, 2)
	_CaptureRegion() ; one frame for the color checks of all rows
	For $i = 0 To UBound($aIcon) - 1
		$sSig &= $aIcon[$i][0] & $aIcon[$i][2] & "|"
	Next
	For $i = 0 To UBound($aIcon) - 1
		If Not $g_bRunState Then Return SetExtended($iFlags, 0)
		Local $sRes = $aIcon[$i][0], $iX = Number($aIcon[$i][1]), $iY = Number($aIcon[$i][2])
		If BuildMenuIsRedCost($iX, $iY) Then
			$iFlags = BitOR($iFlags, BitAND($iFlags, 2) ? 5 : 4, 8)
			If $sType = "Gate" Then ; gate row there but not affordable: stop the search (16), no 6 h skip
				Local $aRed = getBuildingName($g_iXFindUpgrade, $iY - 20, $iX - $g_iXFindUpgrade - 80, 18)
				If RushTHGateRow($aRed[0]) Then $iFlags = BitOR($iFlags, 16)
			EndIf
			ContinueLoop
		EndIf
		$iFlags = BitOR($iFlags, 2)
		If AutoUpgradeIsNewRow($iY) Then ContinueLoop ; new building to place, not an upgrade
		If AutoUpgradeResourceIgnored($sRes) Then ContinueLoop
		Local $aName = getBuildingName($g_iXFindUpgrade, $iY - 20, $iX - $g_iXFindUpgrade - 80, 18)
		Local $sName = $aName[0]
		If StringInStr($sName, "Wall") Then $sName = "Wall"
		If _ArraySearch($aSkip, $sName & "|" & $sRes) >= 0 Then ContinueLoop
		If $sType = "TH" And Not StringInStr($sName, "Town Hall") And Not RushTHGateRow($sName) Then ContinueLoop
		If $sType = "Key" And Not (StringInStr($sName, "Hero H") Or StringInStr($sName, "Labora")) Then ContinueLoop
		If $sType = "Gate" And Not RushTHGateRow($sName) Then ContinueLoop
		If $sType = "Gate" Then $iFlags = BitOR($iFlags, 16)
		; Hero filter also lists the TH18 Guardians (Longshot, Smasher, Logger, on top): Hero pass is for the 6 heroes,
		; Guardians (Defense group of "Upgrades to ignore") come with the rest of the list
		If $sType = "Hero" Then
			OcrMatchName($sName, $g_asHeroHallNames)
			If @extended <> 1 Then ContinueLoop
		EndIf
		; storages first: drills, collectors and mines come with the rest of the list
		If $sType = "Resource" And (StringInStr($sName, "Drill") Or StringInStr($sName, "Collector") Or StringInStr($sName, "Mine")) Then ContinueLoop
		If CheckIgnoreUpgrade($sName) Then ContinueLoop
		$iFlags = BitOR($iFlags, 8)
		If QuickMIS("BC1", $g_sImgAUpgradeObstGear, $g_iXFindUpgrade, $iY - 2, $iX - 230, $iY + 20) Then
			If $g_sQuickMISName = "Gear" And Not $g_bGearUpDone Then
				SetLog("Do GearUp result : " & String(DoGearUp($g_iQuickMISX + 20, $g_iQuickMISY)), $COLOR_INFO)
				$g_bGearUpDone = True
				Return SetExtended($iFlags, 0) ; GearUp window used the menu
			EndIf
			ContinueLoop
		EndIf
		Local $iCost = 0
		If AutoUpgradeMinSave($sRes) > 0 Or $g_bUpgradeLowCost Then ; cost OCR only to keep the Min Save or the low cost limit
			$iCost = BuildMenuReadCost($iX, $iY)
			If $iCost <= 0 Then
				SetLog($sName & ": cost not readable, skip (Min Save / low cost limit)", $COLOR_DEBUG1)
				ContinueLoop
			EndIf
			If $g_bUpgradeLowCost And Not AutoUpgradeLowCostOk($sRes, $iCost) Then
				SetLog($sName & ": " & _NumberFormat($iCost) & " " & $sRes & ", above the low cost limit of the wall reserve builder", $COLOR_DEBUG1)
				ContinueLoop
			EndIf
			If AutoUpgradeMinSave($sRes) > 0 And Not CheckResourceForDoUpgrade($sName, $iCost, $sRes) Then ContinueLoop
		EndIf
		If UpgradeDeadlineLeft() >= 0 And Not UpgradeDeadlineOk($sName, BuildMenuRowTimeStrict($iY)) Then ContinueLoop
		Local $aRet[6] = [$sRes, $iX, $iY, $sName, $iCost, $sName & "|" & $sRes]
		Return SetExtended($iFlags, $aRet)
	Next
	Return SetExtended($iFlags, 0)
EndFunc   ;==>AutoUpgradeFindRow

; green name = new building to place (uses last _CaptureRegion frame)
Func AutoUpgradeIsNewRow($iY)
	Local $iGreen = 0
	For $x = $g_iXFindUpgrade To $g_iXFindUpgrade + 150 Step 3
		For $y = $iY - 22 To $iY - 6 Step 2
			If _ColorCheck(_GetPixelColor($x, $y, False), Hex(0xB4F756, 6), 38) Then $iGreen += 1
		Next
	Next
	Return $iGreen >= 5
EndFunc   ;==>AutoUpgradeIsNewRow

Func AutoUpgradeResourceIgnored($sRes)
	Switch $sRes
		Case "Gold"
			Return $g_iChkResourcesToIgnore[0] = 1
		Case "Elix"
			Return $g_iChkResourcesToIgnore[1] = 1
		Case "DE"
			Return $g_iChkResourcesToIgnore[2] = 1
	EndSwitch
	Return False
EndFunc   ;==>AutoUpgradeResourceIgnored

Func AutoUpgradeMinSave($sRes)
	Switch $sRes
		Case "Gold"
			Return Number($g_iTxtSmartMinGold)
		Case "Elix"
			Return Number($g_iTxtSmartMinElixir)
		Case "DE"
			Return Number($g_iTxtSmartMinDark)
	EndSwitch
	Return 0
EndFunc   ;==>AutoUpgradeMinSave

; wall reserve builder used while the first upgrade ends in more than 12 h: only cheap upgrades
Func AutoUpgradeLowCostOk($sRes, $iCost)
	Return $iCost <= ($sRes = "DE" ? 50000 : 500000)
EndFunc   ;==>AutoUpgradeLowCostOk

; click the row and start the upgrade. Return 1 = started (free builder count went down), 0 = not started (skip row),
; -1 = upgrade clicked but not confirmed by the builder count
Func AutoUpgradeRow(ByRef $aRow, $bTest = False)
	Local $sName = $aRow[3], $iFreeBefore = $g_iFreeBuilderCount
	SetLog("Auto Upgrade: " & $sName & ($aRow[4] > 0 ? ", cost " & _NumberFormat($aRow[4]) : "") & " " & $aRow[0], $COLOR_ACTION)
	Click($aRow[1], $aRow[2])
	If _Sleep(1000) Then Return 0
	Local $aHeroes[6] = ["Barbarian", "Queen", "Warden", "Champion", "Prince", "Duke"]
	For $sHero In $aHeroes
		If StringInStr($sName, $sHero) Then
			If $bTest Then ExitLoop
			If Not DoUpgradeHero($sName, $aRow[4], $aRow[0]) Then
				ClickAway()
				Return 0
			EndIf
			; Hero Hall window: builder counters are read again when the menu is opened (AutoUpgradeTypePass)
			ClickAway("Right")
			If _Sleep(500) Then Return 1
			Return 1
		EndIf
	Next
	; Wall row selects a wall, Crafting Station opens its own panel: no upgrade window
	If Not IsUpgradeWindowOpen() Then
		SetLog($sName & ": upgrade window not opened, skip", $COLOR_WARNING)
		ClickAway("Right")
		If _Sleep(500) Then Return 0
		Return 0
	EndIf
	If $bTest Then
		SetLog("[test] " & $sName & " upgrade window OK, not confirmed", $COLOR_DEBUG)
		ClickAway("Right")
		Return 1
	EndIf
	If Not DoUpgrade(False, False, $sName) Then
		ClickAway("Right")
		Return 0
	EndIf
	If StringInStr($sName, "Town Hall") Then AutoUpgradeContinueTH()
	; a started upgrade takes a builder
	For $i = 1 To 4
		If _Sleep(500) Then Return 0
		Local $sBuilder = getBuildersOnMenu()
		If StringInStr($sBuilder, "#") And Int(StringLeft($sBuilder, StringInStr($sBuilder, "#") - 1)) < $iFreeBefore Then Return 1
	Next
	SetLog($sName & ": free builder count did not go down, upgrade not confirmed", $COLOR_ERROR)
	Return -1
EndFunc   ;==>AutoUpgradeRow

; Town Hall "before you upgrade" warning after the upgrade click
Func AutoUpgradeContinueTH()
	If _Sleep(800) Then Return
	Local $aBtn = findButton("Continue", Default, 1, True)
	If IsArray($aBtn) And UBound($aBtn, 1) = 2 Then
		SetLog("Town Hall upgrade warning: Continue", $COLOR_INFO)
		Click($aBtn[0], $aBtn[1], 1, 0, "Continue Town Hall upgrade")
		If _Sleep(800) Then Return
	EndIf
EndFunc   ;==>AutoUpgradeContinueTH

Func FindUpgrade($bTest = False, $bSkipNew = False, $bLowCost = False, $bUseWallReserve = False)
	If Not $g_bRunState Then Return
	SetLog("[FindUpgrade] RushTH:" & String($g_bChkRushTH) & ", UpLowCost:" & String($bLowCost) & ", OtherDef:" & String($g_bUpgradeOtherDefenses), $COLOR_DEBUG1)
	If $g_bChkRushTH And Not IsTHLevelAchieved() Then SetLog("[FindUpgrade] Only Search for RushTH Building", $COLOR_INFO)
	If $bSkipNew Then SetLog("[FindUpgrade] Skip Search for New Building", $COLOR_INFO)
	If $bUseWallReserve Then SetLog("[FindUpgrade] Search for using last Builder", $COLOR_INFO)
	;If $g_bUpgradeOtherDefenses Then $bSkipNew = False
	
	Local $ElixMultiply = 1, $GoldMultiply = 1 ;used for multiply score
	Local $Gold = $g_aiCurrentLoot[$eLootGold]
	Local $Elix = $g_aiCurrentLoot[$eLootElixir]
	If $Gold > $Elix Then $GoldMultiply += 1
	If $Elix > $Gold Then $ElixMultiply += 1
	Local $aTmpCoord, $aBuilding[0][8], $BuildingName, $UpgradeCost, $aUpgradeName, $tmpcost, $bFoundRushTH = False, $bRusTHFound = False, $lenght = 0
	Local $aPriority[8][2] = [["Castle", 13], ["Pet", 13], ["Laboratory", 16], ["Storage", 13], ["Barracks", 14], ["Army", 11], ["Giga", 12], ["Town", 10]]
	Local $aRushTH[11][2] = [["Hero Hall", 13], ["Barracks", 8], ["Spell Factory", 9], ["Workshop", 10], ["Blacksmith", 9], ["King", 8], ["Queen", 8], ["Warden", 8], ["Champion", 8], ["Prince", 8], ["Duke", 8]]
	Local $aHeroes[6] = ["Barbarian", "Queen", "Warden", "Champion", "Prince", "Duke"]
	Local $bHero = False, $iFlags = 0

	;check if we found new building
	;If Not $bSkipNew And Not $bLowCost Then $aTmpCoord = QuickMIS("CNX", $g_sImgAUpgradeObstNew, $g_iXFindUpgrade, 73, 450, 400)
	;If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
	;	If Not $g_bRunState Then Return
	;	_ArraySort($aTmpCoord, 0, 0, 0, 2)
	;	For $i = 0 To UBound($aTmpCoord) - 1
	;		Local $sCostType = ""
	;		If QuickMIS("BC1", $g_sImgResourceIcon, $aTmpCoord[$i][1] + 80, $aTmpCoord[$i][2] - 12, $aTmpCoord[$i][1] + 260, $aTmpCoord[$i][2] + 10) Then
	;			$sCostType = $g_sQuickMISName
	;			$lenght = Number($g_iQuickMISX) - $aTmpCoord[$i][1]
	;			If $aTmpCoord[$i][0] = "New" And $sCostType = "Free" Then 
	;				$lenght = 33
	;				$sCostType = "Gold" ;force to be gold, this is for wall
	;			EndIf
	;		EndIf
	;
	;		$aUpgradeName = getBuildingName($aTmpCoord[$i][1] + 10, $aTmpCoord[$i][2] - 12, $lenght) ;get upgrade name and amount
	;		$tmpcost = getBuilderMenuCost($g_iQuickMISX + 5, $g_iQuickMISY - 10)
	;		If StringInStr($aUpgradeName[0], "Wall") Then $aUpgradeName[0] = "Wall"
	;		;If $sCostType = "Gem" And Number($tmpcost) = 0 Then ContinueLoop
	;		Local $tmparray[1][8] = [[String($sCostType), $aTmpCoord[$i][1], Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), "New", Number($tmpcost), "New", 0]]
	;		_ArrayAdd($aBuilding, $tmparray)
	;		If @error Then SetLog("FindUpgrade ComposeArray[New] Err : " & @error, $COLOR_ERROR)
	;	Next
	;	Local $aMultiBuilding[2] = ["Ricochet.+", "Multi.+"]
	;	For $sName In $aMultiBuilding
	;		Local $iIndex = _ArraySearch($aBuilding, $sName, 0, 0, 0, 3, 0, 3)
	;		If $iIndex > -1 Then
	;			SetLog("Found NewBuilding " & $aBuilding[$iIndex][3] & ", skip!!", $COLOR_ACTION)
	;			_ArrayDelete($aBuilding, $iIndex)
	;		EndIf
	;	Next
	;EndIf
	If Not $g_bRunState Then Return
	
	;rest upgrades
	$aTmpCoord = QuickMIS("CNX", $g_sImgResourceIcon, 830, 60, 850, 575)
	If IsArray($aTmpCoord) And UBound($aTmpCoord) > 0 Then
		If Not $g_bRunState Then Return
		RemoveDupCNX($aTmpCoord, 2, 5)
		_ArraySort($aTmpCoord, 0, 0, 0, 2)
		; red cost row (not enough resource) is skipped, page flags for the scroll rule (BuildMenuStopScroll)
		_CaptureRegion()
		Local $abRed[UBound($aTmpCoord)]
		For $i = 0 To UBound($aTmpCoord) - 1
			$abRed[$i] = BuildMenuIsRedCost(Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]))
			If $abRed[$i] Then
				$iFlags = BitOR($iFlags, BitAND($iFlags, 2) ? 5 : 4)
			Else
				$iFlags = BitOR($iFlags, 2)
			EndIf
		Next
		For $i = 0 To UBound($aTmpCoord) - 1
			If Not $g_bRunState Then Return
			If $abRed[$i] Then ContinueLoop
			If QuickMIS("BC1",$g_sImgAUpgradeObstGear, $g_iXFindUpgrade, $aTmpCoord[$i][2] - 2, $aTmpCoord[$i][1] - 230, $aTmpCoord[$i][2] + 20) Then
				If $g_sQuickMISName = "Gear" And Not $g_bGearUpDone Then
					Local $bRet = DoGearUp($g_iQuickMISX + 20, $g_iQuickMISY)
					SetLog("Do GearUp result : " & String($bRet), $COLOR_INFO)
					$g_bGearUpDone = True
				Else
					ContinueLoop ;skip list upgrade after try do GearUp
				EndIf
			EndIf
		
			$lenght = Number($aTmpCoord[$i][1]) - $g_iXFindUpgrade - 80
			$aUpgradeName = getBuildingName($g_iXFindUpgrade, $aTmpCoord[$i][2] - 20, $lenght, 18) ;get upgrade name
			$tmpcost = getBuilderMenuCost($aTmpCoord[$i][1] - 120, $aTmpCoord[$i][2] - 2)
			If StringInStr($aUpgradeName[0], "Wall") Then $aUpgradeName[0] = "Wall"
			If Number($tmpcost) = 0 Then ContinueLoop
			If $g_bHeroPriority Then
				$bHero = False
				For $Hero In $aHeroes
					If StringInStr($aUpgradeName[0], $Hero) > 0 Then 
						SetLog("HeroPriority=" & String($g_bHeroPriority) & ", " & $aUpgradeName[0] & " : " & $tmpcost & ", include to list!", $COLOR_DEBUG1)
						$bHero = True
					EndIf
				Next
			EndIf
			
			If $bLowCost Then
				If Number($tmpcost) > 500000 And Not $bHero Then
					SetLog("UpLowCost=" & String($bLowCost) & ", " & $aUpgradeName[0] & " : " & $tmpcost & " > 500000, skip", $COLOR_DEBUG1)
					ContinueLoop
				EndIf
			EndIf
			If $bUseWallReserve Then
				If Number($tmpcost) < 500000  And Not $bHero Then
					SetLog("UseWallReserve=" & String($g_bSkipWallReserve) & ", " & $aUpgradeName[0] & " : " & $tmpcost & " < 500000, skip", $COLOR_DEBUG1)
					ContinueLoop
				EndIf
			EndIf
			If CheckIgnoreUpgrade($aUpgradeName[0], $bLowCost) Then
				;SetLog("UpLowCost=" & String($bLowCost) & ", UseWallReserve=" & String($bUseWallReserve), $COLOR_DEBUG1)
				;SetLog("UpgradeOtherDefenses=" & String($g_bUpgradeOtherDefenses), $COLOR_DEBUG1)
				SetLog($aUpgradeName[0] & " : " & $tmpcost & ", must be Ignored!", $COLOR_DEBUG2)
				ContinueLoop
			EndIf
			
			Local $tmparray[1][8] = [[String($aTmpCoord[$i][0]), Number($aTmpCoord[$i][1]), Number($aTmpCoord[$i][2]), String($aUpgradeName[0]), Number($aUpgradeName[1]), Number($tmpcost), 0, 0]]
			_ArrayAdd($aBuilding, $tmparray)
			If @error Then SetLog("FindUpgrade ComposeArray Err : " & @error, $COLOR_ERROR)
		Next

		For $j = 0 To UBound($aBuilding) -1
			$BuildingName = $aBuilding[$j][3]
			$UpgradeCost = $aBuilding[$j][5]
			$aBuilding[$j][6] = 1
			For $k = 0 To UBound($aPriority) - 1
				If StringInStr($BuildingName, $aPriority[$k][0]) Then
					If $g_bDebugSetLog Then SetLog("[Priority] " & $aPriority[$k][0] & " : " & $BuildingName, $COLOR_DEBUG1)
					Switch $aBuilding[$j][0]
						Case "Gold"
							$aBuilding[$j][6] = $aPriority[$k][1] * $GoldMultiply
						Case "Elix"
							$aBuilding[$j][6] = $aPriority[$k][1] * $ElixMultiply
						Case "DE"
							$aBuilding[$j][6] = $aPriority[$k][1]
					EndSwitch
					$aBuilding[$j][7] = "Priority"
				EndIf
			Next

			If Not $bLowCost Then
				For $k = 0 To UBound($aRushTH) - 1
					If StringInStr($BuildingName, $aRushTH[$k][0]) Then
						If $g_bDebugSetLog Then SetLog("[RushTH] " & $aRushTH[$k][0] & " : " & $BuildingName, $COLOR_DEBUG1)
						Switch $aBuilding[$j][0]
							Case "Gold"
								$aBuilding[$j][6] = $aRushTH[$k][1] * $GoldMultiply
							Case "Elix"
								$aBuilding[$j][6] = $aRushTH[$k][1] * $ElixMultiply
							Case "DE"
								$aBuilding[$j][6] = $aRushTH[$k][1]
						EndSwitch
						$aBuilding[$j][7] = "RushTH"
					EndIf
				Next

				For $k = 0 To UBound($g_aichkEssentialUpgrade) - 1
					;If $g_bDebugSetLog Then SetDebugLog($BuildingName & "|" & $g_aEssential[$k])
					If StringInStr($BuildingName, $g_aEssential[$k]) Then
						SetLog("[Essential] " & $g_aEssential[$k] & " : " & $BuildingName & ", Enabled : " & String($g_aichkEssentialUpgrade[$k] = 1 ? True : False), $COLOR_DEBUG1)
						If $g_aichkEssentialUpgrade[$k] = 1 Then
							$aBuilding[$j][6] = 9
							$aBuilding[$j][7] = "Essential"
						Else
							$aBuilding[$j][6] = "Disabled"
						EndIf
					EndIf
				Next

				If $g_bUpgradeOtherDefenses Then
					For $sName In $g_aOtherDefense
						If StringInStr($BuildingName, $sName) Then
							If $g_bDebugSetLog Then SetLog("[OtherDefense] " & $sName & " : " & $BuildingName, $COLOR_DEBUG1)
							$aBuilding[$j][6] = 8
							$aBuilding[$j][7] = "OtherDefense"
						EndIf
					Next
				EndIf
			Else
				$aBuilding[$j][7] = "LowCost"
			EndIf

			If $g_bHeroPriority Then ;set score = 20 for Heroes, so if there is heroes found for upgrade it will attempt first
				For $l = 0 To UBound($aHeroes) - 1
					If StringInStr($BuildingName, $aHeroes[$l]) Then
						If $g_bDebugSetLog Then SetLog("[HeroPriority] " & $aHeroes[$l] & " : " & $BuildingName, $COLOR_DEBUG1)
						$aBuilding[$j][6] = 20
						$aBuilding[$j][7] = "HeroPriority"
					EndIf
				Next
			EndIf
			If $g_bDebugSetLog Then SetLog("Scoring: " & $BuildingName & ", Cost=" & $UpgradeCost & ", Score=" & $aBuilding[$j][6], $COLOR_DEBUG1)
		Next
	EndIf

	;search upgrade with ocr read failed
	Local $iIndex = _ArraySearch($aBuilding, "0", 0, 0, 0, 0, 0, 5)
	If $iIndex > -1 Then
		SetLog("Found Building " & $aBuilding[$iIndex][3] & " with Zero cost, skip!!", $COLOR_ACTION)
		_ArrayDelete($aBuilding, $iIndex)
	EndIf
	Return SetExtended($iFlags, $aBuilding) ; @extended = page flags, see BuildMenuStopScroll
EndFunc

; index in $g_asUpgradeIgnore for a building name read by OCR, -1 if not in the list
Func UpgradeIgnoreIndex($sUpgradeName)
	Local $sName = OcrMatchBuildingName($sUpgradeName)
	For $i = 0 To UBound($g_asUpgradeIgnore) - 1
		Local $aAlias = StringSplit($g_asUpgradeIgnore[$i][1], "|", $STR_NOCOUNT)
		For $sAlias In $aAlias
			If $sName = $sAlias Then Return $i
		Next
	Next
	; hero upgrade names can contain level or more text
	For $i = 0 To UBound($g_asUpgradeIgnore) - 1
		If $g_asUpgradeIgnore[$i][3] = "H" And StringInStr($sName, $g_asUpgradeIgnore[$i][1]) Then Return $i
	Next
	Return -1
EndFunc   ;==>UpgradeIgnoreIndex

Func CheckResourceForDoUpgrade($BuildingName, $Cost, $CostType)
	If Not $g_bRunState Then Return
	If $g_bDebugSetLog Then SetLog("Gold:" & $g_aiCurrentLoot[$eLootGold] & " Elix:" & $g_aiCurrentLoot[$eLootElixir] & " DE:" & $g_aiCurrentLoot[$eLootDarkElixir] & " GEM:" & $g_iGemAmount, $COLOR_DEBUG1)

	; initiate a False boolean, that firstly says that there is no sufficent resource to launch upgrade
	Local $bSufficentResourceToUpgrade = False
	; if Cost of upgrade + Value set in settings to be kept after upgrade > Current village resource, make boolean True and can continue
	Switch $CostType
		Case "Gold"
			If $g_aiCurrentLoot[$eLootGold] >= ($Cost + $g_iTxtSmartMinGold) Then $bSufficentResourceToUpgrade = True
			If (StringInStr($BuildingName, "Giga") Or StringInStr($BuildingName, "Town")) And $g_aiCurrentLoot[$eLootGold] >= $Cost Then ;bypass save resource for TH and TH weapon
				SetLog("Bypass autoupgrade save Min Gold", $COLOR_DEBUG1)
				$bSufficentResourceToUpgrade = True
			EndIf
			If Not $bSufficentResourceToUpgrade Then SetLog($g_aiCurrentLoot[$eLootGold] & "-" & $Cost & " < " & $g_iTxtSmartMinGold, $COLOR_DEBUG1)
		Case "Elix"
			If $g_aiCurrentLoot[$eLootElixir] >= ($Cost + $g_iTxtSmartMinElixir) Then
				$bSufficentResourceToUpgrade = True
			Else
				SetLog($g_aiCurrentLoot[$eLootElixir] & "-" & $Cost & " < " & $g_iTxtSmartMinElixir, $COLOR_DEBUG1)
			EndIf
		Case "DE"
			If $g_aiCurrentLoot[$eLootDarkElixir] >= ($Cost + $g_iTxtSmartMinDark) Then
				$bSufficentResourceToUpgrade = True
			Else
				SetLog($g_aiCurrentLoot[$eLootDarkElixir] & "-" & $Cost & " < " & $g_iTxtSmartMinDark, $COLOR_DEBUG1)
			EndIf
		Case "Gem"
			If CheckPlaceBuilder() Then $bSufficentResourceToUpgrade = True
	EndSwitch
	SetLog("Checking: " & $BuildingName & ", Cost: " & $Cost & " " & $CostType, $COLOR_INFO)
	SetLog("Is Enough " & $CostType & " ? " & String($bSufficentResourceToUpgrade), $bSufficentResourceToUpgrade ? $COLOR_SUCCESS : $COLOR_ERROR)
	
	If $g_iChkResourcesToIgnore[0] = 1 And $CostType = "Gold" Then 
		$bSufficentResourceToUpgrade = False
		SetLog("Resource Gold, set to Ignored", $COLOR_DEBUG2)
	ElseIf $g_iChkResourcesToIgnore[1] = 1 And $CostType = "Elix" Then 
		$bSufficentResourceToUpgrade = False
		SetLog("Resource Elix, set to Ignored", $COLOR_DEBUG2)
	ElseIf $g_iChkResourcesToIgnore[2] = 1 And $CostType = "DE" Then 
		$bSufficentResourceToUpgrade = False
		SetLog("Resource DE, set to Ignored", $COLOR_DEBUG2)
	EndIf
	
	Return $bSufficentResourceToUpgrade
EndFunc

Func CheckIgnoreUpgrade($sUpgradeName = "", $bUpgradeLowCost = False)
	Local $bMustIgnoreUpgrade = False
	Local $iIgnore = UpgradeIgnoreIndex($sUpgradeName)
	If $iIgnore >= 0 Then $bMustIgnoreUpgrade = ($g_iChkUpgradesToIgnore[$iIgnore] = 1)

	; "Only Upgrade Buildings If TH Level Already Achieved": Rush TH ignore list is used until TH reaches the wanted level
	If $bMustIgnoreUpgrade And $g_bChkRushTH And $g_bUpgradeOnlyTHLevelAchieve And IsTHLevelAchieved() Then
		$bMustIgnoreUpgrade = False
		SetDebugLog("[RushTH] TH level achieved, " & $sUpgradeName & " allowed")
	EndIf

	; buildings the next Town Hall level needs (Rush TH gate) are upgraded although Rush TH ignores defenses
	If $bMustIgnoreUpgrade And AutoUpgradeRushActive() And RushTHGateRow($sUpgradeName) Then
		$bMustIgnoreUpgrade = False
		SetLog("[RushTH] " & $sUpgradeName & " needed for the next Town Hall level, allowed", $COLOR_DEBUG1)
	EndIf

	; Rush TH ignores defenses, but "Essential Building" selected in Rush TH setting must still be upgraded
	If $bMustIgnoreUpgrade And $g_bChkRushTH Then
		For $k = 0 To UBound($g_aEssential) - 1
			If $g_aichkEssentialUpgrade[$k] = 1 And StringInStr($sUpgradeName, $g_aEssential[$k]) Then
				$bMustIgnoreUpgrade = False
				SetLog("[RushTH Essential] " & $sUpgradeName & " allowed", $COLOR_DEBUG1)
				ExitLoop
			EndIf
		Next
	EndIf

	If $bUpgradeLowCost Then
		$bMustIgnoreUpgrade = False
		SetLog("[UpgradeLowCost] " & $sUpgradeName & ", CheckIgnoreUpgrade: " & String($bMustIgnoreUpgrade), $COLOR_DEBUG1)
	EndIf

	If $g_bUpgradeOtherDefenses Then ;bypass for other defense building
		For $sName In $g_aOtherDefense
			If StringInStr($sUpgradeName, $sName) Then
				$bMustIgnoreUpgrade = False
				SetLog("[OtherDefense] " & $sUpgradeName & ", CheckIgnoreUpgrade: " & String($bMustIgnoreUpgrade), $COLOR_DEBUG1)
				ExitLoop
			EndIf
		Next
	EndIf

	SetLog("CheckIgnoreUpgrade: " & $sUpgradeName & ", result=" & String($bMustIgnoreUpgrade), $COLOR_DEBUG1)
	Return $bMustIgnoreUpgrade
EndFunc

Func DoUpgrade($bTest = False, $bUpgradeLowCost = False, $upgradeName = "")
	If Not $g_bRunState Then Return

	; get the name and actual level of upgrade selected, if strings are empty, will exit Auto Upgrade, an error happens
	;$g_aUpgradeNameLevel = BuildingInfo()
	;If $g_aUpgradeNameLevel[0] = "" Then
	;	SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
	;	Return False
	;EndIf

	Local $bMustIgnoreUpgrade = False, $bUpgradeTHWeapon = False

	; Double check if wrong click happen
	If CheckIgnoreUpgrade($upgradeName, $g_bUpgradeLowCost) Then $bMustIgnoreUpgrade = True
	If $g_bChkRushTH And Not $bMustIgnoreUpgrade And RushTHLevelReached($upgradeName) Then $bMustIgnoreUpgrade = True


	If $bUpgradeLowCost Then $bMustIgnoreUpgrade = False
	; check if the upgrade name is on the list of upgrades that must be ignored
	If $bMustIgnoreUpgrade Then
		SetLog($upgradeName & " : This upgrade must be ignored, looking Next...", $COLOR_WARNING)
		Return False
	Else
		SetLog("UpgradeName: " & $upgradeName, $COLOR_DEBUG)
	EndIf

	$g_aUpgradeResourceCostDuration[0] = QuickMIS("N1", $g_sImgAUpgradeRes, 660, 500, 710, 580) ; get resource
	$g_aUpgradeResourceCostDuration[1] = getOcrAndCapture("coc-bonus", 558, 543, 110, 20, True) ; get cost
	$g_aUpgradeResourceCostDuration[2] = getHeroUpgradeTime(730, 546) ; get duration

	;If $g_aUpgradeNameLevel[1] = "Clan Castle" And $g_aUpgradeNameLevel[2] = "Broken" Then
	;	$g_aUpgradeResourceCostDuration[0] = "Gold"
	;	$g_aUpgradeResourceCostDuration[1] = "10000" ; get cost
	;	$g_aUpgradeResourceCostDuration[2] = "Instance Upgrade"
	;EndIf

	Local $bMustIgnoreResource = False
	; matchmaking between resource name and the ignore list
	Switch $g_aUpgradeResourceCostDuration[0]
		Case "Gold"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[0] = 1) ? True : False
		Case "Elixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[1] = 1) ? True : False
		Case "DarkElixir"
			$bMustIgnoreResource = ($g_iChkResourcesToIgnore[2] = 1) ? True : False
		Case Else
			$bMustIgnoreResource = False
	EndSwitch

	; check if the resource of the upgrade must be ignored
	If $bMustIgnoreResource = True Then
		SetLog($upgradeName & ": This resource must be ignored, looking Next...", $COLOR_WARNING)
		Return False
	EndIf

	; final click on upgrade button, click coord is get looking at upgrade type (heroes have a diferent place for Upgrade button)
	If Not $bTest Then
		Click(625, 545)
	Else
		ClickAway("Right")
		Return False
	EndIf

	; update Logs and History file
	;If $upgradeName = "Town Hall" Then
	;	If _Sleep(1000) Then Return
	;	If _ColorCheck(_GetPixelColor(340, 510, True), Hex(0xFFCC7F, 6), 20, Default, "AutoUpgrade") And _ColorCheck(_GetPixelColor(510, 510, True), Hex(0xDDF685, 6), 20, Default, "AutoUpgrade") Then
	;		SetLog("Detected Before you upgrade warning window", $COLOR_INFO)
	;		Click(510, 525)
	;		If _Sleep(1000) Then Return
	;	EndIf
	;EndIf
	
	SetLog("Launched upgrade of " & $upgradeName & " successfully !", $COLOR_SUCCESS)
	
	If IsGemOpen(True) Then
		ClickAway("Right")
		SetLog("Something is wrong, Gem Window Opened", $COLOR_ERROR)
		ClickAway("Right")
	Else
		SetLog(" - Cost : " & _NumberFormat($g_aUpgradeResourceCostDuration[1]) & " " & $g_aUpgradeResourceCostDuration[0], $COLOR_SUCCESS)
		SetLog(" - Duration : " & $g_aUpgradeResourceCostDuration[2], $COLOR_SUCCESS)
		AutoUpgradeLog(False, $upgradeName, "", $g_aUpgradeResourceCostDuration[1], $g_aUpgradeResourceCostDuration[2])
	EndIf

	Return True
EndFunc

Func DoUpgradeHero($sHeroName = "Barbarian King", $Cost = "1000", $CostType = "DE")
	Local $aCheckAreaKing[4] = [100, 360, 190, 420]
	Local $aCheckAreaQueen[4] = [250, 360, 350, 420]
	Local $aCheckAreaPrince[4] = [400, 360, 490, 420]
	Local $aCheckAreaWarden[4] = [450, 360, 540, 420]
	Local $aCheckAreaChampion[4] = [600, 360, 690, 420]
	Local $aCheckAreaDuke[4] = [750, 360, 840, 420]
	Local $aCheckArea, $bRet = False
	Local $iHeroUpgradeTime = ""
	
	Switch $sHeroName
		Case "Barbarian King"
			$aCheckArea = $aCheckAreaKing
		Case "Archer Queen"
			$aCheckArea = $aCheckAreaQueen
		Case "Minion Prince"
			$aCheckArea = $aCheckAreaPrince
		Case "Grand Warden"
			$aCheckArea = $aCheckAreaWarden
		Case "Royal Champion", "Royal Champ"
			$aCheckArea = $aCheckAreaChampion
		Case "Dragon Duke"
			$aCheckArea = $aCheckAreaDuke
		Case Else
			Setlog("What Hero? banana", $COLOR_DEBUG2)
			$aCheckArea = $aCheckAreaKing
	EndSwitch
	
	If Not IsUpgradeWindowOpen() Then
		SetLog("Unable to Verify Upgrade Window", $COLOR_DEBUG2)
		Return
	Else
		$iHeroUpgradeTime = getHeroUpgradeTime(730, 546) ; get duration
		Click(625, 545) ;click upgrade button
		
		If _Sleep(1000) Then Return
		
		; update Logs and History file
		SetLog("Launched upgrade for Hero : " & $sHeroName & " successfully !", $COLOR_SUCCESS)

		If IsGemOpen(True) Then
			ClickAway("Right")
			SetLog("Something is wrong, Gem Window Opened", $COLOR_ERROR)
			ClickAway("Right")
			Return $bRet
		Else
			SetLog(" - Cost : " & _NumberFormat($Cost) & " " & $CostType, $COLOR_SUCCESS)
			SetLog(" - Duration : " & $iHeroUpgradeTime, $COLOR_SUCCESS)
			AutoUpgradeLog(False, $sHeroName, "??", $Cost, $CostType)
			$bRet = True
		EndIf
		
		If $g_bUseHeroBooks Then
			Local $HeroUpgradeTime = ConvertOCRTime("UseHeroBooks", $iHeroUpgradeTime, False)
			If $HeroUpgradeTime >= ($g_iHeroMinUpgradeTime * 1440) Then
				SetLog("Hero Upgrade Time: [" & $HeroUpgradeTime & "] minutes", $COLOR_DEBUG)
				SetLog("MinUpgradeTime on Setting: [" & ($g_iHeroMinUpgradeTime * 1440) & "] minutes", $COLOR_DEBUG)
				;If IsHeroHallWindow() Then 
				;	SetLog("Looking if Hero Books avail", $COLOR_ACTION)
				;	If QuickMIS("BC1", $g_sImgHeroBooks, $aCheckArea[0], $aCheckArea[1], $aCheckArea[2], $aCheckArea[3]) Then ; search image Hero books on Hero Hall
				;		SetLog("You Have hero book available", $COLOR_INFO)
				;		Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Hero Books")
				;		If _Sleep(500) Then return
				;		If WaitforPixel(420, 435, 421, 435, "2F93CF", 10, 1, "Confirm Use Book") Then
				;			Click(420, 430, 1, 0, "Confirm Use Book")
				;		EndIf
				;		SetLog("Successfully using Hero Book", $COLOR_SUCCESS)
				;	Else
				;		SetLog("No Hero Book Available", $COLOR_DEBUG2)
				;	EndIf
				;Else
				;	SetLog("Unable to verify Hero Hall Window", $COLOR_DEBUG2)
				;EndIf
			Else
				SetLog("Use Hero Books enabled, but hero Upgrade time < " & $g_iHeroMinUpgradeTime & " Days", $COLOR_DEBUG2)
			EndIf
		EndIf
		If _Sleep(500) Then Return
	EndIf
	
	Return $bRet
EndFunc



Func OpenShop($sUpgradeType = "Traps", $bCheckRedCounter = True)
	If Not $g_bRunState Then Return
	Local $bRet = False
	If WaitforPixel(815, 590, 816, 591, "E6F3ED", 10, 1, "OpenShop") Then
		Click(815, 590) ;Click Shop Button
		If _Sleep(1000) Then Return
	EndIf

	For $i = 1 To 5
		SetLog("Waiting Shop Window #" & $i, $COLOR_ACTION)
		If IsFullScreenWindow() Then
			If QuickMIS("BC1", $g_sImgBuildingAndTraps, 150, 10, 320, 85) Then
				Click($g_iQuickMISX, $g_iQuickMISY) ;click Building and traps Tab
				If $g_sQuickMISName = "BuildActive" Then
					$bRet = True
					ExitLoop
				EndIf
			EndIf
			If _Sleep(1000) Then Return
		EndIf
		If _Sleep(500) Then Return
	Next

	If Not $bCheckRedCounter Then Return $bRet

	$bRet = False ;reset for checking red counter
	Local $aRedPos[4] = [254, 417, 581, 746], $iRedPosY = 157
	If $bCheckRedCounter Then
		Switch $sUpgradeType
			Case "Army"
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShop-Army") Then
					Click($aRedPos[0], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[0], $iRedPosY, $aRedPos[0] + 1, $iRedPosY + 1, "BBDC9D", 10, 1, "OpenShop-Army") Then
					$bRet = True
				EndIf
			Case "Resources"
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShop-Resources") Then
					Click($aRedPos[1], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[1], $iRedPosY, $aRedPos[1] + 1, $iRedPosY + 1, "BBDC9D", 10, 1, "OpenShop-Resources") Then
					$bRet = True
				EndIf
			Case "Defenses"
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShop-Defenses") Then
					Click($aRedPos[2], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[2], $iRedPosY, $aRedPos[2] + 1, $iRedPosY + 1, "BBDC9D", 10, 1, "OpenShop-Defenses") Then
					$bRet = True
				EndIf
			Case "Traps"
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "D7081B", 10, 1, "OpenShop-Traps") Then
					Click($aRedPos[3], $iRedPosY)
					$bRet = True
				EndIf
				If WaitforPixel($aRedPos[3], $iRedPosY, $aRedPos[3] + 1, $iRedPosY + 1, "BBDC9D", 10, 1, "OpenShop-Traps") Then
					$bRet = True
				EndIf
		EndSwitch

		If Not $bRet Then
			SetLog("Fail Verify " & $sUpgradeType & " Tab, exit!", $COLOR_ERROR)
			Click(820, 37) ;close shop window
			Return $bRet
		EndIf
	EndIf
	SetLog("Opening " & $sUpgradeType & " Tab", $COLOR_ACTION)
	Return $bRet
EndFunc ;OpenShop


Func SearchGreenZone()
	If Not $g_bRunState Then Return
	SetLog("Search GreenZone for Placing new Building", $COLOR_INFO)
	If _Sleep(50) Then Return
	ZoomOut(True)

	Local $bSupportedScenery = False
	Local $sSceneryCode[5] = ["DS", "JS", "MS", "DM", "CS"]
	For $sCode In $sSceneryCode
		If $sCode = $g_sSceneryCode Then
			$bSupportedScenery = True
			ExitLoop
		EndIf
	Next

	If Not $bSupportedScenery Then
		SetLog("Detected Scenery : [" & $g_sSceneryCode & " : " & $g_sCurrentScenery & "]", $COLOR_ERROR)
		SetLog("Place New Building Only Supported for Classic/Jungle/Magic Scenery", $COLOR_ERROR)
		Return False
	EndIf
	
	Local $iTop = 0, $iRight = 0, $iBottom = 0, $iLeft = 0, $sArea
	Local $aFreeTile = QuickMIS("CNX", $g_sImgAUpgradeGreenZone, $g_InnerDiamondLeft, $g_InnerDiamondTop, $g_InnerDiamondRight, $g_InnerDiamondBottom)
	If IsArray($aFreeTile) And UBound($aFreeTile) > 0 Then
		SetDebugLog("count tile: " & UBound($aFreeTile))
		_ArraySort($aFreeTile, 0, 0, 0, 1) ;sort by x
		For $i = 0 To UBound($aFreeTile) - 1
			If IsInsideSmallDiamondXY($aFreeTile[$i][1], $aFreeTile[$i][2]) Then ContinueLoop ;too center on map
			If Not isInsideDiamondXY($aFreeTile[$i][1], $aFreeTile[$i][2]) Then ContinueLoop ;outside village diamond
			If $aFreeTile[$i][1] < $g_DiamondMiddleX - 60 And $aFreeTile[$i][2] > $g_DiamondMiddleY - 60 And $aFreeTile[$i][2] < $g_DiamondMiddleY + 60 Then $iLeft += 1
			If $aFreeTile[$i][1] > $g_DiamondMiddleX + 60 And $aFreeTile[$i][2] > $g_DiamondMiddleY - 60 And $aFreeTile[$i][2] < $g_DiamondMiddleY + 60 Then $iRight += 1
			If $aFreeTile[$i][2] < $g_DiamondMiddleY - 60 And $aFreeTile[$i][1] > $g_DiamondMiddleX - 60 And $aFreeTile[$i][1] < $g_DiamondMiddleX + 60 Then $iTop += 1
			If $aFreeTile[$i][2] > $g_DiamondMiddleY + 60 And $aFreeTile[$i][1] > $g_DiamondMiddleX - 60 And $aFreeTile[$i][1] < $g_DiamondMiddleX + 60 Then $iBottom += 1
		Next
		SetLog("Top=" & $iTop & ", Right=" & $iRight & ", Bottom=" & $iBottom & ", Left=" & $iLeft, $COLOR_DEBUG)
	EndIf
	Local $aiArea[4][2] = [["Top", $iTop], ["Right", $iRight], ["Bottom", $iBottom], ["Left", $iLeft]]
	_ArraySort($aiArea, 1, 0, 0, 1)
	SetLog("Most free area = " & $aiArea[0][0] & " with " & $aiArea[0][1] & " free tiles", $COLOR_INFO)
	$sArea = $aiArea[0][0]
	If Not $g_bRunState Then Return
	;Local $x, $y, $Offset = 300, $iCount = 0
	
	;Local $aArea = StringSplit($CocDiamondDCD, "|", $STR_NOCOUNT)
	;;426,53|779,318|426,585|73,318
	;If IsArray($aArea) And UBound($aArea) > 0 Then
	;	For $i = 0 TO UBound($aArea) - 1
	;		Local $aXY = StringSplit($aArea[$i], ",", $STR_NOCOUNT)
	;		If UBound($aXY) = 2 Then
	;			$x = $aXY[0]
	;			$y = $aXY[1]
	;			Switch $i
	;				Case 0
	;					$iTop = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x - ($Offset/2), $y, $x + ($Offset/2), $y + $Offset)
	;					SetLog("Count Green Top = " & $iTop, $COLOR_DEBUG1)
	;					$iCount = Number($iTop)
	;					$sArea = "Top"
	;				Case 1
	;					$iRight = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x - $Offset, $y - ($Offset/2), $x, $y + ($Offset/2))
	;					SetLog("Count Green Right = " & $iRight, $COLOR_DEBUG1)
	;					If $iCount < Number($iRight) Then
	;						$iCount = Number($iRight)
	;						$sArea = "Right"
	;					EndIf
	;				Case 2
	;					$iBottom = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x - ($Offset/2), $y - $Offset, $x + ($Offset/2), $y)
	;					SetLog("Count Green Bottom = " & $iBottom, $COLOR_DEBUG1)
	;					If $iCount < Number($iBottom) Then
	;						$iCount = Number($iBottom)
	;						$sArea = "Bottom"
	;					EndIf
	;				Case 3
	;					$iLeft = QuickMIS("Q1", $g_sImgAUpgradeGreenZone, $x, $y - ($Offset/2), $x + $Offset, $y + ($Offset/2))
	;					SetLog("Count Green Left = " & $iLeft, $COLOR_DEBUG1)
	;					If $iCount < Number($iLeft) Then
	;						$iCount = Number($iLeft)
	;						$sArea = "Left"
	;					EndIf
	;			EndSwitch
	;			;SetLog($i & ", Count = " & $iCount, $COLOR_DEBUG1)
	;		Else
	;			SetLog("UBound($aXY) != 2", $COLOR_DEBUG1)
	;		EndIf
	;	Next
	;	SetLog("Green Area = " & $sArea & ", count:" & $iCount, $COLOR_DEBUG1)
	;Else
	;	SetLog("aArea Not Array", $COLOR_DEBUG1)
	;EndIf

	If ZoomIn($sArea) Then
		SetLog("Succeed ZoomIn", $COLOR_DEBUG)
		Return True
	Else
		SetLog("Failed ZoomIn", $COLOR_ERROR)
	EndIf

	Return False
EndFunc

Func ClickDragAUpgrade()
	If Not $g_bRunState Then Return
	Local $x = 660, $yUp = 150, $yDown = 540, $Delay = 1500, $YY = 0
	
	BuildMenuScrollDown() ; slow drag of ~3 rows, a long fast drag can fling over rows
	
EndFunc ;==>ClickDragAUpgrade

Func OpenMainBuilder()
	If Not $g_bRunState Then Return
	Local $bRet = False
	
	; open the builders menu
	If _ColorCheck(_GetPixelColor(753, 594, True), Hex(0xFCC610, 6), 10, Default, "Orange Build Button") Then
		SetLog("Opening Builder Menu", $COLOR_ACTION)
		Click(800, 600, 1, 0, "Click Builder Button")
	EndIf
	
	WaitforPixel(835, 35, 836, 35, "D0151A", 20, 2) ;check red x upper right corner
	If QuickMIS("BC1", $g_sImgUpgradeMenu, 600, 15, 650, 30) Then $bRet = True
	
	Return $bRet
EndFunc ;==>OpenMainBuilder

Func GoGoblinMap()
	If Not $g_bRunState Then Return
	Local $GoblinFaceCoord, $CircleCoord
	Clickaway("Right")
	Click(60, 620) ;attack button
	SetLog("Going to Goblin Map to reset Field", $COLOR_INFO)
	If Not $g_bRunState Then Return
	If _Sleep(2000) Then Return
	Click(140, 360) ;Select Goblin Map
	If _Sleep(1000) Then Return
	$GoblinFaceCoord = decodeSingleCoord(findImage("GoblinFace", $g_sImgGoblin & "\GoblinFace*", "FV", 1, True))
	If IsArray($GoblinFaceCoord) And UBound($GoblinFaceCoord) = 2 Then
		Click($GoblinFaceCoord[0], $GoblinFaceCoord[1] + 50)
	Else ; we not find goblin face, try find circle map button
		$CircleCoord = decodeSingleCoord(findImage("GoblinFace", $g_sImgGoblin & "\OrangeCircle*", "FV", 1, True))
		If IsArray($CircleCoord) And UBound($CircleCoord) = 2 Then
			Click($CircleCoord[0], $CircleCoord[1])
			If _Sleep(500) Then Return
			Click($CircleCoord[0], $CircleCoord[1] + 50)
		Else
			Click(818, 55)
		EndIf
	EndIf
	Local $count = 0
	While Not IsAttackPage()
		If Not $g_bRunState Then Return
		$count += 1
		If _Sleep(250) Then Return
		If $count > 50 Then Return
	Wend

	If Not $g_bRunState Then Return

	If IsAttackPage() Then
		Click(66, 540)
	EndIf
	$count = 0
	While Not IsMainPage()
		If Not $g_bRunState Then Return
		$count += 1
		If _Sleep(250) Then Return
		If $count > 50 Then Return
	Wend
	SetLog("Field should be clear now", $COLOR_INFO)
EndFunc

; RushTH "Upgrade To Level" setting: True when selected building already has the wanted level
; (Town Hall: option + 9, Barracks / Dark Barracks / Spell Factory / Dark Spell Factory: option + 2)
Func RushTHLevelReached($sUpgradeName)
	Local $iOption = -1, $iAdd = 2
	Switch $sUpgradeName
		Case "Town Hall"
			$iOption = 0
			$iAdd = 9
		Case "Barracks"
			$iOption = 1
		Case "Dark Barracks"
			$iOption = 2
		Case "Spell Factory"
			$iOption = 3
		Case "Dark Spell Factory"
			$iOption = 4
	EndSwitch
	If $iOption < 0 Then Return False
	Local $iNext = UpgradeWindowTargetLevel() ; upgrade window is open after click in Build menu
	If $iNext <= 0 Then Return False
	Local $iWanted = Number($g_aiCmbRushTHOption[$iOption]) + $iAdd
	If $iNext > $iWanted Then
		SetLog("RushTH: " & $sUpgradeName & " upgrade to level " & $iNext & " > wanted " & $iWanted & ", skip", $COLOR_INFO)
		Return True
	EndIf
	Return False
EndFunc   ;==>RushTHLevelReached

; level in upgrade window title "Upgrade to level X?" (tested on screenshots: title y 58 / 101), 0 if not read
Func UpgradeWindowTargetLevel()
	Local $aTxt = OcrNamesInBand(150, 35, 720, 130), $sTxt = ""
	For $i = 0 To UBound($aTxt) - 1
		$sTxt &= $aTxt[$i][0] & " "
	Next
	Local $aLvl = StringRegExp($sTxt, "(?i)upgrade\D*?(\d{1,3})", 1) ; "level" word is often misread, take first number after "Upgrade"
	If Not IsArray($aLvl) Then
		SetDebugLog("UpgradeWindowTargetLevel: not read '" & $sTxt & "'")
		Return 0
	EndIf
	Local $iLvl = Number($aLvl[0])
	While $iLvl >= 40 ; "?" is read as 7 ("10?" = "107"), no building level is that high
		$iLvl = Int($iLvl / 10)
	WEnd
	Return $iLvl
EndFunc   ;==>UpgradeWindowTargetLevel

; Town Hall reached the Rush TH wanted level (option index + 9), False when TH level is unknown
; buildings the game asks before the next Town Hall upgrade (user, 31 Oct): TH16 -> 17 Eagle Artillery level 7,
; TH17 -> 18 Inferno Artillery 5 upgrades (stars), TH18 -> 19 (expected next month) the Guardians Longshot / Smasher / Logger.
; Their rows only show while they can be upgraded, so the Town Hall pass (Rush TH) takes them before the rest
Func RushTHGateRow($sName)
	Switch Number($g_iTownHallLevel)
		Case 16
			Return StringInStr($sName, "Eagle Art") > 0
		Case 17
			Return StringInStr($sName, "Inferno Art") > 0
		Case 18
			Return StringInStr($sName, "Longshot") > 0 Or StringInStr($sName, "Smasher") > 0 Or StringInStr($sName, "Logger") > 0
	EndSwitch
	Return False
EndFunc   ;==>RushTHGateRow

Func IsTHLevelAchieved()
	Return Number($g_iTownHallLevel) >= Number($g_aiCmbRushTHOption[0]) + 9
EndFunc

; Town Hall level of the current account, read every 6 h from the saved Town Hall position. FirstCheck reads it only for
; the account the bot starts on: a finished Town Hall upgrade on another account kept the old level (Rush TH target,
; wall costs, Auto Upgrade empty list are by TH level)
Func CheckTownHallLevel()
	If Number($g_aiTownHallPos[0]) < 1 Or Number($g_aiTownHallPos[1]) < 1 Then Return
	If Not RoutineIntervalDue(6, 360) Then Return
	ClickP($g_aiTownHallPos)
	If _Sleep(800) Then Return
	Local $aInfo = BuildingInfo()
	ClickAway()
	If $aInfo[1] <> "Town Hall" Or Number($aInfo[2]) < 1 Then
		SetLog("Town Hall level check: '" & $aInfo[1] & "' at the saved Town Hall position, next check in 6 h", $COLOR_DEBUG)
		Return
	EndIf
	If Number($aInfo[2]) <> Number($g_iTownHallLevel) Then
		SetLog("Town Hall level changed: " & $g_iTownHallLevel & " -> " & $aInfo[2], $COLOR_SUCCESS)
		$g_iTownHallLevel = Number($aInfo[2])
		saveConfig()
	EndIf
EndFunc   ;==>CheckTownHallLevel

Func getMostBottomCost()
	If Not $g_bRunState Then Return
	Local $TmpUpgradeCost, $ret
	Local $Icon = QuickMIS("CNX", $g_sImgResourceIcon, 830, 500, 850, 585)
	If IsArray($Icon) And UBound($Icon) > 0 Then
		_ArraySort($Icon, 1, 0, 0, 2) ;sort by y coord, descending
		$TmpUpgradeCost = getBuilderMenuCost($Icon[0][1] - 120, $Icon[0][2] - 2)
		$ret = $Icon[0][0] & "|" & $TmpUpgradeCost
	EndIf
	Return $ret
EndFunc


Func CheckPlaceBuilder($bTest = False)
	If Not $g_bRunState Then Return
	Local $bRet = False
	Local $iGem = Number($g_iGemAmount)
	Local $iBuilder = Number($g_iTotalBuilderCount)
	If $iBuilder < 5 Then
		If ($iBuilder = 2 And $iGem > 499) Or  ($iBuilder = 3 And $iGem > 999) Or ($iBuilder = 4 And $iGem > 1999 ) Then $bRet = True
	EndIf
	Return $bRet
EndFunc

Func AutoUpgradeLog($bNew = False, $aUpgradeName = "Traps", $iUpgradeLevel = 1, $iCost = 0 , $iDuration = 0)
	If Not $g_bRunState Then Return
	Local $txtAcc = $g_iCurAccount + 1
	Local $txtAccName = $g_sProfileCurrentName
	Local $sTxtUpgradeLog = "", $sTxtUpgradeLogToFile = "", $sUpgradeLogFile = $g_sProfileLogsPath & "\AutoUpgradeHistory.log"

	$sTxtUpgradeLog = @CRLF & _NowDate() & " " & _NowTime() & " [" & $txtAcc & "] " & $txtAccName & ($bNew ? " - Placing New Building: " : " - Upgrading ")
	$sTxtUpgradeLogToFile = "[" & $txtAcc & "] " & $txtAccName & ($bNew ? " - Placing New Building: " : " - Upgrading ")
	If $bNew Then
		$sTxtUpgradeLog &= $aUpgradeName
		$sTxtUpgradeLogToFile &= $aUpgradeName
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, $sTxtUpgradeLog)
		_FileWriteLog($sUpgradeLogFile, $sTxtUpgradeLogToFile)
	Else
		$sTxtUpgradeLog &= $aUpgradeName & " to level " & $iUpgradeLevel + 1 & " Cost = " & $iCost & " Duration = " & $iDuration
		$sTxtUpgradeLogToFile &= $aUpgradeName & " to level " & $iUpgradeLevel + 1 & " Cost = " & $iCost & " Duration = " & $iDuration
		_GUICtrlEdit_AppendText($g_hTxtAutoUpgradeLog, $sTxtUpgradeLog)
		_FileWriteLog($sUpgradeLogFile, $sTxtUpgradeLogToFile)
	EndIf
EndFunc

Func PlaceUnplacedBuilding($bTest = False)
	If Not $g_bRunState Then Return
	If SearchUnplacedBuilding() Then
		SetLog("Found Unplaced Building!", $COLOR_SUCCESS)
		If SearchGreenZone() Then
			SetLog("Trying to place Unplaced Bulding!", $COLOR_INFO)
			Click(431,571)
			If _Sleep(1500) Then Return
			If QuickMIS("BC1", $g_sImgGreenCheck) Then
				Click($g_iQuickMISX, $g_iQuickMISY)
				SetLog("Unplaced Bulding, Succeed", $COLOR_SUCCESS)
				ZoomOut(True)
			Else
				GoGoblinMap()
			EndIf
			If _Sleep(1000) Then Return
		Else
			SetLog("Trying to place Unplaced Bulding, Failed", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
EndFunc

Func IsUpgradeWindowOpen()
	Local $bRet = False
	
	If _ColorCheck(_GetPixelColor(810, 130, True), Hex(0x635550, 6), 10, Default, "IsUpgradeWindowOpen") _ ; Brown color under red x
		And _ColorCheck(_GetPixelColor(810, 120, True), Hex(0xDB2025, 6), 10, Default, "IsUpgradeWindowOpen") Then ; Red color under x 
		$bRet = True
	EndIf
	Return $bRet
EndFunc

Func IsBuilderMenuOpen()
	If Not $g_bRunState Then Return
	Local $bRet = False
	Local $aBorder0[4] = [370, 73, 0xFFFFFF, 20]
	Local $aBorder1[4] = [500, 73, 0xFFFFFF, 20]
	Local $sTriangle
	If _CheckPixel($aBorder0, True) And _CheckPixel($aBorder1, True) Then
		$bRet = True ;got correct color for border
	Else
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border0 Color Not Matched: " & _GetPixelColor($aBorder0[0], $aBorder0[1], True), $COLOR_DEBUG1)
		If $g_bDebugSetLog Then SetLog("IsBuilderMenuOpen Border1 Color Not Matched: " & _GetPixelColor($aBorder1[0], $aBorder1[1], True), $COLOR_DEBUG1)
	EndIf

	Return $bRet
EndFunc

Func DoGearUp($x, $y)
	If Not $g_bRunState Then Return
	SetLog("Do GearUp for OptimizeOTTO", $COLOR_INFO)
	Click($x, $y)
	If _Sleep(1000) Then Return
	Local $g_aUpgradeNameLevel = BuildingInfo()
	If $g_aUpgradeNameLevel[0] = "" Then
		SetLog("Error when trying to get upgrade name and level...", $COLOR_ERROR)
		Return False
	EndIf

	If ClickB("GearUp") Then
		If _Sleep(1000) Then Return
		If QuickMIS("BC1", $g_sImgAUpgradeRes, 350, 410, 560, 560) Then
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(1000) Then Return
			If IsGemOpen(True) Then
				ClickAway("Right")
				SetLog("Something is wrong, Gem Window Opened", $COLOR_ERROR)
				Return False
			Else
				SetLog(" - GearUp : " & $g_aUpgradeNameLevel[1], $COLOR_SUCCESS)
				Return True
			EndIf
		EndIf
	EndIf
EndFunc


;------------------------------------------
;old unused func below
;------------------------------------------







