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
	While $g_bRunState
		If Not OpenBuildMenu(1) Then ExitLoop
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

		Local $aCoord = BuildMenuGoToItem(1, $sHero, $aList[$iRow][8], $g_sImgResourceIcon, $g_iXFindUpgrade, -22, "hero")
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
Func UpgradeHeroesHeroHall($bTest = False)
	Local $aEnable = HeroHallEnabledList(), $bAny = False
	For $h = 0 To 5
		If $aEnable[$h] Then $bAny = True
	Next
	If Not $bAny Then Return False
	If Not $g_bRunState Then Return False

	checkMainScreen(False)
	If $g_bRestart Then Return False
	VillageReport(True, True)
	If Not getBuilderCount(True) Then Return False
	Local $iAvail = $g_iFreeBuilderCount - WallReservedBuilder()
	If $iAvail < 1 And Not $bTest Then
		SetLog("No builder available for hero upgrade (Free:" & $g_iFreeBuilderCount & ", Wall reserve:" & WallReservedBuilder() & ")", $COLOR_INFO)
		Return False
	EndIf

	SetLog("Upgrading Heroes", $COLOR_INFO)
	If Not OpenHeroHallWindow() Then
		ClickAway()
		Return False
	EndIf

	Local $iPage = 1, $bRet = False
	For $h = 0 To 5
		If Not $aEnable[$h] Then ContinueLoop
		If Not $g_bRunState Then Return False
		Local $sHero = $g_asHeroHallNames[$h]

		; Lab has priority on same resource (old behaviour)
		Local $bElixir = ($h = 3) ; Grand Warden uses Elixir, others Dark Elixir
		If $g_bAutoLabUpgradeEnable And (($bElixir And $g_iLaboratoryElixirCost > 0) Or (Not $bElixir And $g_iLaboratoryDElixirCost > 0)) Then
			SetLog("Laboratory needs " & ($bElixir ? "Elixir" : "Dark Elixir") & ", skip " & $sHero, $COLOR_INFO)
			ContinueLoop
		EndIf

		Local $aCard = HeroHallFindCard($h, $iPage)
		If Not IsArray($aCard) Then
			SetLog("Cannot find " & $sHero & " in Hero Hall", $COLOR_WARNING)
			ContinueLoop
		EndIf

		Local $iCost = Number(getOcrAndCapture("coc-labcost", $aCard[0] - 50, $aCard[1] + 195, 92, 20, True))
		If $iCost <= 0 Then
			SetLog($sHero & ": no upgrade cost found (upgrading or max level)", $COLOR_INFO)
			ContinueLoop
		EndIf

		Local $iLoot = $bElixir ? Number($g_aiCurrentLoot[$eLootElixir]) : Number($g_aiCurrentLoot[$eLootDarkElixir])
		Local $iMinSave = $bElixir ? $g_iUpgradeMinElixir : $g_iUpgradeMinDark
		If $iLoot < $iCost + $iMinSave Then
			SetLog($sHero & ": need " & _NumberFormat($iCost) & " + save " & _NumberFormat($iMinSave) & ", have " & _NumberFormat($iLoot), $COLOR_INFO)
			ContinueLoop
		EndIf

		SetLog("Upgrade " & $sHero & ", cost: " & _NumberFormat($iCost) & ($bElixir ? " Elixir" : " DE"), $COLOR_ACTION)
		Click($aCard[0], $aCard[1] + 195, 1, 0, "Upgrade " & $sHero)
		If _Sleep(1500) Then Return False
		If $bTest Then
			SetLog("[test] " & $sHero & " upgrade window should be open now, not confirmed", $COLOR_DEBUG)
			ExitLoop
		EndIf

		If Not HeroUpgradeConfirm() Then
			SetLog($sHero & " upgrade confirm button not found", $COLOR_ERROR)
			ExitLoop
		EndIf
		If _Sleep(1000) Then Return False
		If isGemOpen(True) Then
			SetLog($sHero & " upgrade failed, gem window popped up", $COLOR_ERROR)
			ClickAway()
			ExitLoop
		EndIf

		SetLog($sHero & " upgrade started", $COLOR_SUCCESS)
		$g_iNbrOfHeroesUpped += 1
		If Not $bElixir Then $g_iCostDElixirHero += $iCost
		UpdateStats()
		$bRet = True
		ExitLoop ; one builder used, next upgrade on next run
	Next

	ClickAway()
	If _Sleep(500) Then Return $bRet
	ClickAway()
	Return $bRet
EndFunc   ;==>UpgradeHeroesHeroHall

; click Hero Hall building and open the heroes window
Func OpenHeroHallWindow()
	If Not isInsideDiamond($g_aiHeroHallPos) Or $g_aiHeroHallPos[0] < 1 Then LocateHeroHall()
	If $g_aiHeroHallPos[0] < 1 Or $g_aiHeroHallPos[1] < 1 Then
		SetLog("Hero Hall location unknown", $COLOR_ERROR)
		Return False
	EndIf

	ClickAway()
	If _Sleep(500) Then Return False
	ClickP($g_aiHeroHallPos)
	If _Sleep(800) Then Return False
	Local $aInfo = BuildingInfo()
	If Not IsArray($aInfo) Or Not StringInStr($aInfo[1], "Hero") Then
		SetLog("Wrong click on Hero Hall (" & (IsArray($aInfo) ? $aInfo[1] : "") & "), please locate Hero Hall again", $COLOR_WARNING)
		ClickAway()
		Return False
	EndIf

	; heroes button below the building: no image for it, find it by its label
	If Not ClickButtonByText("Hero Hall") Then
		SetLog("Cannot find Heroes button on Hero Hall", $COLOR_ERROR)
		Return False
	EndIf
	For $i = 1 To 5
		If _Sleep(500) Then Return False
		If UBound(HeroHallReadCards()) >= 2 Then Return True
	Next
	SetLog("Hero Hall window not opened", $COLOR_ERROR)
	Return False
EndFunc   ;==>OpenHeroHallWindow

; OCR hero names on visible cards. Return [n][3] = [hero index (Hero Hall order), card x, name y]
Func HeroHallReadCards()
	Local $aRet[0][3]
	Local $aNames = OcrNamesInBand(30, 230, 830, 258)
	For $i = 0 To UBound($aNames) - 1
		Local $sName = OcrMatchName($aNames[$i][0], $g_asHeroHallNames)
		If @extended = 0 Then ContinueLoop
		Local $iHero = _ArraySearch($g_asHeroHallNames, $sName)
		If $iHero < 0 Then ContinueLoop
		Local $aAdd[1][3] = [[$iHero, $aNames[$i][1], $aNames[$i][2]]]
		_ArrayAdd($aRet, $aAdd)
	Next
	Return $aRet
EndFunc   ;==>HeroHallReadCards

; find card of $iHero, scroll right/left when needed. Return [x, name y] or 0
Func HeroHallFindCard($iHero, ByRef $iPage)
	For $iTry = 1 To 2
		Local $aCards = HeroHallReadCards()
		For $i = 0 To UBound($aCards) - 1
			If $aCards[$i][0] = $iHero Then
				Local $aRet[2] = [$aCards[$i][1], $aCards[$i][2]]
				Return $aRet
			EndIf
		Next
		; 5 cards visible: Dragon Duke (and next heroes) need scroll right
		If $iPage = 1 Then
			ClickDrag(700, 330, 200, 330, 300)
			$iPage = 2
		Else
			ClickDrag(200, 330, 700, 330, 300)
			$iPage = 1
		EndIf
		If _Sleep(1000) Then Return 0
	Next
	Return 0
EndFunc   ;==>HeroHallFindCard

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
