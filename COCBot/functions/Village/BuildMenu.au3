; #FUNCTION# ====================================================================================================================
; Name ..........: BuildMenu
; Description ...: Build button menu (bottom right of main screen).
;                  Home village 4 tabs: 1 = Buildings & Heroes, 2 = Army Upgrades (Laboratory), 3 = Hero Equipment, 4 = Hero Pets
;                  Builder Base 2 tabs: 1 = Buildings & Heroes, 2 = Army Upgrades (Star Laboratory)
;                  Each tab shows a list (name, upgrade time, cost + resource icon) and builder/slot counters at the bottom.
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; ===============================================================================================================================
#include-once

Global Const $g_aiBuildMenuTabX[5] = [0, 545, 630, 720, 815] ; home village
Global Const $g_aiBuildMenuTabXBB[3] = [0, 590, 770] ; builder base
Global Const $g_iBuildMenuTabY = 630
Global Const $g_aiBuildMenuCounterX[5] = [0, 527, 618, 0, 799] ; "free/total" text below tab 1, 2 and 4
Global Const $g_aiBuildMenuCounterXBB[3] = [0, 572, 754]
Global $g_aiBuildMenuCounter[5][2] = [[-1, -1], [-1, -1], [-1, -1], [-1, -1], [-1, -1]] ; [tab][free, total], -1 = unknown
Global $g_iBuildMenuPage = 1 ; how many pages the list of current tab is scrolled down (1 = top)
Global $g_bBuildMenuBB = False ; menu opened on Builder Base

; Builder Base names as written in game (OCR)
Global Const $g_asBBBuildingNames[35] = ["Cannon", "Double Cannon", "Archer Tower", "Hidden Tesla", "Firecrackers", "Crusher", "Guard Post", _
		"Air Bombs", "Multi Mortar", "Roaster", "Giant Cannon", "Mega Tesla", "Lava Launcher", "X-Bow", "Zappy", "Wall", _
		"Push Trap", "Spring Trap", "Mine", "Mega Mine", "Builder Hall", "Gold Mine", "Elixir Collector", "Gold Storage", "Elixir Storage", _
		"Gem Mine", "B.O.B Control", "Builder Barracks", "Army Camp", "Star Laboratory", "Battle Machine", "Reinforcement Camp", _
		"Healing Hut", "Battle Copter", "O.T.T.O's Outpost"]
; same index as $g_avStarLabTroops
Global Const $g_asStarLabGameNames[13] = ["", "Raged Barbarian", "Sneaky Archer", "Boxer Giant", "Beta Minion", "Bomber", "Baby Dragon", _
		"Cannon Cart", "Night Witch", "Drop Ship", "Power P.E.K.K.A", "Hog Glider", "Electrofire Wizard"]

; Build menu list filter (button left of the tab title). One button per row can be on, a second click turns it off,
; the filter stays after the menu is closed. Home tab 1 types: Army, Defense, Hero, Resource, New, Permanent
; (Lab tab 2: Troops, Spells, Siege on the Army/Defense/Hero places). Sorting is not used: Cost Max moves red rows on top.
; Tested on emulator (Oct 2026): button on EDAB27 (yellow), off 8D6848, read at (x - 49, y - 10). A click during the window
; animation can be lost, so every button state is read again after the click.
Global Const $g_aBuildMenuFilterBtn[11][3] = [["Gold", 214, 136], ["Elixir", 350, 136], ["Dark", 487, 136], _
		["Army", 214, 220], ["Defense", 350, 220], ["Hero", 487, 220], ["Resource", 214, 272], ["New", 350, 272], ["Permanent", 487, 272], _
		["CostMax", 214, 355], ["CostMin", 350, 355]]

; filter button yellow = a filter is on (menu open, filter window closed): F3B52E on, 867B72 off
Func BuildMenuFilterActive()
	Return _ColorCheck(_GetPixelColor(515, 24, True), Hex(0xF3B52E, 6), 40)
EndFunc   ;==>BuildMenuFilterActive

; area of the first row of type buttons (brown off / yellow on, panel between them is brown too) instead of 3 pixels:
; the 3 pixels failed on tab 1 every time overnight (22 Oct 2026) while the popup was open (captured window a few px off)
Func BuildMenuFilterWindowOpen()
	_CaptureRegion()
	Local $iHits = 0, $iAll = 0, $sColor
	For $x = 160 To 540 Step 12
		For $y = 204 To 236 Step 8
			$iAll += 1
			$sColor = _GetPixelColor($x, $y, False)
			If _ColorCheck($sColor, Hex(0x8D6848, 6), 25) Or _ColorCheck($sColor, Hex(0xEDAB27, 6), 30) Then $iHits += 1
		Next
	Next
	Return $iHits >= $iAll * 0.3 ; screenshots: popup open 0.51 (white labels), closed 0.02..0.07
EndFunc   ;==>BuildMenuFilterWindowOpen

; popup opens / closes with an animation: wait for the state before a new click (a second click too early toggles it back)
Func BuildMenuFilterWaitWindow($bOpen, $iMs = 2000)
	Local $hTimer = __TimerInit()
	While __TimerDiff($hTimer) < $iMs
		If _Sleep(250) Then Return False
		If BuildMenuFilterWindowOpen() = $bOpen Then Return True
	WEnd
	Return False
EndFunc   ;==>BuildMenuFilterWaitWindow

Func BuildMenuFilterBtnOn($i)
	Return _ColorCheck(_GetPixelColor($g_aBuildMenuFilterBtn[$i][1] - 49, $g_aBuildMenuFilterBtn[$i][2] - 10, True), Hex(0xEDAB27, 6), 30)
EndFunc   ;==>BuildMenuFilterBtnOn

; set the list filter of the open tab $iTab: only type button $sType on ("" = no filter), resource off, sorting off unless
; $sType ends with "|CostMin" (e.g. "Army|CostMin", "|CostMin": cheapest first, used by the wall reserve builder low cost mode)
; or "|Elixir" / "|Dark" (resource button with the type, Lab tab: "Troops|Dark" = dark troops only).
; Lab tab names Troops / Spells / Siege are the Army / Defense / Hero buttons. Opens the menu (tab $iTab) when it is closed,
; the menu stays open. Return True when the wanted state is verified
Func BuildMenuSetFilter($sType = "", $iTab = 1)
	If Not IsBuildMenuOpen() Then Return OpenBuildMenu($iTab, False, $sType)
	Local $aPart = StringSplit($sType, "|", $STR_NOCOUNT)
	Local $sSort = UBound($aPart) > 1 ? $aPart[1] : "" ; sorting or resource button ("Troops|Elixir")
	Local $sBtn = $aPart[0]
	; Lab tab has 2 resource buttons only: Elixir and Dark on the Gold and Elixir places of tab 1 (emulator, Oct 2026)
	If $iTab = 2 Then
		Switch $sSort
			Case "Elixir"
				$sSort = "Gold"
			Case "Dark"
				$sSort = "Elixir"
		EndSwitch
	EndIf
	Switch $sBtn
		Case "Troops"
			$sBtn = "Army"
		Case "Spells"
			$sBtn = "Defense"
		Case "Siege"
			$sBtn = "Hero"
	EndSwitch
	If $sType = "" And Not BuildMenuFilterActive() Then
		$g_asBuildMenuFilter[$iTab] = ""
		Return True
	EndIf
	For $iTry = 1 To 2
		If BuildMenuFilterWindowOpen() Then ExitLoop
		Click(540, 24, 1, 0, "Build menu filter")
		If BuildMenuFilterWaitWindow(True) Then ExitLoop
		If Not $g_bRunState Then Return False
	Next
	If Not BuildMenuFilterWindowOpen() Then
		SetLog("Build menu filter window not opened", $COLOR_WARNING)
		SaveDebugImage("BuildMenuFilter")
		ClickAway("Left") ; do not leave a half open popup over the list
		Return False
	EndIf
	Local $bOk = True
	For $i = 0 To UBound($g_aBuildMenuFilterBtn) - 1
		Local $bWant = ($g_aBuildMenuFilterBtn[$i][0] = $sBtn Or ($sSort <> "" And $g_aBuildMenuFilterBtn[$i][0] = $sSort))
		For $iTry = 1 To 3
			If BuildMenuFilterBtnOn($i) = $bWant Then ExitLoop
			Click($g_aBuildMenuFilterBtn[$i][1], $g_aBuildMenuFilterBtn[$i][2], 1, 0, "Filter " & $g_aBuildMenuFilterBtn[$i][0])
			If _Sleep(700) Then Return False
		Next
		If BuildMenuFilterBtnOn($i) <> $bWant Then $bOk = False
	Next
	For $iTry = 1 To 2 ; close the filter window (same button)
		If Not BuildMenuFilterWindowOpen() Then ExitLoop
		Click(540, 24, 1, 0, "Close Build menu filter")
		If BuildMenuFilterWaitWindow(False) Then ExitLoop
	Next
	$g_iBuildMenuPage = 1
	BuildMenuWaitStill() ; list redrawn after the filter (quiver 27 Oct: read 40 ms later, Lab names '' and costs lost)
	If $bOk Then
		$g_asBuildMenuFilter[$iTab] = $sType
		SetDebugLog("Build menu filter tab " & $iTab & ": " & ($sType = "" ? "none" : $sType))
	Else
		SetLog("Build menu filter " & ($sType = "" ? "reset" : $sType) & " not verified", $COLOR_WARNING)
	EndIf
	Return $bOk
EndFunc   ;==>BuildMenuSetFilter

Func IsBuildMenuOpen()
	Return _ColorCheck(_GetPixelColor(835, 35, True), Hex(0xD0151A, 6), 20)
EndFunc   ;==>IsBuildMenuOpen

Func BuildMenuIsBBType($sType)
	Return $sType = "bb" Or $sType = "slab"
