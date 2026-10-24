; #FUNCTION# ====================================================================================================================
; Name ..........: UpgradeHeroes
; Description ...: Upgrade heroes from Hero Hall window (all heroes are upgraded from Hero Hall since 2024 update)
;                  Cards are found by hero name (OCR), cost is read on the Upgrade button of each card.
; Syntax ........: UpgradeHeroes([$bTest = False])
; Return values .: True when an upgrade was started
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; ===============================================================================================================================


Func HeroHallEnabledList()
	Local $aEnable[6] = [$g_bUpgradeKingEnable, $g_bUpgradeQueenEnable, $g_bUpgradePrinceEnable, $g_bUpgradeWardenEnable, $g_bUpgradeChampionEnable, $g_bUpgradeDukeEnable]
	Return $aEnable
EndFunc   ;==>HeroHallEnabledList

; Hero upgrade from Build menu, tab 1 "Buildings & Heroes" (only checked heroes)
; Hero Hall window way is kept in UpgradeHeroesHeroHall()
Func UpgradeHeroes($bTest = False)
	Local $aEnable = HeroHallEnabledList(), $aWanted[0]
	For $h = 0 To 5
		If $aEnable[$h] Then _ArrayAdd($aWanted, $g_asHeroHallNames[$h])
	Next
	If UBound($aWanted) = 0 Or Not $g_bRunState Then Return False

	checkMainScreen(False)
	If $g_bRestart Then Return False
	Local $iUpgraded = 0, $aDone[0]
	; Hero filter: Guardians + heroes only (short list, no scroll through every building). Guardian rows do not match a hero name
	Local $sFilter = "Hero"
	While $g_bRunState
		If Not OpenBuildMenu(1, False, $sFilter) Then
			If $sFilter = "" Or @error <> 1 Then ExitLoop
			$sFilter = "" ; filter failed (no filter button while the Town Hall is upgrading): whole list
			If Not OpenBuildMenu(1) Then ExitLoop
		EndIf
		BuildMenuReadLoot($iUpgraded = 0) ; resources and builders without closing the menu
		If $g_iFreeBuilderCount - WallReservedBuilder() < 1 And Not $bTest Then
			SetLog("No builder available for hero upgrade (Free:" & $g_iFreeBuilderCount & ", Wall reserve:" & WallReservedBuilder() & ")", $COLOR_INFO)
			ExitLoop
		EndIf

		If $iUpgraded = 0 Then SetLog("Checking for Hero upgrade", $COLOR_INFO)
		; heroes are usually on top of the list (suggested upgrades): stop scrolling when all checked heroes are seen
		Local $aList = BuildMenuCollect($g_sImgResourceIcon, $g_iXFindUpgrade, -22, "hero", $aWanted)
		BuildMenuLogList("Hero Upgrade List", $aList)
		Local $iRow = -1, $sHero = ""
		For $h = 0 To UBound($aWanted) - 1
			If _ArraySearch($aDone, $aWanted[$h]) >= 0 Then ContinueLoop
			For $i = 0 To UBound($aList) - 1
				If Not $aList[$i][7] Or $aList[$i][3] <> $aWanted[$h] Then ContinueLoop
				Local $bElixir = ($aList[$i][0] = "Elix")
				Local $iLoot = $bElixir ? Number($g_aiCurrentLoot[$eLootElixir]) : Number($g_aiCurrentLoot[$eLootDarkElixir])
				Local $iMinSave = $bElixir ? $g_iUpgradeMinElixir : $g_iUpgradeMinDark
				If $iLoot >= $aList[$i][5] + $iMinSave Then
					$iRow = $i
					$sHero = $aWanted[$h]
					ExitLoop 2
				EndIf
				SetLog($aWanted[$h] & ": need " & _NumberFormat($aList[$i][5]) & " + save " & _NumberFormat($iMinSave) & ", have " & _NumberFormat($iLoot), $COLOR_INFO)
				_ArrayAdd($aDone, $aWanted[$h]) ; do not check it again in this run
			Next
		Next
		If $iRow < 0 Then
			If $iUpgraded = 0 Then SetLog("No checked hero to upgrade (upgrading, max level, locked or not enough resource)", $COLOR_INFO)
			ExitLoop
		EndIf

		Local $aCoord = BuildMenuGoToItem(1, $sHero, $aList[$iRow][8], $g_sImgResourceIcon, $g_iXFindUpgrade, -22, "hero", $sFilter)
		_ArrayAdd($aDone, $sHero)
		If Not IsArray($aCoord) Then ContinueLoop
		SetLog("Upgrade " & $sHero & ", cost: " & _NumberFormat($aList[$iRow][5]) & " " & $aList[$iRow][0], $COLOR_ACTION)
		ClickP($aCoord) ; opens hero upgrade window
		If _Sleep(1500) Then Return False
		If $bTest Then
			SetLog("[test] " & $sHero & " upgrade window open: " & String(IsUpgradeWindowOpen()) & ", not confirmed", $COLOR_DEBUG)
			ClickAway()
			ExitLoop
		EndIf
		If Not DoUpgradeHero($sHero, $aList[$iRow][5], $aList[$iRow][0]) Then ; same confirm as Auto Upgrade
			ClickAway()
			ExitLoop
		EndIf
		$iUpgraded += 1
		$g_iNbrOfHeroesUpped += 1
		If $aList[$iRow][0] = "DE" Then $g_iCostDElixirHero += $aList[$iRow][5]
		UpdateStats()
		If _Sleep(500) Then Return False
		If IsUpgradeWindowOpen() Then ClickAway("Left")
		; more builders left? loop reads builders and loot again on the Build menu
	WEnd
	ClickAway()
	CloseBuildMenu()
	Return $iUpgraded > 0