EndFunc   ;==>BuildMenuIsBBType

; selected tab of the open Build menu, 0 if unknown. Selected tab button is lighter (one capture, pixel checks only)
Func BuildMenuTab($bBB = $g_bBuildMenuBB)
	_CaptureRegion()
	Local $iLast = $bBB ? 2 : 4
	; a small area instead of one pixel: the captured window can be a few px off (read 3-4 px lower/right on 20 Oct 2026)
	; borders of not selected tabs also match a few pixels: the tab with clearly the most matches is the selected one
	Local $iBest = 0, $iBestHits = 0, $iSecondHits = 0
	For $iTab = 1 To $iLast
		Local $iX = $bBB ? $g_aiBuildMenuTabXBB[$iTab] : $g_aiBuildMenuTabX[$iTab], $iHits = 0
		For $x = $iX - 4 To $iX + 4 Step 4
			For $y = 658 To 668 Step 2
				If _ColorCheck(_GetPixelColor($x, $y, False), Hex(0x9E897C, 6), 20) Then $iHits += 1
			Next
		Next
		If $iHits > $iBestHits Then
			$iSecondHits = $iBestHits
			$iBestHits = $iHits
			$iBest = $iTab
		ElseIf $iHits > $iSecondHits Then
			$iSecondHits = $iHits
		EndIf
	Next
	If $iBestHits >= 5 And $iBestHits >= $iSecondHits + 3 Then Return $iBest
	Return 0
EndFunc   ;==>BuildMenuTab

; $sFilter = list filter wanted on a home tab ("" = none, see BuildMenuSetFilter). @error = 1: tab open but filter failed
Func OpenBuildMenu($iTab = 1, $bBB = False, $sFilter = "")
	If Not $g_bRunState Then Return False
	If IsBuildMenuOpen() And $g_bBuildMenuBB <> $bBB Then CloseBuildMenu() ; menu of the other village left open
	If Not IsBuildMenuOpen() Then
		If Not BuildMenuOnVillage($bBB) Then
			SetLog("Build menu: not on " & ($bBB ? "Builder Base" : "Home Village") & ", skip", $COLOR_WARNING)
			Return False
		EndIf
		Click(800, 600, 1, 0, "Build button")
		If Not WaitforPixel(835, 35, 836, 36, "D0151A", 20, 3, "OpenBuildMenu") Then
			SetLog("Build menu not opened", $COLOR_ERROR)
			Return False
		EndIf
		$g_iBuildMenuPage = 1
		If _Sleep(500) Then Return False
	EndIf
	$g_bBuildMenuBB = $bBB
	For $iTry = 1 To 3
		If BuildMenuTab($bBB) = $iTab Then
			If $iTry > 1 Or $g_iBuildMenuPage = 1 Then ReadBuildMenuCounters($bBB)
			; home tabs: the filter stays in game after the menu is closed. Set the wanted one, and reset a filter left on
			; (other routine, bot stopped while filtering, or set by hand) because it hides rows
			; (tabs 1 and 2 only: Hero Equipment / Pets have another filter window)
			If Not $bBB And $iTab <= 2 And ($sFilter <> $g_asBuildMenuFilter[$iTab] Or ($sFilter = "" And BuildMenuFilterActive())) Then
				If $sFilter = "" Then SetLog("Build menu filter is on, reset it", $COLOR_INFO)
				If Not BuildMenuSetFilter($sFilter, $iTab) And $sFilter <> "" Then Return SetError(1, 0, False)
			EndIf
			Return True
		EndIf
		Click($bBB ? $g_aiBuildMenuTabXBB[$iTab] : $g_aiBuildMenuTabX[$iTab], $g_iBuildMenuTabY, 1, 0, "Build menu tab " & $iTab)
		$g_iBuildMenuPage = 1
		If _Sleep(800) Then Return False
	Next
	SetLog("Cannot open Build menu tab " & $iTab, $COLOR_ERROR)
	; without Background Mode the bot reads the screen where the emulator window is: a window over it gives wrong pixels
	If Not $g_bChkBackgroundMode Then SetLog("Background Mode is disabled: keep the emulator window fully visible (not covered) or enable Background Mode", $COLOR_WARNING)
	SaveDebugImage("BuildMenuTab")
	CloseBuildMenu() ; do not leave the menu open for the next routine
	Return False
EndFunc   ;==>OpenBuildMenu

; make sure we are on the wanted village before clicking Build (Home and BB menus have other tabs)
Func BuildMenuOnVillage($bBB)
	If ($bBB ? isOnBuilderBase() : isOnMainVillage()) Then Return True
	checkMainScreen(False, $bBB, "OpenBuildMenu")
	If ($bBB ? isOnBuilderBase() : isOnMainVillage()) Then Return True
	; switch only when the other village is really seen (a main screen not recognized is not builder base)
	If Not ($bBB ? isOnMainVillage() : isOnBuilderBase()) Then
		SetLog("Build menu: " & ($bBB ? "Builder Base" : "Home Village") & " not recognized, skip", $COLOR_WARNING)
		Return False
	EndIf
	SetLog("Build menu: on " & ($bBB ? "Home Village" : "Builder Base") & ", switching", $COLOR_INFO)
	SwitchBetweenBases($bBB ? "BB" : "Main")
	If _Sleep(500) Then Return False
	Return ($bBB ? isOnBuilderBase() : isOnMainVillage())
EndFunc   ;==>BuildMenuOnVillage

; Builder's Apprentice (tab 1) / Lab Assistant (tab 2): face icon left of the open Build menu, "Available" text when idle
; (same images and steps as dev, checked on qruel 23 Oct 2026). Idle: open it, Assign the first ongoing upgrade (longest),
; "Keep assigned until upgrade is complete", Confirm. The menu is opened again on $iTab after it.
; Checked again after 60 min per account ($iHelper 0 = builder, 1 = lab). Return True = assigned
Func BuildMenuAssignHelper($iHelper, $iTab)
	Local $sName = $iHelper = 0 ? "Builder's Apprentice" : "Lab Assistant"
	If Not BuildMenuHelperDue($iHelper) Or Not IsBuildMenuOpen() Then Return False
	$g_ahHelperCheckTimer[CurAccountIndex()][$iHelper] = __TimerInit()
	If Not QuickMIS("BC1", $iHelper = 0 ? $g_sImgBuilderMenu : $g_sImgLabAssistant, 450, 200, 495, 245) Then
		SetDebugLog($sName & ": no icon left of Build menu")
		Return False
	EndIf
	If Not QuickMIS("BC1", $g_sImgBuilderMenu, 425, 220, 450, 230) Then ; "Available" text
		SetLog($sName & " is working", $COLOR_DEBUG1)
		Return False
	EndIf
	SetLog($sName & " available, assign it", $COLOR_INFO)
	Click($g_iQuickMISX, $g_iQuickMISY)
	Local $bRet = False
	If WaitForPixel(830, 130, 831, 131, Hex(0x635550, 6), 10, 2, $sName & " window") Then
		If QuickMIS("BC1", $g_sImgLabAssistant, 720, 270, 810, 310) Then ; first Assign button = longest ongoing upgrade
			Click($g_iQuickMISX, $g_iQuickMISY)
			If _Sleep(500) Then Return False
			If WaitForPixel(430, 525, 431, 526, Hex(0x8BD43A, 6), 10, 2, $sName & " confirm") Then
				Click(250, 421, 1, 0, "Keep assigned until upgrade is complete")
				If _Sleep(500) Then Return False
				Click(430, 520, 1, 0, "Confirm " & $sName)
				If _Sleep(1000) Then Return False
				SetLog($sName & " assigned", $COLOR_SUCCESS)
				$bRet = True
			EndIf
		Else
			SetLog($sName & ": Assign button not found", $COLOR_WARNING)
		EndIf
	EndIf
	ClickAway("Left")
	If _Sleep(800) Then Return $bRet
	If Not IsBuildMenuOpen() Then OpenBuildMenu($iTab)
	Return $bRet
EndFunc   ;==>BuildMenuAssignHelper

; True when the helper check is due (TH 9+, not checked in the last 60 min on this account): callers open the menu only then
Func BuildMenuHelperDue($iHelper)
	If $g_iTownHallLevel < 9 Then Return False
	Local $h = $g_ahHelperCheckTimer[CurAccountIndex()][$iHelper]
	Return $h = 0 Or __TimerDiff($h) >= 3600000
EndFunc   ;==>BuildMenuHelperDue

; Research / Builder Potion from the Magic Item button of the open Build menu (tab 2 lab / tab 1 builders) when the first
; running upgrade has 1 day or more left ("d" in its time, row 1). $iKind: 0 research, 1 builder. One try per hour per
; account (a potion lasts 1 hour). Returns True when used.
Func BuildMenuUsePotion($iKind)
	Local $sDir = $iKind = 0 ? $g_sImgResearchPotion : $g_sImgBuilderPotion
	Local $sName = $iKind = 0 ? "Research" : "Builder"
	Local $iAcc = CurAccountIndex(), $h = $g_ahPotionTimer[$iAcc][$iKind]
	If $h <> 0 And __TimerDiff($h) < 3600000 Then Return False
	If Not IsBuildMenuOpen() Then Return False
	$g_ahPotionTimer[$iAcc][$iKind] = __TimerInit()
	If Not QuickMIS("BFI", $g_sImgAUpgradeHour & "Day*", 776, 65, 830, 80) Then
		SetLog($sName & " Potion: running upgrade ends in less than 1 day, not used", $COLOR_DEBUG2)
		Return False
	EndIf
	If Not QuickMIS("BC1", $sDir, 440, 620, 460, 640) Then
		SetLog($sName & " Potion: Magic Item button not found", $COLOR_DEBUG2)
		Return False
	EndIf
	Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, "Magic Item")
	If _Sleep(1000) Then Return False
	Local $bRet = False
	If IsMagicItemWindowOpen() Then
		If QuickMIS("BC1", $sDir, 180, 225, 670, 380) Then
			Click($g_iQuickMISX, $g_iQuickMISY, 1, 0, $sName & " Potion")
			If WaitforPixel(650, 510, 651, 510, "8BD43B", 20, 2) Then
				Click(650, 510, 1, 0, "Use " & $sName & " Potion")
				If WaitforPixel(430, 430, 431, 430, "2E93D0", 20, 2) Then
					Click(430, 430, 1, 0, "Confirm " & $sName & " Potion")
					SetLog($sName & " Potion used (1 day or more left)", $COLOR_SUCCESS)
					$bRet = True
				Else
					SetLog($sName & " Potion: confirm button not found", $COLOR_DEBUG2)
				EndIf
			Else
				SetLog($sName & " Potion: Use button not found", $COLOR_DEBUG2)
			EndIf
		Else
			SetLog("No " & $sName & " Potion in Magic Items", $COLOR_INFO)
		EndIf
		If _Sleep(500) Then Return $bRet
		ClickAway("Left") ; close the Magic Items window
		If _Sleep(500) Then Return $bRet
	Else
		SetLog($sName & " Potion: Magic Items window not opened", $COLOR_DEBUG2)
	EndIf
	Return $bRet
EndFunc   ;==>BuildMenuUsePotion

Func CloseBuildMenu()
	If IsBuildMenuOpen() Then
		Click(836, 24, 1, 0, "Close Build menu")
		If _Sleep(500) Then Return
	EndIf
EndFunc   ;==>CloseBuildMenu

; read "free/total" counters below the tabs (visible on every tab)
; home: builders (tab 1), laboratory (tab 2), pet house (tab 4). BB: builders (tab 1), star laboratory (tab 2)
Func ReadBuildMenuCounters($bBB = $g_bBuildMenuBB)
	Local $aTabs = $bBB ? StringSplit("1|2", "|", $STR_NOCOUNT) : StringSplit("1|2|4", "|", $STR_NOCOUNT)
	Local $sRead, $aSplit, $iTab
	For $sTab In $aTabs
		$iTab = Number($sTab)
		; template font reads these small digits best: totalreq on home village, armycap on builder base (tested on screenshots).
		; The text is at the edge of the box: 2 px off reads nothing (BB counters were -1/-1 most of the night, 22 Oct 2026),
		; so other y are tried when the read is not "n#n" (same font: totalreq reads BB "0/3" as "0#4")
		Local $aY[4] = [636, 638, 634, 640], $sFont = $bBB ? "coc-armycap" : "coc-totalreq", $iX = $bBB ? $g_aiBuildMenuCounterXBB[$iTab] - 2 : $g_aiBuildMenuCounterX[$iTab]
		For $iTry = 0 To 3
			$sRead = getOcrAndCapture($sFont, $iX, $aY[$iTry], $bBB ? 40 : 36, 16, True)
			If StringRegExp($sRead, "^\d+#\d+$") Then ExitLoop
		Next
		If StringRegExp($sRead, "^\d+#\d+$") Then
			$aSplit = StringSplit($sRead, "#", $STR_NOCOUNT)
			$g_aiBuildMenuCounter[$iTab][0] = Number($aSplit[0])
			$g_aiBuildMenuCounter[$iTab][1] = Number($aSplit[1])
		Else
			$g_aiBuildMenuCounter[$iTab][0] = -1
			$g_aiBuildMenuCounter[$iTab][1] = -1
		EndIf
	Next
	$g_hBuildMenuCounterTime = __TimerInit()
	$g_bBuildMenuCounterBB = $bBB
	$g_iBuildMenuCounterAcc = CurAccountIndex()
	If $bBB Then
		If $g_aiBuildMenuCounter[1][1] > 0 Then
			$g_iFreeBuilderCountBB = $g_aiBuildMenuCounter[1][0]
			$g_iTotalBuilderCountBB = $g_aiBuildMenuCounter[1][1]
		EndIf
		SetDebugLog("BB Build menu counters, Builder:" & $g_aiBuildMenuCounter[1][0] & "/" & $g_aiBuildMenuCounter[1][1] & ", Star Lab:" & $g_aiBuildMenuCounter[2][0] & "/" & $g_aiBuildMenuCounter[2][1])
		Return
	EndIf
	; event Goblin Builder / Goblin Researcher (gems): not counted
	If $g_aiBuildMenuCounter[1][1] > 0 Then GoblinBuilderAdjust($g_aiBuildMenuCounter[1][0], $g_aiBuildMenuCounter[1][1], "MenuBuilder")
	; lab: goblin icon = only the goblin is free (lab icon with 1/2: the lab is free, goblin busy)
	If $g_aiBuildMenuCounter[2][1] > 1 And IsGoblinCounter("MenuLab") Then
		$g_aiBuildMenuCounter[2][0] = _Max(0, $g_aiBuildMenuCounter[2][0] - 1)
		$g_aiBuildMenuCounter[2][1] -= 1
		SetDebugLog("Build menu: Goblin Researcher not counted")
	EndIf
	If $g_aiBuildMenuCounter[1][1] > 0 Then
		$g_iFreeBuilderCount = $g_aiBuildMenuCounter[1][0]
		$g_iTotalBuilderCount = $g_aiBuildMenuCounter[1][1]
	EndIf
	SetDebugLog("Build menu counters, Builder:" & $g_aiBuildMenuCounter[1][0] & "/" & $g_aiBuildMenuCounter[1][1] & _
			", Lab:" & $g_aiBuildMenuCounter[2][0] & "/" & $g_aiBuildMenuCounter[2][1] & ", Pet:" & $g_aiBuildMenuCounter[4][0] & "/" & $g_aiBuildMenuCounter[4][1])
EndFunc   ;==>ReadBuildMenuCounters

; log the rows read from the Build menu (name, cost, resource) so every choice can be traced; "?" = name not recognized
Func BuildMenuLogList($sTitle, ByRef $aList)
	SetLog($sTitle & ":", $COLOR_INFO)
	If UBound($aList) = 0 Then SetLog(" - (no affordable row)", $COLOR_DEBUG)
	For $i = 0 To UBound($aList) - 1
		BuildMenuLogRow($aList, $i)
	Next
EndFunc   ;==>BuildMenuLogList

Func BuildMenuLogRow(ByRef $aList, $i)
	If $aList[$i][3] = "(not wall)" Then Return
	SetLog(" - " & ($aList[$i][7] ? $aList[$i][3] : "? '" & $aList[$i][3] & "'") & " : " & ($aList[$i][5] = -1 ? "(not enough) " : _NumberFormat($aList[$i][5]) & " ") & $aList[$i][0], $COLOR_DEBUG)
EndFunc   ;==>BuildMenuLogRow

; True when the counters ($g_aiBuildMenuCounter) were read less than $iSec ago on this village and account
; (counters are shown on every tab: a routine can use them without opening the menu again)
Func BuildMenuCountersFresh($bBB, $iSec = 120)
	If $g_hBuildMenuCounterTime = 0 Or $g_bBuildMenuCounterBB <> $bBB Or $g_iBuildMenuCounterAcc <> CurAccountIndex() Then Return False
	Return __TimerDiff($g_hBuildMenuCounterTime) < $iSec * 1000
EndFunc   ;==>BuildMenuCountersFresh