EndFunc   ;==>UpgradeHeroes

; old way from Hero Hall window (needs Heroes button found by text), kept for reference

; click Hero Hall building and open the heroes window

; OCR hero names on visible cards. Return [n][3] = [hero index (Hero Hall order), card x, name y]

; find card of $iHero, scroll right/left when needed. Return [x, name y] or 0

; confirm hero upgrade in the upgrade window
Func HeroUpgradeConfirm()
	If ClickB("Upgrade") Then Return True
	Local $aWhiteZeros = decodeSingleCoord(findImage("UpgradeWhiteZero", $g_sImgUpgradeWhiteZero, GetDiamondFromRect("408,519,747,606"), 1, True, Default))
	If IsArray($aWhiteZeros) And UBound($aWhiteZeros, 1) = 2 Then
		ClickP($aWhiteZeros, 1, 0)
		Return True
	EndIf
	If $g_bDebugImageSave Then SaveDebugImage("HeroUpgradeConfirm")
	Return False
EndFunc   ;==>HeroUpgradeConfirm

Func ReservedBuildersForHeroes()
	Local $iUsedBuildersForHeroes = Number(BitAND($g_iHeroUpgradingBit, $eHeroKing) = $eHeroKing ? 1 : 0) + Number(BitAND($g_iHeroUpgradingBit, $eHeroQueen) = $eHeroQueen ? 1 : 0) + Number(BitAND($g_iHeroUpgradingBit, $eHeroWarden) = $eHeroWarden ? 1 : 0) + Number(BitAND($g_iHeroUpgradingBit, $eHeroChampion) = $eHeroChampion ? 1 : 0)
	If $iUsedBuildersForHeroes = 1 Then
		If $g_bDebugSetlog Then SetLog($iUsedBuildersForHeroes & " builder is upgrading your heroes.", $COLOR_INFO)
	Else
		If $g_bDebugSetlog Then SetLog($iUsedBuildersForHeroes & " builders are upgrading your heroes.", $COLOR_INFO)
	EndIf

	Local $iFreeBuildersReservedForHeroes = _Max(Number($g_iHeroReservedBuilder) - $iUsedBuildersForHeroes, 0)
	If $iFreeBuildersReservedForHeroes = 1 Then
		If $g_bDebugSetlog Then SetLog($iFreeBuildersReservedForHeroes & " free builder is reserved for heroes.", $COLOR_INFO)
	Else
		If $g_bDebugSetlog Then SetLog($iFreeBuildersReservedForHeroes & " free builders are reserved for heroes.", $COLOR_INFO)
	EndIf

	If $g_bDebugSetlog Then SetLog("HeroBuilders R|Rn|W|F: " & $g_iHeroReservedBuilder & "|" & Number($g_iHeroReservedBuilder) & "|" & $iUsedBuildersForHeroes & "|" & $iFreeBuildersReservedForHeroes, $COLOR_DEBUG)

	Return $iFreeBuildersReservedForHeroes
EndFunc   ;==>ReservedBuildersForHeroes