; resources while Build menu is open (shown top center), no need to close the menu (same as dev AutoUpgradeCheckResource)
Func BuildMenuReadLoot($bSetLog = True, $bBB = $g_bBuildMenuBB)
	If $bBB Then
		$g_aiCurrentLootBB[$eLootGoldBB] = getResourcesMainScreen(350, 22)
		$g_aiCurrentLootBB[$eLootElixirBB] = getResourcesMainScreen(350, 59)
		If $bSetLog Then SetLog("[BB Builder]:" & $g_iFreeBuilderCountBB & "/" & $g_iTotalBuilderCountBB & " [G]:" & _NumberFormat($g_aiCurrentLootBB[$eLootGoldBB]) & _
				" [E]:" & _NumberFormat($g_aiCurrentLootBB[$eLootElixirBB]), $COLOR_SUCCESS)
		Return
	EndIf
	$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(350, 22)
	$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(350, 59)
	$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(350, 96)
	If $bSetLog Then SetLog("[Builder]:" & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount & " [G]:" & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & _
			" [E]:" & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [D]:" & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]), $COLOR_SUCCESS)
EndFunc   ;==>BuildMenuReadLoot

; upgrade time text read by OCR ("2d 3h", often only partly readable) -> minutes, as LOWER bound (never later than real finish)
Func BuildMenuTimeToMin($sTime)
	; Tesseract reads the CoC "1" as l / I and "5" as S ("SHSm" = 5H 54M, "IH" = 1H, adb test 27 Oct)
	$sTime = StringRegExpReplace($sTime, "[lI](?=[\dlIdhmDHM])", "1")
	$sTime = StringRegExpReplace($sTime, "S(?=[\ddhmDHM])", "5")
	$sTime = StringLower($sTime)
	Local $iMin = 0, $a
	$a = StringRegExp($sTime, "(\d+)\s*d", $STR_REGEXPARRAYMATCH)
	If IsArray($a) Then $iMin += Number($a[0]) * 1440
	$a = StringRegExp($sTime, "(\d+)\s*h", $STR_REGEXPARRAYMATCH)
	If IsArray($a) And Number($a[0]) < 24 Then $iMin += Number($a[0]) * 60
	$a = StringRegExp($sTime, "(\d+)\s*m", $STR_REGEXPARRAYMATCH)
	If IsArray($a) And Number($a[0]) < 60 And $iMin < 1440 Then $iMin += Number($a[0])
	Return $iMin
EndFunc   ;==>BuildMenuTimeToMin

; time of the upgrade in progress (first row, green bar) of current tab, in minutes (lower bound), 0 if unknown
Func BuildMenuBusyTime()
	Return BuildMenuTimeToMin(getOcrAndCapture("coc-buildtime", 755, 66, 76, 14, False))
EndFunc   ;==>BuildMenuBusyTime

Func BuildMenuMatchName($sOcr, $sType)
	Switch $sType
		Case "lab"
			Local $sMatch = OcrMatchTroopName($sOcr)
			Return SetExtended(@extended, $sMatch)
		Case "pet"
			Local $sMatch = OcrMatchName($sOcr, $g_asPetGameNames)
			Return SetExtended(@extended, $sMatch)
		Case "hero"
			Local $sMatch = OcrMatchName($sOcr, $g_asHeroHallNames)
			Return SetExtended(@extended, $sMatch)
		Case "bb"
			Local $sMatch = OcrMatchName($sOcr, $g_asBBBuildingNames)
			Return SetExtended(@extended, $sMatch)
		Case "slab"
			Local $sMatch = OcrMatchName($sOcr, $g_asStarLabGameNames)
			Return SetExtended(@extended, $sMatch)
		Case Else
			Local $sMatch = OcrMatchBuildingName($sOcr)
			Return SetExtended(@extended, $sMatch)
	EndSwitch
EndFunc   ;==>BuildMenuMatchName

; cost of a row: $iX, $iY = resource icon point (like QuickMIS, ~7 px above icon center)
; Return cost, 0 = unreadable, -1 = red cost (not enough resource)
; red cost text = not enough resource (row is skipped, see BuildMenuStopScroll for the list order)
; uses the last full screen frame (_CaptureRegion), absolute coordinates, $iX/$iY = resource icon point
Func BuildMenuIsRedCost($iX, $iY)
	Local $iRed = 0, $iPix
	For $x = $iX - 105 To $iX - 13 Step 3
		For $y = $iY - 1 To $iY + 15 Step 2
			$iPix = Dec(_GetPixelColor($x, $y, False))
			If BitAND(BitShift($iPix, 16), 0xFF) > 200 And BitAND(BitShift($iPix, 8), 0xFF) < 130 And BitAND($iPix, 0xFF) < 130 Then $iRed += 1
		Next
	Next
	Return $iRed > 20
EndFunc   ;==>BuildMenuIsRedCost

Func BuildMenuReadCost($iX, $iY)
	If BuildMenuIsRedCost($iX, $iY) Then Return -1 ; red digits are also often misread: skip the row
	Local $iMinDigits = BuildMenuCostMinDigits($iX, $iY)
	; template font, keep spaces to check the digit groups ("5 400 000"); a lost digit gives "00 000" or "5 00 000"
	Local $sCost = getOcrAndCapture("coc-buildermenu-cost", $iX - 120, $iY - 2, 120, 18, False)
	Local $sDigits = StringReplace($sCost, " ", "")
	; wide first group split by a space: "10 000 000" read as "1 0 000 000"
	If (StringRegExp($sCost, "^[1-9]\d{0,2}( \d{3})*$") Or StringRegExp($sCost, "^[1-9] \d( \d{3})+$")) And StringLen($sDigits) >= $iMinDigits Then Return Number($sDigits)
	; fallback: Tesseract digits (also when the template read lost a digit: "175 000" read as "15 000").
	; Template drops digits that touch ("60 000" -> "0 000", "1 500 000" -> "1 00 000") and reads 4 as 1. Tesseract area
	; from x-128: from x-105 the first digit of 8 digit costs was cut ("26 500 000" -> "6500000"). Tesseract can add or
	; change a digit, so its length must be the pixel digit count; when that count is unknown, the template digits must
	; all be in the Tesseract read, in the same order (adb test 27 Oct, 2 accounts tab 1: 93 of 97 rows read)
	Local $sTess = StringStripWS(getOcrAndCapture("coc-buildcost", $iX - 128, $iY - 2, 115, 18, False), $STR_STRIPALL)
	If StringRegExp($sTess, "^[1-9]\d{2,8}$") Then
		If $iMinDigits > 1 And StringLen($sTess) = $iMinDigits Then Return Number($sTess)
		If $iMinDigits = 1 And ($sDigits = "" Or (StringLen($sTess) > StringLen($sDigits) And BuildMenuIsSubsequence($sDigits, $sTess))) Then Return Number($sTess)
	EndIf
	SetDebugLog("BuildMenu cost not readable: '" & $sCost & "' / '" & $sTess & "' (text needs " & $iMinDigits & "+ digits)")
	Return 0
EndFunc   ;==>BuildMenuReadCost

; True when all chars of $sPart are in $sAll in the same order ("0000" in "60000", "15000" in "175000")
Func BuildMenuIsSubsequence($sPart, $sAll)
	Local $iPos = 1
	For $i = 1 To StringLen($sPart)
		$iPos = StringInStr($sAll, StringMid($sPart, $i, 1), 1, 1, $iPos)
		If $iPos = 0 Then Return False
		$iPos += 1
	Next
	Return True
EndFunc   ;==>BuildMenuIsSubsequence

; digit count of the white cost text (last _CaptureRegion frame), to catch a lost digit ("12 600 000" read as "2 600 000").
; Pixel width can not tell 7 from 8 digits ("1" is narrow), so digits are counted: white column runs are digits,
; gaps of 1..3 px are inside a digit group, 5+ px between groups (Build menu screenshots, Oct 2026).
; Return 1 (no check) when the text does not look like "d dd ddd" groups
Func BuildMenuCostMinDigits($iX, $iY)
	Local $iRight = 0
	For $x = $iX - 5 To $iX - 30 Step -1 ; right end of the text, left of the icon
		If BuildMenuCostWhiteColumn($x, $iY) Then
			$iRight = $x
			ExitLoop
		EndIf
	Next
	If $iRight = 0 Then Return 1
	Local $iGroupDigits = 0, $iDigits = 0, $iRun = 0, $iGap = 0
	For $x = $iRight To $iX - 125 Step -1
		If BuildMenuCostWhiteColumn($x, $iY) Then
			If $iRun = 0 And $iGap >= 5 Then ; new digit group: the one on the right must have 3 digits
				If $iGroupDigits <> 3 Then Return 1
				$iGroupDigits = 0
			EndIf
			$iRun += 1
			$iGap = 0
		Else
			If $iRun > 0 Then
				Local $iCount = ($iRun >= 15) ? 2 : 1 ; two digits touching
				$iGroupDigits += $iCount
				$iDigits += $iCount
			EndIf
			$iRun = 0
			$iGap += 1
			If $iGap >= 12 Then ExitLoop ; end of the text
		EndIf
	Next
	If $iGroupDigits < 1 Or $iGroupDigits > 3 Then Return 1
	Return $iDigits
EndFunc   ;==>BuildMenuCostMinDigits

Func BuildMenuCostWhiteColumn($x, $iY)
	Local $iPix
	For $y = $iY + 2 To $iY + 10 Step 2
		$iPix = Dec(_GetPixelColor($x, $y, False))
		If BitAND(BitShift($iPix, 16), 0xFF) > 225 And BitAND(BitShift($iPix, 8), 0xFF) > 225 And BitAND($iPix, 0xFF) > 225 Then Return True
	Next
	Return False
EndFunc   ;==>BuildMenuCostWhiteColumn

; Builder Base rows: resource icons found by color in icon column (x 838..852), gold = yellow, elixir = purple
; (tested on BB screenshots; clock icons are only 1-2 rows of yellow and are ignored)
; Return [n][3] = ["Gold"/"Elix", x, y] with y like QuickMIS point (icon center - 7)
Func BuildMenuRowsByColor($iTop = 50, $iBottom = 600)
	Local $aRet[0][3]
	_CaptureRegion2(838, $iTop, 853, $iBottom)
	Local $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	If @error Or $hBmp = 0 Then Return $aRet
	Local $iW = 15, $iH = $iBottom - $iTop
	Local $tData = _GDIPlus_BitmapLockBits($hBmp, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iStridePx = DllStructGetData($tData, "Stride") / 4
	Local $tPix = DllStructCreate("uint[" & $iStridePx * $iH & "]", DllStructGetData($tData, "Scan0"))
	Local $sCur = "", $iStart = 0, $iPix, $r, $g, $b, $iGold, $iElix, $sRow
	For $y = 0 To $iH
		$sRow = ""
		If $y < $iH Then
			$iGold = 0
			$iElix = 0
			For $x = 0 To $iW - 1
				$iPix = DllStructGetData($tPix, 1, $y * $iStridePx + $x + 1)
				$r = BitAND(BitShift($iPix, 16), 0xFF)
				$g = BitAND(BitShift($iPix, 8), 0xFF)
				$b = BitAND($iPix, 0xFF)
				If $r > 200 And $g > 150 And $b < 90 Then $iGold += 1
				If $r > 130 And $b > 170 And $g < 120 Then $iElix += 1
			Next
			If $iGold >= 4 Then $sRow = "Gold"
			If $iElix >= 4 Then $sRow = "Elix"
		EndIf
		If $sRow <> $sCur Then
			If $sCur <> "" And $y - $iStart >= 6 Then
				Local $aAdd[1][3] = [[$sCur, 845, $iTop + Int(($iStart + $y - 1) / 2) - 7]]
				_ArrayAdd($aRet, $aAdd)
			EndIf
			$sCur = $sRow
			$iStart = $y
		EndIf
	Next
	_GDIPlus_BitmapUnlockBits($hBmp, $tData)
	_GDIPlus_BitmapDispose($hBmp)
	Return $aRet
EndFunc   ;==>BuildMenuRowsByColor

; read the visible rows of current tab. A row is found by its resource icon at the right side.
; Return [n][8] = [resource ("Gold"/"Elix"/"DE"), icon x, icon y, name, count, cost, 0 (time, see BuildMenuRowTime), matched (True/False)]
; $bRedNames: red rows (not enough resource) are returned too, with cost -1 and their name
Func BuildMenuReadPage($sIconDir, $iNameX, $iNameDy, $sType, $bRedNames = False)
	Local $aRet[0][8], $aIcon
	If BuildMenuIsBBType($sType) Then
		$aIcon = BuildMenuRowsByColor()
	Else
		$aIcon = QuickMIS("CNX", $sIconDir, 828, 60, 852, 595)
		If Not IsArray($aIcon) Then
			Local $aNoIcon[0][4]
			$aIcon = $aNoIcon
		EndIf
		; Gold / Elixir icons found by color too: QuickMIS missed the last rows of the list (qath, Oct 2026: Wall and Bomb
		; at the bottom of the last page were never read, the wall was not upgraded)
		Local $aColor = BuildMenuRowsByColor(60, 595)
		For $j = 0 To UBound($aColor) - 1
			Local $bNear = False
			For $k = 0 To UBound($aIcon) - 1
				If Abs(Number($aIcon[$k][2]) - $aColor[$j][2]) < 15 Then $bNear = True
			Next
			If $bNear Then ContinueLoop
			SetDebugLog("BuildMenu row found by color only: " & $aColor[$j][0] & " at y " & $aColor[$j][2])
			Local $aAddIcon[1][4] = [[$aColor[$j][0], 840, $aColor[$j][2], ""]]
			_ArrayAdd($aIcon, $aAddIcon)
		Next
		If UBound($aIcon) = 0 Then Return $aRet
		RemoveDupCNX($aIcon, 2, 5)
	EndIf
	If UBound($aIcon) = 0 Then Return $aRet
	_ArraySort($aIcon, 0, 0, 0, 2)
	_CaptureRegion() ; one frame for the red cost checks of all rows
	Local $iFlags = 0
	For $i = 0 To UBound($aIcon) - 1
		If Not $g_bRunState Then Return SetExtended($iFlags, $aRet)
		Local $iX = Number($aIcon[$i][1]), $iY = Number($aIcon[$i][2])
		Local $iCost = BuildMenuReadCost($iX, $iY) ; fast template OCR first
		If $iCost = -1 Then ; red row (not enough resource): skip it, no name OCR
			$iFlags = BitOR($iFlags, BitAND($iFlags, 2) ? 5 : 4)
			If Not $bRedNames Then ContinueLoop
		EndIf
		; in progress / max level / unreadable: skip name OCR. BB rows are found by their resource icon (no row without
		; cost): white cost not read ("500 000" read as "00 000") is kept with cost 0, the upgrade window checks the cost.
		; Wall search ("building") keeps them too: "10 000 000" was not read and the wall was not found (zone, Oct 2026)
		If $iCost <= 0 And Not (($sType = "bb" Or $sType = "building") And $iCost = 0) And Not ($bRedNames And $iCost = -1) Then ContinueLoop
		If $iCost <> -1 Then $iFlags = BitOR($iFlags, 2)
		; wall search: a read cost that is no wall cost can not be the wall row (UpgradeWallBuildMenu drops it), no name OCR
		; (~0.3-1 s per row, 10-28 s per wall search 28 Oct). Kept as "(not wall)" so the page signature still sees the row
		If $g_bBuildMenuWallOnly And $iCost > 0 And _ArraySearch($g_aiWallCost, $iCost, 1) < 1 Then
			Local $aSkipRow[1][8] = [[$aIcon[$i][0], $iX, $iY, "(not wall)", 1, $iCost, 0, False]]
			_ArrayAdd($aRet, $aSkipRow)
			ContinueLoop
		EndIf
		; new building to place (green name, the white text OCR reads it as ''): not an upgrade, no name OCR
		If ($sType = "building" Or $sType = "hero") And AutoUpgradeIsNewRow($iY) Then ContinueLoop
		Local $iW = $iX - 80 - $iNameX ; like dev: keep upgrade time text out of the name
		If $iW > 210 Then $iW = 210
		; name text is a little lower in tab 1 than in tab 2/4 (dev uses y-20 tab 1, y-18 lab), area covers both
		Local $iNameH = ($sType = "hero" Or $sType = "building") ? 22 : 20
		Local $aName = getBuildingName($iNameX, $iY + $iNameDy, $iW, $iNameH)
		Local $sName = BuildMenuMatchName($aName[0], $sType)
		Local $bMatched = (@extended = 1)
		; list can still move a little after a scroll (empty / garbled names on page 2): read again a few px up and down
		If Not $bMatched Then
			Local $aRetryDy[2] = [-3, 3]
			For $iDy In $aRetryDy
				Local $aName2 = getBuildingName($iNameX, $iY + $iNameDy + $iDy, $iW, $iNameH)
				Local $sName2 = BuildMenuMatchName($aName2[0], $sType)
				If @extended = 1 Then
					SetDebugLog("BuildMenu name '" & $aName[0] & "' read again (" & $iDy & " px): " & $sName2)
					$aName = $aName2
					$sName = $sName2
					$bMatched = True
					ExitLoop
				EndIf
			Next
		EndIf
		Local $aAdd[1][8] = [[$aIcon[$i][0], $iX, $iY, $sName, $aName[1], $iCost, 0, $bMatched]]
		_ArrayAdd($aRet, $aAdd)
	Next
	Return SetExtended($iFlags, $aRet) ; @extended = page flags, see BuildMenuStopScroll
EndFunc   ;==>BuildMenuReadPage

; scroll rule for Build menu lists. Affordable rows come first (most expensive first), red rows (not enough
; resource) below them; a few red rows can be above them too (Suggested upgrades, top of Other upgrades).
; $iFlags = page flags: 1 = red row below an affordable row, 2 = affordable row, 4 = red row
; red rows after affordable rows (or a page with only red rows): check one more page, stop if it has no affordable row
; Return True = stop scrolling
Func BuildMenuStopScroll($iFlags, ByRef $bAffordSeen, ByRef $bCheckNext)
	Local $bAfford = (BitAND($iFlags, 2) = 2)
	If $bCheckNext And Not $bAfford Then Return True
	$bCheckNext = (BitAND($iFlags, 4) = 4) And ($bAffordSeen Or BitAND($iFlags, 1) = 1 Or Not $bAfford)
	If $bAfford Then $bAffordSeen = True
	Return False
EndFunc   ;==>BuildMenuStopScroll

; upgrade time of the row with resource icon at $iY, in minutes (lower bound, 0 = unknown). Only read for the chosen row.
Func BuildMenuRowTime($iY)
	; text at y-18..y-8: y-26 h14 read only its top half ("15d 12H" -> "s", adb test 27 Oct)
	Return BuildMenuTimeToMin(getOcrAndCapture("coc-buildtime", 755, $iY - 21, 76, 16, False))
EndFunc   ;==>BuildMenuRowTime

; drags inside the list (slow enough to not fling, start point between texts so no row is clicked), about 7 rows
Func BuildMenuScrollDown()
	BuildMenuDrag(680, 545, 680, 125)
	$g_iBuildMenuPage += 1
	BuildMenuWaitStill()
EndFunc   ;==>BuildMenuScrollDown

Func BuildMenuScrollUp()
	BuildMenuDrag(680, 125, 680, 545)
	If $g_iBuildMenuPage > 1 Then $g_iBuildMenuPage -= 1
	BuildMenuWaitStill()
EndFunc   ;==>BuildMenuScrollUp

; wait until the list stops moving after a drag: 2 frames 150 ms apart with the same white (text) pixels in the name and
; cost columns. A fixed 200 ms wait was too short sometimes (qath 27 Oct: page 2 read while moving, garbled names, all
; costs ''). Only white is compared: the shine of in-progress bars changes the other colors all the time
Global $g_aiBuildMenuStillX[4] = [575, 600, 780, 800] ; name and cost text columns

Func BuildMenuWaitStill($iMaxMs = 1500)
	Local $sLast = "", $sCur, $hTimer = __TimerInit(), $iPix
	While __TimerDiff($hTimer) < $iMaxMs
		If _Sleep(150) Then Return
		_CaptureRegion()
		$sCur = ""
		For $y = 62 To 592 Step 2
			For $x In $g_aiBuildMenuStillX
				$iPix = Dec(_GetPixelColor($x, $y, False))
				$sCur &= (BitAND(BitShift($iPix, 16), 0xFF) > 225 And BitAND(BitShift($iPix, 8), 0xFF) > 225 And BitAND($iPix, 0xFF) > 225) ? "1" : "0"
			Next
		Next
		If $sCur = $sLast Then Return
		$sLast = $sCur
	WEnd
	SetDebugLog("Build menu list still moving after " & $iMaxMs & " ms")
EndFunc   ;==>BuildMenuWaitStill

; list drag with short end hold (~1.8 s less per page than the default 1000 ms hold + 700 ms wait)
Func BuildMenuDrag($x1, $y1, $x2, $y2)
	$g_iMumuDragEndMs = 300
	ClickDrag($x1, $y1, $x2, $y2, 300)
	$g_iMumuDragEndMs = 1000
EndFunc   ;==>BuildMenuDrag

; read rows of current tab, scrolling down until the list does not move anymore,
; or (when $aStopNames is an array) as soon as all names of $aStopNames were seen.
; $sLogTitle: rows are logged page by page while reading (not all at the end)
; $sStopFunc: function called with the rows read so far after each page, True = stop scrolling
; Return [n][9] = BuildMenuReadPage columns + [8] = page number
Global $g_bBuildMenuRedSeen = False ; last BuildMenuCollect saw a red row (not enough resource)

Func BuildMenuCollect($sIconDir, $iNameX, $iNameDy, $sType, $aStopNames = Default, $iMaxPage = 12, $sLogTitle = "", $sStopFunc = "")
	Local $aAll[0][9], $sLastSig = "", $sSig, $iFlags, $bAffordSeen = False, $bCheckNext = False
	$g_bBuildMenuRedSeen = False
	If $sLogTitle <> "" Then SetLog($sLogTitle & ":", $COLOR_INFO)
	For $iPage = 1 To $iMaxPage
		If Not $g_bRunState Then ExitLoop
		If $iPage > 1 Then BuildMenuScrollDown()
		Local $aPage = BuildMenuReadPage($sIconDir, $iNameX, $iNameDy, $sType)
		$iFlags = @extended
		If BitAND($iFlags, 4) Then $g_bBuildMenuRedSeen = True
		$sSig = ""
		For $i = 0 To UBound($aPage) - 1
			$sSig &= $aPage[$i][3] & $aPage[$i][5] & "|"
		Next
		If $iPage > 1 And $sSig = $sLastSig Then ; list did not move: end reached
			$g_iBuildMenuPage -= 1
			ExitLoop
		EndIf
		$sLastSig = $sSig
		For $i = 0 To UBound($aPage) - 1
			Local $bDup = False
			For $j = 0 To UBound($aAll) - 1
				; resource too: "Crafting Station 7 000 000" exists for Gold and Elixir
				If $aAll[$j][3] = $aPage[$i][3] And $aAll[$j][5] = $aPage[$i][5] And $aAll[$j][0] = $aPage[$i][0] Then $bDup = True
			Next
			If $bDup Then ContinueLoop
			Local $aAdd[1][9] = [[$aPage[$i][0], $aPage[$i][1], $aPage[$i][2], $aPage[$i][3], $aPage[$i][4], $aPage[$i][5], 0, $aPage[$i][7], $g_iBuildMenuPage]]
			_ArrayAdd($aAll, $aAdd)
			If $sLogTitle <> "" Then BuildMenuLogRow($aAll, UBound($aAll) - 1)
			SetDebugLog("[BuildMenu p" & $g_iBuildMenuPage & "] " & $aPage[$i][3] & " x" & $aPage[$i][4] & ", cost " & $aPage[$i][5] & " " & $aPage[$i][0])
		Next
		If BuildMenuStopScroll($iFlags, $bAffordSeen, $bCheckNext) Then
			SetDebugLog("[BuildMenu p" & $g_iBuildMenuPage & "] no affordable row after red rows, stop scrolling")
			ExitLoop
		EndIf
		If IsArray($aStopNames) Then
			Local $bAllSeen = True
			For $sStop In $aStopNames
				If _ArraySearch($aAll, $sStop, 0, 0, 0, 0, 1, 3) < 0 Then $bAllSeen = False
			Next
			If $bAllSeen Then ExitLoop ; no need to read the rest of the list
		EndIf
		If $sStopFunc <> "" And UBound($aAll) > 0 Then
			If Call($sStopFunc, $aAll) = True Then ExitLoop
		EndIf
	Next
	If $sLogTitle <> "" And UBound($aAll) = 0 Then SetLog(" - (no affordable row)", $COLOR_DEBUG)
	Return $aAll
EndFunc   ;==>BuildMenuCollect

; go to the row $sName on $iPage (scroll from current page, no close/reopen) and
; return [icon x, icon y, upgrade time min], or 0 if the row is not found
Func BuildMenuGoToItem($iTab, $sName, $iPage, $sIconDir, $iNameX, $iNameDy, $sType, $sFilter = "")
	If Not OpenBuildMenu($iTab, BuildMenuIsBBType($sType), $sFilter) Then Return 0 ; already open on this tab (same filter): page kept
	While $g_iBuildMenuPage > $iPage
		BuildMenuScrollUp()
	WEnd
	While $g_iBuildMenuPage < $iPage
		BuildMenuScrollDown()
	WEnd
	; row may move a little after scrolling: look on this page, then one page down, then up
	Local $aMove[3] = [0, 1, -2]
	For $iMove In $aMove
		If $iMove = 1 Then BuildMenuScrollDown()
		If $iMove = -2 Then
			BuildMenuScrollUp()
			BuildMenuScrollUp()
		EndIf
		Local $aPage = BuildMenuReadPage($sIconDir, $iNameX, $iNameDy, $sType)
		For $i = 0 To UBound($aPage) - 1
			If $aPage[$i][3] = $sName Then
				Local $aRet[3] = [$aPage[$i][1], $aPage[$i][2], BuildMenuRowTime($aPage[$i][2])]
				Return $aRet
			EndIf
		Next
	Next
	SetLog("BuildMenu: " & $sName & " not found again on page " & $iPage, $COLOR_WARNING)
	Return 0
EndFunc   ;==>BuildMenuGoToItem

; ============================================== Builder Base ==============================================

; Builder Base: a click on a Build menu row opens the "Upgrade to level X?" window directly.
; Building window: green button with cost at (433,540). Star Laboratory window: green button at (718,577)
; (left of it is the blue book/potion button, never click there). Red cost on the button = not enough resource.
; Return True when upgrade started (or window found in test mode)
Func BBConfirmUpgradeWindow($sName, $bTest = False)
	Local $iBtnX = 0, $iBtnY = 0
	For $i = 1 To 6 ; wait for the window
		_CaptureRegion()
		If BBIsGreen(_GetPixelColor(433, 565, False)) Then
			$iBtnX = 433
			$iBtnY = 540
			ExitLoop
		ElseIf BBIsGreen(_GetPixelColor(718, 600, False)) Then
			$iBtnX = 718
			$iBtnY = 577
			ExitLoop
		EndIf
		If _Sleep(500) Then Return False
	Next
	If $iBtnX = 0 Then
		SetLog($sName & ": upgrade window not found", $COLOR_ERROR)
		If $g_bDebugImageSave Then SaveDebugImage("BBUpgradeWindow")
		Return False
	EndIf
	; red cost text on the button = not enough resource
	Local $iRed = 0, $iPix
	For $x = $iBtnX - 80 To $iBtnX + 40 Step 4
		For $y = $iBtnY - 8 To $iBtnY + 8 Step 4
			$iPix = Dec(_GetPixelColor($x, $y, False))
			If BitAND(BitShift($iPix, 16), 0xFF) > 230 And BitAND(BitShift($iPix, 8), 0xFF) < 160 And BitAND($iPix, 0xFF) < 160 Then $iRed += 1
		Next
	Next
	If $iRed > 8 Then
		SetLog($sName & ": not enough resource (red cost on button)", $COLOR_INFO)
		ClickAway("Left")
		Return False
	EndIf
	If $bTest Then
		SetLog("[test] " & $sName & " upgrade window OK, button at " & $iBtnX & "," & $iBtnY & ", not confirmed", $COLOR_DEBUG)
		ClickAway("Left")
		Return True
	EndIf
	Click($iBtnX, $iBtnY, 1, 0, "Upgrade " & $sName)
	If _Sleep(1000) Then Return False
	If isGemOpen(True) Then
		SetLog($sName & ": upgrade failed, gem window popped up", $COLOR_ERROR)
		ClickAway("Left")
		Return False
	EndIf
	SetLog($sName & " upgrade started", $COLOR_SUCCESS)
	AutoUpgradeLog(False, "BB " & $sName, "", 0)
	Return True
EndFunc   ;==>BBConfirmUpgradeWindow

Func BBIsGreen($sColor)
	Local $iPix = Dec($sColor)
	Local $r = BitAND(BitShift($iPix, 16), 0xFF), $g = BitAND(BitShift($iPix, 8), 0xFF), $b = BitAND($iPix, 0xFF)
	Return $g > 170 And $r < 190 And $b < 80
EndFunc   ;==>BBIsGreen

; Builder Base building upgrade from Build menu tab 1.
; Takes the first row from the top that can be upgraded (resource enough, not ignored in GUI): no full list read.
Func BBUpgradeBuildMenu($bTest = False)
	If Not $g_bAutoUpgradeBBEnabled Or Not $g_bRunState Then Return False
	Local $iUpgraded = 0, $aSkip[0], $iExpectFree = -1, $sLast = ""
	For $iTry = 1 To 6 ; never loop forever
		If Not $g_bRunState Then ExitLoop
		CloseBuildMenu() ; list back on top for every try
		If Not OpenBuildMenu(1, True) Then ExitLoop
		; a started building upgrade takes a Master Builder (counters read again when the menu opens, walls are instant)
		If $iExpectFree >= 0 And $g_aiBuildMenuCounter[1][1] > 0 And $g_iFreeBuilderCountBB > $iExpectFree Then
			SetLog("BB " & $sLast & ": free Master Builders did not go down, upgrade not confirmed, stop", $COLOR_ERROR)
			$iUpgraded -= 1
			ExitLoop
		EndIf
		$iExpectFree = -1
		BuildMenuReadLoot($iTry = 1, True)
		If $g_iFreeBuilderCountBB < 1 And Not $bTest Then
			If $iUpgraded = 0 Then SetLog("No free Master Builder", $COLOR_INFO)
			ExitLoop
		EndIf
		Local $aRow = BBFindFirstUpgrade($aSkip)
		If Not IsArray($aRow) Then
			If $iUpgraded = 0 Then SetLog("No BB upgrade available (ignored / not enough resource)", $COLOR_INFO)
			ExitLoop
		EndIf
		_ArrayAdd($aSkip, $aRow[0]) ; same name is not tried again in this run (e.g. all "Wall" rows)
		SetLog("BB upgrade: " & $aRow[0] & ", cost " & _NumberFormat($aRow[2]) & " " & $aRow[1], $COLOR_ACTION)
		Click($aRow[3], $aRow[4])
		If _Sleep(1000) Then Return False
		Local $bOk = False
		If $aRow[0] = "Wall" Then
			$bOk = BBUpgradeWallSelected($aRow[1], $bTest, $aRow[2]) ; wall row selects a wall on the village
		Else
			$bOk = BBConfirmUpgradeWindow($aRow[0], $bTest) ; other rows open the upgrade window
		EndIf
		If $bOk Then
			$iUpgraded += 1
			If $aRow[0] <> "Wall" Then
				$iExpectFree = $g_iFreeBuilderCountBB - 1
				$sLast = $aRow[0]
			EndIf
		EndIf
		If $bTest Then ExitLoop
	Next
	ClickAway("Left")
	CloseBuildMenu()
	Return $iUpgraded > 0
EndFunc   ;==>BBUpgradeBuildMenu

; scan the BB list from the top, return [name, resource, cost, x, y] of the first row to upgrade, or 0.
; Only page 1 (affordable rows are on top, most expensive first, red rows skipped);
; page 2 only when page 1 has no affordable row.
; Wall (not ignored) is only taken when 1 Master Builder is left, or with more free Master Builders when no other building
; is left to upgrade (none waiting for resources either: red rows are read for that)
Func BBFindFirstUpgrade(ByRef $aSkip)
	Local $aWall = 0, $aOther = 0, $bWait = False ; $bWait: a building waits for resources (red cost)
	For $iPage = 1 To 2
		If Not $g_bRunState Then Return 0
		If $iPage > 1 Then BuildMenuScrollDown()
		Local $aPage = BuildMenuReadPage("", 562, -18, "bb", True)
		Local $bAfford = (BitAND(@extended, 2) = 2)
		BuildMenuLogList("BB Upgrade List (page " & $iPage & ")", $aPage)
		For $i = 0 To UBound($aPage) - 1
			; name not read (a lone "Mine" always gives empty OCR): still a building to upgrade, so Wall is not taken first
			If Not $aPage[$i][7] Then
				; a main village name (quiver, Oct 2026: 'Pet House' 12 000 000 Elix, an ad was over the screen): not the BB list
				If $aPage[$i][3] <> "" Then
					OcrMatchBuildingName($aPage[$i][3])
					If @extended = 1 Then
						SetLog("BB list: main village row '" & $aPage[$i][3] & "', not the BB Build menu, stop", $COLOR_WARNING)
						Return 0
					EndIf
				EndIf
				$aPage[$i][3] = "?"
				; name and cost both unread (row cut at the list edge): "upgrade window not found" after a 4 s try (quiver 27 Oct)
				If $aPage[$i][5] = 0 Then ContinueLoop
			EndIf
			If $aPage[$i][3] = "Builder Hall" And $g_bChkAutoUpgradeBBIgnoreHall Then ContinueLoop
			If $aPage[$i][5] = -1 Then ; red cost
				If $aPage[$i][3] <> "Wall" Then $bWait = True
				ContinueLoop
			EndIf
			If _ArraySearch($aSkip, $aPage[$i][3]) >= 0 Then ContinueLoop
			If $aPage[$i][3] = "Wall" And ($g_bChkAutoUpgradeBBIgnoreWall Or $aPage[$i][5] = 0) Then ContinueLoop ; wall needs its cost (Upgrade More)
			Local $iLoot = $aPage[$i][0] = "Elix" ? $g_aiCurrentLootBB[$eLootElixirBB] : $g_aiCurrentLootBB[$eLootGoldBB]
			If Number($iLoot) < $aPage[$i][5] Then
				If $aPage[$i][3] <> "Wall" Then $bWait = True
				ContinueLoop
			EndIf
			Local $aRet[5] = [$aPage[$i][3], $aPage[$i][0], $aPage[$i][5], $aPage[$i][1], $aPage[$i][2]]
			If $aPage[$i][3] = "Wall" Then
				If Not IsArray($aWall) Then $aWall = $aRet
			ElseIf Not IsArray($aOther) Then
				$aOther = $aRet
			EndIf
		Next
		If IsArray($aWall) And $g_iFreeBuilderCountBB <= 1 Then
			SetDebugLog("BB list: 1 Master Builder left, Wall first")
			Return $aWall
		EndIf
		If IsArray($aOther) Then Return $aOther
		If IsArray($aWall) And $bWait Then ExitLoop
		If $bAfford And Not IsArray($aWall) Then ExitLoop ; affordable rows on this page are all ignored / skipped: no scroll
		; only walls (look on page 2 for buildings waiting for resources) or no affordable row
		SetDebugLog("BB list: page " & $iPage & ($bAfford ? ": only walls" : ": no affordable row"))
	Next
	If IsArray($aWall) And $bWait Then
		SetLog("BB: " & $g_iFreeBuilderCountBB & " Master Builders free, buildings wait for resources: no wall upgrade now", $COLOR_INFO)
		Return 0
	EndIf
	If IsArray($aWall) Then SetDebugLog("BB list: nothing else to upgrade, Wall")
	Return $aWall
EndFunc   ;==>BBFindFirstUpgrade

; a Wall row of BB Build menu selects one wall on the village and shows buttons at the bottom:
; Upgrade with Gold (cost + gold icon ~185,570) and Upgrade with Elixir (cost + elixir icon ~278,570)
Func BBUpgradeWallSelected($sResource, $bTest = False, $iWallCost = 0)
	Local $iIconX = 0
	For $i = 1 To 6
		_CaptureRegion()
		$iIconX = BBWallButtonIconX($sResource)
		If $iIconX > 0 Then ExitLoop
		If _Sleep(500) Then Return False
	Next
	If $iIconX = 0 Then
		SetLog("Wall: upgrade button with " & $sResource & " not found", $COLOR_ERROR)
		If $g_bDebugImageSave Then SaveDebugImage("BBWallButtons")
		Return False
	EndIf
	Local $iBtnX = $iIconX - 30 ; icon is at the right end of the cost text, button center is ~30 px left of it
	If BBWallCostRed($iBtnX) Then ; red cost on the button = not enough resource
		SetLog("Wall: not enough " & $sResource & " (red cost)", $COLOR_INFO)
		Return False
	EndIf
	If $bTest Then
		SetLog("[test] Wall upgrade button with " & $sResource & " found, not clicked", $COLOR_DEBUG)
		Return True
	EndIf
	; more walls of the same level with Upgrade More (+10 / +1), count from the resource (exact cost, max 50 walls)
	Local $iLoot = Number($sResource = "Elix" ? $g_aiCurrentLootBB[$eLootElixirBB] : $g_aiCurrentLootBB[$eLootGoldBB])
	Local $iCount = $iWallCost > 0 ? Floor($iLoot / $iWallCost) : 1
	If $iCount > 50 Then $iCount = 50
	If $iCount >= 2 Then
		Local $iMore = BBWallUpgradeMore($sResource, $iCount)
		If $iMore = 1 Then Return True
		If $iMore = -1 Then Return False ; Upgrade More was used but upgrade failed: wall unselected, nothing spent
		; 0 = no Upgrade More button: upgrade the selected wall only
	EndIf
	Click($iBtnX, 605, 1, 0, "Wall upgrade " & $sResource)
	If _Sleep(1000) Then Return False
	; possible confirm window (same green button as other BB upgrade windows)
	_CaptureRegion()
	If BBIsGreen(_GetPixelColor(433, 565, False)) Or BBIsGreen(_GetPixelColor(718, 600, False)) Then Return BBConfirmUpgradeWindow("Wall", False)
	If isGemOpen(True) Then
		SetLog("Wall upgrade failed, gem window popped up", $COLOR_ERROR)
		ClickAway("Left")
		Return False
	EndIf
	SetLog("Wall upgrade started (" & $sResource & ")", $COLOR_SUCCESS)
	Return True
EndFunc   ;==>BBUpgradeWallSelected

; red cost text on a wall upgrade button (button center $iBtnX, cost line top $iY: 566 bottom row, 482 top row),
; uses the last _CaptureRegion frame
Func BBWallCostRed($iBtnX, $iY = 566)
	Local $iRed = 0, $iPix
	For $x = $iBtnX - 30 To $iBtnX + 22 Step 3
		For $y = $iY To $iY + 10 Step 2
			$iPix = Dec(_GetPixelColor($x, $y, False))
			If BitAND(BitShift($iPix, 16), 0xFF) > 230 And BitAND(BitShift($iPix, 8), 0xFF) < 160 And BitAND($iPix, 0xFF) < 160 Then $iRed += 1
		Next
	Next
	Return $iRed > 5
EndFunc   ;==>BBWallCostRed

; pixels of a top row wall button (column center $iX: 155 / 248 / 340, y 478..545), uses the last _CaptureRegion frame
; $sKind "green" = green text/arrows ("+10", "+1", Select Row arrows), "beige" = button background
Func BBWallTopButtonPixels($iX, $sKind)
	Local $iHits = 0, $iPix, $r, $g, $b
	For $x = $iX - 30 To $iX + 30 Step 2
		For $y = 478 To 545 Step 2
			$iPix = Dec(_GetPixelColor($x, $y, False))
			$r = BitAND(BitShift($iPix, 16), 0xFF)
			$g = BitAND(BitShift($iPix, 8), 0xFF)
			$b = BitAND($iPix, 0xFF)
			If $sKind = "green" Then
				If $g > 170 And $r < 170 And $b < 110 Then $iHits += 1
			Else
				If $r > 200 And $g > 180 And $b > 130 And $b < 200 Then $iHits += 1
			EndIf
		Next
	Next
	Return $iHits
EndFunc   ;==>BBWallTopButtonPixels

; Upgrade More on a selected BB wall (same layout as home village, tested on BB screenshots lv5 / lv6):
; top row before: Info | Select Row | Upgrade More (no green), after Upgrade More: Remove Wall | +10 (green) | +1 (green)
; bottom row keeps the Gold / Elixir upgrade buttons, their cost becomes the total cost.
; Return 1 = upgraded, 0 = no Upgrade More button (nothing clicked), -1 = failed after Upgrade More (wall unselected)
Func BBWallUpgradeMore($sResource, $iCount)
	Static $iFail = 0 ; resource button not found after Upgrade More 3 times in a row: single wall upgrade until bot restart
	If $iFail >= 3 Then Return 0
	_CaptureRegion()
	; Upgrade More by its white "+" (column 340 only missed it: quazzy 28 Oct 'no Upgrade More button'), +1 takes its column
	Local $aPlusSign[3]
	If Not WallPlusSignByShape($aPlusSign) Or Not WallUpgradeMoreEnabled($aPlusSign) Then
		SetDebugLog("Wall: no Upgrade More button (or disabled)")
		Return 0
	EndIf
	Local $iMoreX = $aPlusSign[0] - 20
	Click($iMoreX, 510, 1, 50, "Wall Upgrade More")
	Local $bPlus = False, $iPlusX = $iMoreX
	For $i = 1 To 6 ; buttons change with an animation (one check after 700 ms missed it, 21 Oct 2026)
		If _Sleep(350) Then Return -1
		_CaptureRegion()
		If BBWallTopButtonPixels($iMoreX, "green") >= 15 Then
			$bPlus = True
			ExitLoop
		EndIf
		; fewer than 10 walls left of this level (qassa, Oct 2026): no +10, top row Remove Wall | +1 | Gold upgrade
		If BBWallTopButtonPixels($iMoreX - 92, "green") >= 15 Then
			$bPlus = True
			$iPlusX = $iMoreX - 92
			ExitLoop
		EndIf
	Next
	Local $iWalls = 1
	; +1 grey (last wall of this level, checked on zone 23 Oct 2026: green +1 shows within 350 ms when it can be used):
	; the selected wall is still upgraded alone with the buttons below
	If Not $bPlus Then
		SetLog("Wall: +1 not available (no other wall of this level), upgrade 1 wall", $COLOR_INFO)
		$iCount = 1
	EndIf
	If $iCount >= 11 And $iPlusX = $iMoreX And BBWallTopButtonPixels($iMoreX - 92, "green") >= 40 Then
		While $iWalls + 10 <= $iCount
			Click($iMoreX - 92, 510, 1, 50, "Wall +10")
			If _Sleep(400) Then Return -1
			$iWalls += 10
		WEnd
	EndIf
	While $iWalls < $iCount
		Click($iPlusX, 510, 1, 50, "Wall +1")
		If _Sleep(300) Then Return -1
		$iWalls += 1
	WEnd
	If _Sleep(300) Then Return -1
	; total cost text is longer now: resource icon is searched again on the cost line
	_CaptureRegion()
	Local $iRowY = 0
	Local $iIconX = BBWallButtonIconXRow($sResource, $iRowY)
	If $iIconX = 0 Then
		$iFail += 1
		SetLog("Wall: " & $sResource & " button not found after Upgrade More (" & $iFail & "/3" & ($iFail >= 3 ? ", disabled until restart" : "") & ")", $COLOR_WARNING)
		If $g_bDebugImageSave Then SaveDebugImage("BBWallUpgradeMore")
		ClickAway("Left")
		Return -1
	EndIf
	; total cost red (cost OCR off): Remove Wall (-1) until the cost is not red
	While BBWallCostRed($iIconX - 30, $iRowY) And $iWalls > 1
		Click($iPlusX - ($iPlusX = $iMoreX ? 184 : 92), 510, 1, 50, "Wall -1") ; Remove Wall = leftmost of the top row
		If _Sleep(300) Then Return -1
		$iWalls -= 1
		_CaptureRegion()
		$iIconX = BBWallButtonIconXRow($sResource, $iRowY)
		If $iIconX = 0 Then ExitLoop
	WEnd
	If $iIconX = 0 Or BBWallCostRed($iIconX - 30, $iRowY) Then
		SetLog("Wall: not enough " & $sResource & " (red cost), skip", $COLOR_INFO)
		ClickAway("Left")
		Return -1
	EndIf
	Click($iIconX - 30, $iRowY + 39, 1, 0, "Wall upgrade x" & $iWalls & " " & $sResource)
	If _Sleep(1000) Then Return -1
	_CaptureRegion()
	If BBIsGreen(_GetPixelColor(433, 565, False)) Or BBIsGreen(_GetPixelColor(718, 600, False)) Then
		If Not BBConfirmUpgradeWindow("Wall x" & $iWalls, False) Then Return -1
	ElseIf IsOKCancelPage() Then
		ClickP($aConfirmSurrender) ; confirm upgrade OK button
		If _Sleep(500) Then Return -1
	EndIf
	If isGemOpen(True) Then
		SetLog("Wall upgrade failed, gem window popped up", $COLOR_ERROR)
		ClickAway("Left")
		Return -1
	EndIf
	$iFail = 0
	SetLog("Wall upgrade started (" & $sResource & " x" & $iWalls & ")", $COLOR_SUCCESS)
	Return 1
EndFunc   ;==>BBWallUpgradeMore

; resource icon on the cost line of the wall upgrade buttons (bottom left), uses the last _CaptureRegion frame.
; The icon moves with the cost text length and the button layout, so the whole line is scanned (x 110..305, y 566..574)
; Return icon x, 0 = not found
Func BBWallButtonIconX($sResource, $iY = 566, $iX0 = 110, $iX1 = 305)
	Local $iPix, $r, $g, $b, $iHits
	For $x = $iX0 To $iX1 Step 2
		$iHits = 0
		For $y = $iY To $iY + 8 Step 2
			$iPix = Dec(_GetPixelColor($x, $y, False))
			$r = BitAND(BitShift($iPix, 16), 0xFF)
			$g = BitAND(BitShift($iPix, 8), 0xFF)
			$b = BitAND($iPix, 0xFF)
			If $sResource = "Elix" Then
				If $r > 130 And $b > 170 And $g < 120 Then $iHits += 1
			Else
				If $r > 200 And $g > 150 And $b < 90 Then $iHits += 1
			EndIf
		Next
		If $iHits >= 3 Then Return $x
	Next
	Return 0
EndFunc   ;==>BBWallButtonIconX

; after Upgrade More with fewer than 10 walls of the level the Gold button moves to the top row (x ~340, qassa Oct 2026:
; Gold icon 366,486, Elixir icon 232,570). Bottom row first: the top row scan finds a wrong icon when +10 is there.
; $iRowY = cost line top of the row found (566 bottom, 482 top), button click y = $iRowY + 39
Func BBWallButtonIconXRow($sResource, ByRef $iRowY)
	$iRowY = 566
	Local $iX = BBWallButtonIconX($sResource)
	If $iX > 0 Then Return $iX
	$iRowY = 482
	Return BBWallButtonIconX($sResource, 482, 300, 420)
EndFunc   ;==>BBWallButtonIconXRow

; Star Laboratory upgrade from Build menu tab 2
Func StarLabUpgradeBuildMenu($bTest = False)
	If Not $g_bAutoStarLabUpgradeEnable Or Not $g_bRunState Then Return False
	; counters already read by the BB building upgrade a moment ago: busy Star Laboratory needs no menu
	If Not $bTest And BuildMenuCountersFresh(True) And $g_aiBuildMenuCounter[2][0] = 0 Then
		SetLog("Star Laboratory is busy", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf
	If Not OpenBuildMenu(2, True) Then Return False
	BuildMenuReadLoot(True, True)
	If $g_aiBuildMenuCounter[2][0] = 0 And Not $bTest Then
		SetLog("Star Laboratory is busy", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf
	Local $aList = BuildMenuCollect("", 562, -18, "slab", Default, 12, "Star Laboratory Upgrade List")
	Local $iElix = Number($g_aiCurrentLootBB[$eLootElixirBB]), $iPick = -1
	Local $aWanted[0]
	If $g_bSLabUpgradeOrderEnable Then
		For $z = 0 To UBound($g_aCmbSLabUpgradeOrder) - 1
			If $g_aCmbSLabUpgradeOrder[$z] >= 0 Then _ArrayAdd($aWanted, $g_asStarLabGameNames[$g_aCmbSLabUpgradeOrder[$z] + 1])
		Next
	ElseIf $g_iCmbStarLaboratory > 0 Then
		_ArrayAdd($aWanted, $g_asStarLabGameNames[$g_iCmbStarLaboratory])
	EndIf
	For $sWant In $aWanted
		For $i = 0 To UBound($aList) - 1
			If $aList[$i][7] And $aList[$i][3] = $sWant And $iElix >= $aList[$i][5] Then
				$iPick = $i
				ExitLoop 2
			EndIf
		Next
	Next
	If $iPick < 0 Then ; selected troop not available: any affordable (rows with red cost are already skipped)
		For $i = 0 To UBound($aList) - 1
			If $aList[$i][7] And $iElix >= $aList[$i][5] Then
				$iPick = $i
				ExitLoop
			EndIf
		Next
	EndIf
	If $iPick < 0 Then
		SetLog("No Star Laboratory upgrade available", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf
	Local $aCoord = BuildMenuGoToItem(2, $aList[$iPick][3], $aList[$iPick][8], "", 562, -18, "slab")
	If Not IsArray($aCoord) Then
		CloseBuildMenu()
		Return False
	EndIf
	SetLog("Star Lab upgrade: " & $aList[$iPick][3] & ", cost " & _NumberFormat($aList[$iPick][5]), $COLOR_ACTION)
	ClickP($aCoord) ; opens the upgrade window
	If _Sleep(1000) Then Return False
	Local $bRet = BBConfirmUpgradeWindow($aList[$iPick][3], $bTest)
	CloseBuildMenu()
	Return $bRet
EndFunc   ;==>StarLabUpgradeBuildMenu
