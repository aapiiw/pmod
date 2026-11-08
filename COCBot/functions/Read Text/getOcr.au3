; #FUNCTION# ====================================================================================================================
; Name ..........: OCR
; Description ...: Gets complete value of gold/Elixir/DarkElixir/Trophy/Gem xxx,xxx
; Author ........: Didipe (2015)
; Modified ......: ProMac (2015), Hervidero (2015-12), MMHK (2016-12), MR.ViPER (2017-4)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; name and level of the selected building, label above the button row (y 480).
; Area 480 / 26 high (Nov 2026, 26 adb frames of 10 buildings): 25 read right, 0 wrong. Old 477 / 27: 3 empty, a bouncing
; resource bubble above the label reaches into the top. 480 / 22 (upstream): 7 wrong, cuts g / p ("Gold Stora 1e")
Func getNameBuilding($x_start, $y_start)
	Return getOcrAndCapture("coc-build", $x_start, $y_start, 420, 26)
EndFunc   ;==>getNameBuilding

; loot of the searched base / of the battle, top left (gold 45,70 elixir 45,99 DE 45,127). Own glyphs first, template after
Func getGoldVillageSearch($x_start, $y_start)
	Local $sGlyph = ReadSearchLoot($x_start + 2, $y_start - 3, "g")
	If $sGlyph <> "" Then Return $sGlyph
	Return getOcrAndCapture("coc-v-g", $x_start, $y_start, 90, 21, True)
EndFunc   ;==>getGoldVillageSearch

; digits of the search / battle loot ($sKind "g" cream gold, "e" pink elixir, "d" white DE) read with $g_aiSearchLootGlyph.
; The base is behind the text: only the text band (9-14 rows with text pixels) is kept, glyphs left to right until a gap
; > 14 px. Return the digits ("" = not a clean number, the template OCR is used)
Func ReadSearchLoot($iX, $iY, $sKind)
	Local Const $iW = 125, $iH = 20
	_CaptureRegion2($iX, $iY, $iX + $iW, $iY + $iH)
	Local $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	If @error Or $hBmp = 0 Then Return ""
	Local $tData = _GDIPlus_BitmapLockBits($hBmp, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iStridePx = DllStructGetData($tData, "Stride") / 4
	Local $tPix = DllStructCreate("uint[" & $iStridePx * $iH & "]", DllStructGetData($tData, "Scan0"))
	Local $aM[$iH][$iW], $aiRow[$iH], $iPix, $r, $g, $b, $bText
	For $y = 0 To $iH - 1
		For $x = 0 To $iW - 1
			$iPix = DllStructGetData($tPix, 1, $y * $iStridePx + $x + 1)
			$r = BitAND(BitShift($iPix, 16), 0xFF)
			$g = BitAND(BitShift($iPix, 8), 0xFF)
			$b = BitAND($iPix, 0xFF)
			Switch $sKind ; text colors measured on 131 search screenshots (Nov 2026)
				Case "g"
					$bText = $r > 228 And $g > 228 And $b >= 165 And $b <= 228
				Case "e"
					$bText = $r > 228 And $g >= 200 And $g <= 242 And $b > 228
				Case Else
					$bText = $r > 222 And $g > 222 And $b > 222
			EndSwitch
			$aM[$y][$x] = $bText ? 1 : 0
			If $bText Then $aiRow[$y] += 1
		Next
	Next
	_GDIPlus_BitmapUnlockBits($hBmp, $tData)
	_GDIPlus_BitmapDispose($hBmp)
	Local $iBandT = -1, $iBandB = -1, $y = 0
	While $y < $iH
		If $aiRow[$y] < 2 Then
			$y += 1
			ContinueLoop
		EndIf
		Local $iT = $y
		While $y < $iH And $aiRow[$y] >= 2
			$y += 1
		WEnd
		If $y - $iT >= 9 And $y - $iT <= 14 Then
			$iBandT = $iT
			$iBandB = $y - 1
			ExitLoop
		EndIf
	WEnd
	If $iBandT < 0 Then Return ""
	Local $abCol[$iW]
	For $x = 0 To $iW - 1
		For $y = $iBandT To $iBandB
			If $aM[$y][$x] Then
				$abCol[$x] = True
				ExitLoop
			EndIf
		Next
	Next
	Local $sText = "", $x = 0, $iS, $iTop, $iBot, $iLastE = -1, $sChar
	While $x < $iW
		If Not $abCol[$x] Then
			$x += 1
			ContinueLoop
		EndIf
		$iS = $x
		While $x < $iW And $abCol[$x]
			$x += 1
		WEnd
		$iTop = -1
		$iBot = -1
		For $y = $iBandT To $iBandB
			For $c = $iS To $x - 1
				If $aM[$y][$c] Then
					If $iTop < 0 Then $iTop = $y
					$iBot = $y
					ExitLoop
				EndIf
			Next
		Next
		If $iBot - $iTop + 1 < 7 Then ContinueLoop
		If $iLastE >= 0 And $iS - $iLastE > 14 Then ExitLoop
		$sChar = BuildMenuGlyphMatch($aM, $iS, $x, $iTop, $iBot, $g_aiSearchLootGlyph)
		If @extended > 24 Then Return ""
		If $iLastE >= 0 And $iS - $iLastE >= 5 Then $sText &= " "
		$sText &= $sChar
		$iLastE = $x
	WEnd
	If Not StringRegExp($sText, "^[1-9]\d{0,2}( \d{3})*$") Then Return ""
	Return StringReplace($sText, " ", "")
EndFunc   ;==>ReadSearchLoot

; NOTE: $bNeedCapture params below are kept for caller compatibility only. OCR always captures its own region,
; because a forced OCR capture replaces $g_hHBitmap2 with a small region and reusing it would crop wrong coordinates.
Func getRemainTrainTimer($x_start, $y_start, $bNeedCapture = True) ;
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 70, 13, True)
EndFunc   ;==>getRemainTrainTimer

Func getRemainBuildTimer($x_start, $y_start, $bNeedCapture = True) ;
	Return getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 50, 10, True)
EndFunc   ;==>getRemainTrainTimer

Func getElixirVillageSearch($x_start, $y_start)
	Local $sGlyph = ReadSearchLoot($x_start + 2, $y_start - 3, "e")
	If $sGlyph <> "" Then Return $sGlyph
	Return getOcrAndCapture("coc-v-e", $x_start, $y_start, 90, 21, True)
EndFunc   ;==>getElixirVillageSearch

Func getDarkElixirVillageSearch($x_start, $y_start)
	Local $sGlyph = ReadSearchLoot($x_start + 2, $y_start - 3, "d")
	If $sGlyph <> "" Then Return $sGlyph
	Return getOcrAndCapture("coc-v-de", $x_start, $y_start, 75, 21, True)
EndFunc   ;==>getDarkElixirVillageSearch

Func getTrophyVillageSearch($x_start, $y_start) ;48, 69+99 or 69+69 -> Gets complete value of Trophies xxx,xxx , top left, Getresources.au3
	Return getOcrAndCapture("coc-v-t", $x_start, $y_start, 75, 21, True)
EndFunc   ;==>getTrophyVillageSearch

Func getTrophyMainScreen($x_start, $y_start) ; -> Gets trophy value, top left of main screen "VillageReport.au3"
	Return StringReplace(getOcrAndCapture("coc-ms", $x_start, $y_start, 50, 16, True), "-", "")
EndFunc   ;==>getTrophyMainScreen

; Gold / Elixir / Dark Elixir / Gems of the main screen and the Build menu, digits only.
; Own glyphs first (Nov 2026, 375 fields of 6 accounts: 374 right; template "coc-ms" 336, mostly empty reads), template after
Func getResourcesMainScreen($x_start, $y_start)
	Local $sGlyph = ReadWhiteNumber($x_start, $y_start - 2, 125, 20)
	If StringRegExp($sGlyph, "^\d{1,3}( \d{3})*$") Then Return StringReplace($sGlyph, " ", "")
	Return StringReplace(getOcrAndCapture("coc-ms", $x_start, $y_start, 125, 16, True), "-", "")
EndFunc   ;==>getResourcesMainScreen

; pure white digits with black outline (resources, gems, "free/total" counters) read with $g_aiWhiteNumGlyph, right to left
; until a gap > 14 px. Return the text with a space for gaps of 5+ px ("26 000 000", "1/7"), "" when a glyph is far from
; every template. Only white > 248: the Build menu shows the village through the resource bars (light pixels were read)
Func ReadWhiteNumber($iX, $iY, $iW, $iH, $iCutGap = 0)
	_CaptureRegion2($iX, $iY, $iX + $iW, $iY + $iH)
	Local $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	If @error Or $hBmp = 0 Then Return ""
	Local $tData = _GDIPlus_BitmapLockBits($hBmp, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iStridePx = DllStructGetData($tData, "Stride") / 4
	Local $tPix = DllStructCreate("uint[" & $iStridePx * $iH & "]", DllStructGetData($tData, "Scan0"))
	Local $aM[$iH][$iW], $abCol[$iW], $iPix
	For $y = 0 To $iH - 1
		For $x = 0 To $iW - 1
			$iPix = DllStructGetData($tPix, 1, $y * $iStridePx + $x + 1)
			If BitAND(BitShift($iPix, 16), 0xFF) > 248 And BitAND(BitShift($iPix, 8), 0xFF) > 248 And BitAND($iPix, 0xFF) > 248 Then
				$aM[$y][$x] = 1
				$abCol[$x] = True
			Else
				$aM[$y][$x] = 0
			EndIf
		Next
	Next
	_GDIPlus_BitmapUnlockBits($hBmp, $tData)
	_GDIPlus_BitmapDispose($hBmp)
	; $iCutGap: keep only the first text group from the left (attack bar "x12": the white slot border is 8+ px after it)
	If $iCutGap > 0 Then
		Local $iLastCol = -1
		For $x = 0 To $iW - 1
			If Not $abCol[$x] Then ContinueLoop
			If $iLastCol >= 0 And $x - $iLastCol - 1 > $iCutGap Then
				For $k = $x To $iW - 1
					$abCol[$k] = False
				Next
				ExitLoop
			EndIf
			$iLastCol = $x
		Next
	EndIf
	Local $sText = "", $x = $iW - 1, $iEnd, $iTop, $iBot, $iLastS = -1, $sChar
	While $x >= 0
		If Not $abCol[$x] Then
			$x -= 1
			ContinueLoop
		EndIf
		$iEnd = $x + 1
		While $x >= 0 And $abCol[$x]
			$x -= 1
		WEnd
		If $iLastS >= 0 And $iLastS - $iEnd > 14 Then ExitLoop
		$iTop = -1
		$iBot = -1
		For $y = 0 To $iH - 1
			For $c = $x + 1 To $iEnd - 1
				If $aM[$y][$c] Then
					If $iTop < 0 Then $iTop = $y
					$iBot = $y
					ExitLoop
				EndIf
			Next
		Next
		If $iBot - $iTop + 1 < 6 Then ContinueLoop
		$sChar = BuildMenuGlyphMatch($aM, $x + 1, $iEnd, $iTop, $iBot, $g_aiWhiteNumGlyph)
		If @extended > 24 Then Return ""
		If $iLastS >= 0 And $iLastS - $iEnd >= 5 Then $sChar &= " "
		$sText = $sChar & $sText
		$iLastS = $x + 1
	WEnd
	Return $sText
EndFunc   ;==>ReadWhiteNumber

Func getTrophyBB($x_start = 70, $y_start = 135) ; -> Gets trophy value BB
	Return StringReplace(getOcrAndCapture("coc-freemagicitems", $x_start, $y_start, 50, 16, True), "-", "")
EndFunc   ;==>getTrophyMainScreen

Func getResourcesLoot($x_start, $y_start) ; -> Gets complete value of Gold/Elixir after attack xxx,xxx "AttackReport"
	Return getOcrAndCapture("coc-loot", $x_start, $y_start, 160, 22, True)
EndFunc   ;==>getResourcesLoot

;HArchH Needs to be a bit longer.  Was 75, trying 85
; ranked battle result loot (bigger font than coc-loot), Tesseract digits, "" when not a number
Func getResourcesLootTs($x_start, $y_start, $iWidth)
	Local $s = getOcrAndCapture("coc-loot-ts", $x_start, $y_start, $iWidth, 24, True)
	Return StringRegExp($s, "^\d{1,9}$") ? $s : ""
EndFunc   ;==>getResourcesLootTs

Func getResourcesLootDE($x_start, $y_start) ; -> Gets complete value of Dark Elixir after attack xxx,xxx "AttackReport"
	Return getOcrAndCapture("coc-loot", $x_start, $y_start, 85, 22, True)
EndFunc   ;==>getResourcesLootDE

Func getResourcesLootT($x_start, $y_start) ; -> Gets complete value of Trophies after attack. xxx,xxx "AttackReport"
	Return getOcrAndCapture("coc-loot", $x_start, $y_start, 37, 22, True)
EndFunc   ;==>getResourcesLootT

Func getResourcesBonus($x_start, $y_start) ; -> Gets complete value of Gold/Elixir bonus loot in "AttackReport.au3"
	Return getOcrAndCapture("coc-bonus", $x_start, $y_start, 115, 20, True)
EndFunc   ;==>getResourcesBonus

Func getResourcesBonusPerc($x_start, $y_start) ; -> Gets complete value of Bonus % in "AttackReport.au3"
	Return getOcrAndCapture("coc-bonus", $x_start, $y_start, 48, 16, True)
EndFunc   ;==>getResourcesBonusPerc

Func getHeroUpgradeTime($x_start, $y_start) ; -> Gets complete upgrade time for heroes 464, 527
	Return StringReplace(getOcrAndCapture("coc-uptime2", $x_start, $y_start, 78, 20), "-", "") ; 78 is required to days & hours for young hero
EndFunc   ;==>getHeroUpgradeTime

Func getChatString($x_start, $y_start, $language) ; -> Get string chat request - Latin Alphabetic - EN "DonateCC.au3"
	Return getOcrAndCapture($language, $x_start, $y_start, 310, 17)
EndFunc   ;==>getChatString

; "free#total" counter of the main screen (builders at 753,545, lab at 802,545). Own glyphs first, template after
Func getBuilders($x_start, $y_start)
	Local $sGlyph = ReadWhiteNumber($x_start - 8, $y_start - 5, 50, 22)
	If StringRegExp($sGlyph, "^\d/\d$") Then Return StringReplace($sGlyph, "/", "#")
	Return getOcrAndCapture("coc-Builders", $x_start, $y_start, 40, 16, True)
EndFunc   ;==>getBuilders

Func getBuildersOnMenu($x_start = 528, $y_start = 639) ;  -> Gets Builders number - on Builder menu
	Return getOcrAndCapture("coc-totalreq", $x_start, $y_start, 35, 14, True)
EndFunc   ;==>getBuildersOnMenu

; troop amount "x12" on the attack bar, $x_start = middle of the "x". Own glyphs first (Nov 2026, 127 counts of 26 battles:
; template 113, glyphs 127; the template missed "x1" / "x2" of spells with an event label, the amount then was 1)
Func getTroopCount($x_start, $y_start, $width = 50, $height = 22)
	Local $iX = $x_start - 12, $sGlyph = ReadWhiteNumber($iX, $y_start + 2, _Min(56, 860 - $iX), 18, 4)
	If StringRegExp($sGlyph, "^x\d{1,3}$") Then Return StringTrimLeft($sGlyph, 1)
	Return StringReplace(getOcrAndCapture("coc-troopcount", $x_start, $y_start, $width, $height, True), "-", "")
EndFunc   ;==>getTroopCountSmall

Func getTroopsSpellsLevel($x_start, $y_start) ;  -> Gets spell level on Attack Screen for selected spell kind (could be used for troops too)
	Return getOcrAndCapture("coc-spellslevel", $x_start, $y_start, 30, 18, True)
EndFunc   ;==>getTroopsSpellsLevel

Func getArmyCampCap($x_start, $y_start, $bNeedCapture = True) ;  -> Gets army camp capacity on Army Tab (Troops:xx/xx)
	Return StringReplace(getOcrAndCapture("coc-armycap", $x_start, $y_start, 70, 14, True), "-", "")
EndFunc   ;==>getArmyCampCap

Func getArmySiegeCap($x_start, $y_start, $bNeedCapture = True) ;  -> Gets army camp capacity --> train.au3, and used to read CC request time remaining
	Return StringReplace(getOcrAndCapture("coc-armycap", $x_start, $y_start, 46, 17, True), "-", "")
EndFunc   ;==>getArmySiegeCap

Func getCastleDonateCap($x_start, $y_start, $x1 = 35) ;  -> Gets clan castle capacity,  --> donatecc.au3
	Return getOcrAndCapture("coc-army", $x_start, $y_start, $x1, 14, True)
EndFunc   ;==>getCastleDonateCap

Func getBarracksNewTroopQuantity($x_start, $y_start, $bNeedCapture = True) ;  -> Gets quantity of troops in army Window (slot)
	Return StringReplace(getOcrAndCapture("coc-newarmy", $x_start, $y_start, 55, 18, True), "-", "")
EndFunc   ;==>getBarracksNewTroopQuantity

Func getArmyCapacityOnTrainTroops($x_start, $y_start, $x1 = 63) ;  -> Gets quantity of troops in army Window
	Return StringRegExpReplace(getOcrAndCapture("coc-troopcap", $x_start, $y_start, $x1, 14, True), "[-x]", "")
EndFunc   ;==>getArmyCapacityOnTrainTroops

Func getArmyCapacityOnTrainTroops240($x_start, $y_start, $x1 = 63) ;  -> Gets quantity of troops in army Window
	Return StringRegExpReplace(getOcrAndCapture("coc-troopcap240", $x_start, $y_start, $x1, 14, True), "[-x]", "")
EndFunc   ;==>getArmyCapacityOnTrainTroops

Func getRequestCCCapacity($x_start = 250, $y_start = 148, $width = 90, $height = 22)
	Return StringReplace(getOcrAndCapture("coc-ccgold", $x_start, $y_start, $width, $height, True), "-", "")
EndFunc

Func getMatchRemain($x_start = 395, $y_start = 475) ; Gets complete Tournament Match Remain / Max
	Local $sRet = "", $aRet[0]
	$sRet = getOcrAndCapture("coc-tournament", $x_start, $y_start, 70, 22)
	If $sRet <> "" Then
		$aRet = StringSplit($sRet, "#", $STR_NOCOUNT)
	EndIf
	Return $aRet
EndFunc   ;==>getMatchRemain

Func TestAllOCR($xStart = 0, $yStart = 0, $ilength = 200, $iheight = 50)
	If $xStart = 0 And $yStart = 0 Then
		SetLog("Please set xStart and yStart", $COLOR_DEBUG2)
		Return
	EndIf
	Local $aOCRFile = _FileListToArray(@ScriptDir & "\lib\", "listSymbols_coc-*.xml", $FLTA_FILES)
	If IsArray($aOCRFile) And $aOCRFile[0] > 0 Then
		Local $ocrname = "", $ocrResult = ""
		For $i = 1 To Ubound($aOCRFile)
			$ocrname = StringReplace(StringReplace($aOCRFile[$i], "listSymbols_", ""), ".xml", "")
			SetLog("checking ocrname : " & $ocrname, $COLOR_INFO)
			$ocrResult = getOcrAndCapture($ocrname, $xStart, $yStart, $ilength, $iheight)
			SetLog("Result : " & $ocrResult, $COLOR_DEBUG2)
		Next
	EndIf
EndFunc

Func TestOCRTroopCap($iStart = 0, $iCount = 10, $path = "D:\OCRTool\TestImages\DebugOCR\", $iSleep = 800)
	
	Local $sRet = "", $sRet1 = "", $sRet2 = "", $aRet, $s1 = ""
	If Not OpenTroopsTab() Then Return
	For $i = $iStart To $iCount
		If Not $g_bRunState Then Return
		$aRet = GetCurrentTroop()
		$sRet = $aRet[0]
		$sRet1 = $aRet[3]
		$sRet2 = StringRegExpReplace(getOcrAndCapture("coc-troopcap", 96, 165, 63, 14)," \d+", "")
		
		SetLog($sRet & "/" & $sRet1 & " = " & $sRet2)
		_CaptureRegion2(96, 165, 96 + 63, 165 + 14)
		SaveDebugImageOCR($i & "_" & $sRet, $path)
		
		If $i = $iCount Then ExitLoop
		Click(122, 394)
		If Not $g_bRunState Then Return
		If _Sleep($iSleep) Then Return
	Next
EndFunc

Func getArmyCapacityOnTrainSpell($x_start, $y_start, $x1 = 40) ;  -> Gets quantity of spell in army Window
	Return StringRegExpReplace(getOcrAndCapture("coc-spellcap", $x_start, $y_start, $x1, 13, True), "[-x]", "")
EndFunc   ;==>getArmyCapacityOnTrainSpell

Func getQueueTroopsQuantity($x_start, $y_start) ;  -> Gets quantity of troops in Queue in Train Tab
	Return StringReplace(getOcrAndCapture("coc-qqtroop", $x_start, $y_start, 58, 15, True), "-", "")
EndFunc   ;==>getQueueTroopsQuantity

Func getOcrSpaceCastleDonate($x_start, $y_start) ;  -> Get the number of troops donated/capacity from a request
	Return getOcrAndCapture("coc-totalreq", $x_start, $y_start, 50, 13, True)
EndFunc   ;==>getOcrSpaceCastleDonate

; overall damage "58%" of the battle. Own glyphs first (Nov 2026, 120 battle screenshots: template empty on 12 shown
; values, glyphs read 10 of them; digits that touch are refused and the template reads them)
Func getOcrOverAllDamage($x_start, $y_start)
	Local $sGlyph = ReadWhiteNumber($x_start, $y_start, 66, 25)
	If StringRegExp($sGlyph, "^\d{1,3}%$") Then Return StringTrimRight($sGlyph, 1)
	Return getOcrAndCapture("coc-overalldamage", $x_start, $y_start, 55, 25, True)
EndFunc   ;==>getOcrOverAllDamage

Func getOcrGuardShield($x_start, $y_start) ;  -> Get the guard/shield time left, middle top of the screen
	Return getOcrAndCapture("coc-guardshield", $x_start, $y_start, 68, 15)
EndFunc   ;==>getOcrGuardShield

Func getOcrPBTtime($x_start, $y_start) ;  -> Get the Time until PBT starts from PBT info window
	Return getOcrAndCapture("coc-pbttime", $x_start, $y_start, 80, 15)
EndFunc   ;==>getOcrPBTtime

Func getBuilderLeastUpgradeTime($x_start, $y_start) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-buildermenu-cost", $x_start, $y_start, 100, 18, True)
EndFunc   ;==>getBuilderLeastUpgradeTime

Func getBuilderMenuCost($x_start, $y_start) ;  -> Get least upgradetime on builder menu
	Return getOcrAndCapture("coc-buildermenu-cost", $x_start, $y_start, 120, 18, True)
EndFunc   ;==>getBuilderBuilderMenuCost

Func getBuildingName($x_start, $y_start, $length = 180, $height = 25) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = StringReplace(getOcrAndCapture("coc-buildermenu-name", $x_start, $y_start, $length, $height, False), "-", "")
	If StringRegExp($Name, "x\d{1,}") Then
		Local $aCount = StringRegExp($Name, "\d{1,}", 1) ;check if we found count of building
		If IsArray($aCount) Then $Count = $aCount[0]
	EndIf
	
	If StringLeft($Name, 2) = "l " Then 
		$BuildingName = StringTrimLeft($Name, 2) ;remove first "l" because sometimes buildermenu border captured as "l"
	Else
		$BuildingName = $Name
	EndIf
	ReplaceQuantityX($BuildingName)
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

Func ReplaceQuantityX(ByRef $UpgradeName)
	If StringRegExp($UpgradeName, "x\d{1,}") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( x\d{1,})", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	If StringRegExp($UpgradeName, " x") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( x)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " l.+") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( l.+)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " l") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( l)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " \d+") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( \d+)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " \d+.+") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( \d+.+)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " \'") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( \')", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " T$") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( T$)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, " 1$") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "( 1$)", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	If StringRegExp($UpgradeName, "^' ") = 1 Then
		Local $aReplace = StringRegExp($UpgradeName, "(^' )", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($UpgradeName, $aReplace[0], "")
			$UpgradeName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	
EndFunc

Func getCCBuildingName($x_start, $y_start) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = getOcrAndCapture("coc-ccbuildermenu-name", $x_start, $y_start, 200, 25, False)
	If StringRegExp($Name, "x\d{1,}") Then
		Local $aCount = StringRegExp($Name, "\d{1,}", 1) ;check if we found count of building
		If IsArray($aCount) Then $Count = $aCount[0]
	EndIf
	
	If StringLeft($Name, 2) = "l " Then 
		$BuildingName = StringTrimLeft($Name, 2) ;remove first "l" because sometimes buildermenu border captured as "l"
	Else
		$BuildingName = $Name
	EndIf
	
	If StringRegExp($BuildingName, "x\d{1,}") Then
		Local $aReplace = StringRegExp($BuildingName, "( x\d{1,})", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($BuildingName, $aReplace[0], "")
			$BuildingName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

Func getCCBuildingNameBlue($x_start, $y_start) ;  -> Get BuildingName on builder menu
	Local $BuildingName = "", $Count = 1
	Local $Name = getOcrAndCapture("coc-ccbuildermenu-nameblue", $x_start, $y_start, 200, 25, False)
	If StringRegExp($Name, "x\d{1,}") Then
		Local $aCount = StringRegExp($Name, "\d{1,}", 1) ;check if we found count of building
		If IsArray($aCount) Then $Count = $aCount[0]
	EndIf
	
	If StringLeft($Name, 2) = "l " Then 
		$BuildingName = StringTrimLeft($Name, 2) ;remove first "l" because sometimes buildermenu border captured as "l"
	Else
		$BuildingName = $Name
	EndIf
	
	If StringRegExp($BuildingName, "x\d{1,}") Then
		Local $aReplace = StringRegExp($BuildingName, "( x\d{1,})", 1)
		If Ubound($aReplace) > 0 Then 
			Local $TmpBuildingName = StringReplace($BuildingName, $aReplace[0], "")
			$BuildingName = StringStripWS($TmpBuildingName, $STR_STRIPTRAILING)
		EndIf
	EndIf
	
	Local $aResult[2]
	$aResult[0] = $BuildingName
	$aResult[1] = Number($Count)
	Return $aResult
EndFunc   ;==>getBuildingName

Func getOcrReloadMessage($x_start, $y_start, $sLogText = Default, $LogTextColor = Default, $bSilentSetLog = Default)
	Local $result = getOcrAndCapture("coc-reloadmsg", $x_start, $y_start, 116, 19, True)
	Local $String = ""
	If $sLogText = Default Then
		$String = "getOcrReloadMessage: " & $result
	Else
		$String = $sLogText & " " & $result
	EndIf
	If $g_bDebugSetlog Then ; if enabled generate debug log message
		SetDebugLog($String, $LogTextColor, $bSilentSetLog)
	ElseIf $result <> "" Then ;
		SetDebugLog($String, $LogTextColor, True) ; if result found, add to log file
	EndIf
	Return $result
EndFunc   ;==>getOcrReloadMessage

Func getOcrMaintenanceTime($x_start, $y_start)
	Local $result = getOcrAndCapture("coc-RemainTrain", $x_start, $y_start, 20, 12, True)
	If Number($result) > 0 Then 
		$result = $result & "m"
	Else
		$result = "soon"
	EndIf
	
	Return $result
EndFunc   ;==>getOcrMaintenanceTime

Func getOcrTimeGameTime($x_start, $y_start) ;  -> Get the guard/shield time left, middle top of the screen
	Return StringReplace(getOcrAndCapture("coc-clangames", $x_start, $y_start, 116, 31, True), "-", "")
EndFunc   ;==>getOcrTimeGameTime

Func getOcrYourCGScore($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return StringReplace(getOcrAndCapture("coc-cgscores", $x_start, $y_start, 140, 18, True), "-", "")
EndFunc   ;==>getOcrYourScore

Func getOcrEventTime($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCapture("coc-cgevents", $x_start, $y_start, 60, 20, True)
EndFunc   ;==>getOcrEventTime

Func getRemainTHero($x_start, $y_start, $bNeedCapture = True) ; Get time remaining for hero to be ready for attack from train window, BK:443,504 AQ:504,504 GW:565:504
	Return getOcrAndCapture("coc-remainhero", $x_start, $y_start, 55, 12, True)
EndFunc   ;==>getRemainTHero

Func getRequestRemainTime($x_start, $y_start, $bNeedCapture = True) ; Get Remain Time To request Troops
	Return getOcrAndCapture("coc-CCremainTime", $x_start, $y_start, 30, 14, False)
EndFunc   ;==>getRequestRemainTime

Func OcrForceCaptureRegion($bForce = Default)
	If $bForce = Default Then Return $g_bOcrForceCaptureRegion
	Local $wasForce = $g_bOcrForceCaptureRegion
	$g_bOcrForceCaptureRegion = $bForce
	Return $wasForce
EndFunc   ;==>OcrForceCaptureRegion

Func getOcrAndCapture($language, $x_start, $y_start, $width, $height, $removeSpace = Default, $bImgLoc = Default, $bForceCaptureRegion = Default)
	If $removeSpace = Default Then $removeSpace = False
	If $bImgLoc = Default Then $bImgLoc = False
	If $bForceCaptureRegion = Default Then $bForceCaptureRegion = $g_bOcrForceCaptureRegion
	Static $_hHBitmap = 0
	
	Local $result
	
	If $bForceCaptureRegion = True Then
		_CaptureRegion2($x_start, $y_start, $x_start + $width, $y_start + $height)
	Else
		$_hHBitmap = GetHHBitmapArea($g_hHBitmap2, $x_start, $y_start, $x_start + $width, $y_start + $height)
	EndIf
	If $bImgLoc Then
		If $_hHBitmap <> 0 Then
			$result = getOcrImgLoc($_hHBitmap, $language)
		Else
			$result = getOcrImgLoc($g_hHBitmap2, $language)
		EndIf
	Else
		If $_hHBitmap <> 0 Then
			$result = getOcr($_hHBitmap, $language)
		Else
			$result = getOcr($g_hHBitmap2, $language)
		EndIf
	EndIf
	If $_hHBitmap <> 0 Then
		GdiDeleteHBitmap($_hHBitmap)
	EndIf
	$_hHBitmap = 0
	If ($removeSpace) Then
		$result = StringReplace($result, " ", "")
	Else
		$result = StringStripWS($result, BitOR($STR_STRIPLEADING, $STR_STRIPTRAILING, $STR_STRIPSPACES))
	EndIf
	Return $result
EndFunc   ;==>getOcrAndCapture

Func getOcrImgLoc(ByRef Const $_hHBitmap, $sLanguage)
	Local $result = DllCallMyBot("DoOCR", "handle", $_hHBitmap, "str", $sLanguage)

	Local $error = @error ; Store error values as they reset at next function call
	Local $extError = @extended
	If $error Then
		_logErrorDLLCall($g_hLibMyBot, $error)
		SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		Return SetError(2, $extError, "") ; Set external error code = 2 for DLL error
	EndIf
	If $g_bDebugImageSave Then SaveDebugImage($sLanguage, False)

	If IsArray($result) Then
		Return $result[0]
	Else
		Return ""
	EndIf
EndFunc   ;==>getOcrImgLoc

#include <GDIPlus.au3>

Global Const $WM_OCR_TRIGGER = 0x0465
Global Const $OCR_SHM_SIZE   = 4194304
Global Const $OCR_SEND_TIMEOUT = 5000 ; ms, max wait for ocrworker answer
Global $g_hOcrMapFile        = 0
Global $g_pOcrSharedBuf      = 0
Global $g_iOcrWorkerPID      = 0

; whitelist for building / troop / spell names (Tesseract), must stay below 64 chars
Global Const $g_sOcrNameWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-'"

Func _GetOcrWorkerHWND()
	; Cari Window yang memiliki judul sesuai PID instance bot ini
	Local $sTitle = "MBR_OCR_Worker_" & @AutoItPID
	Local $aWnd = DllCall("user32.dll", "hwnd", "FindWindowW", "ptr", 0, "wstr", $sTitle)
	If IsArray($aWnd) And $aWnd[0] <> 0 Then Return $aWnd[0]
	Return 0
EndFunc   ;==>_GetOcrWorkerHWND

Func StartOcrWorkerClient()
	Static $bGdiStarted = False
	If Not $bGdiStarted Then
		_GDIPlus_Startup()
		$bGdiStarted = True
	EndIf

	; 1. Buka / Buat Shared Memory unik sesuai PID bot ini
	If $g_pOcrSharedBuf = 0 Then
		Local $sShmName = "MBR_OCR_SHM_" & @AutoItPID
		$g_hOcrMapFile = DllCall("kernel32.dll", "handle", "CreateFileMappingW", _
				"handle", -1, "ptr", 0, "dword", 0x04, "dword", 0, "dword", $OCR_SHM_SIZE, "wstr", $sShmName)[0]
		$g_pOcrSharedBuf = DllCall("kernel32.dll", "ptr", "MapViewOfFile", _
				"handle", $g_hOcrMapFile, "dword", 0xF001F, "dword", 0, "dword", 0, "ulong_ptr", $OCR_SHM_SIZE)[0]
	EndIf

	; 2. Jalankan ocrworker.exe dengan menyertakan PID instance ini sebagai parameter
	Local $sWorkerExe = @ScriptDir & "\lib\Tesseract\ocrworker.exe"
	Local $sWorkerDir = @ScriptDir & "\lib\Tesseract"

	Local $hWnd = _GetOcrWorkerHWND()
	If $hWnd = 0 Then
		If Not FileExists($sWorkerExe) Then
			SetDebugLog("StartOcrWorkerClient: " & $sWorkerExe & " not found", $COLOR_ERROR)
			Return 0
		EndIf
		; Contoh eksekusi: ocrworker.exe 4528
		$g_iOcrWorkerPID = Run('"' & $sWorkerExe & '" ' & @AutoItPID, $sWorkerDir, @SW_HIDE)
		For $i = 1 To 30
			Sleep(100)
			$hWnd = _GetOcrWorkerHWND()
			If $hWnd <> 0 Then ExitLoop
		Next
	EndIf
	If $hWnd <> 0 Then $g_iOcrWorkerPID = WinGetProcess($hWnd)
	Return $hWnd
EndFunc   ;==>StartOcrWorkerClient

Func StopOcrWorkerClient()
	If $g_iOcrWorkerPID > 0 And ProcessExists($g_iOcrWorkerPID) Then ProcessClose($g_iOcrWorkerPID)
	$g_iOcrWorkerPID = 0
EndFunc   ;==>StopOcrWorkerClient

; FUNGSI UTAMA (HYBRID)
; Tesseract hanya untuk teks nama (huruf). Angka tetap memakai OCR template MBR (lebih akurat untuk digit kecil).
Func getOcr(ByRef Const $_hHBitmap, $language)
	Local $sRet = ""

	Switch $language
		Case "coc-buildermenu-name"
			$sRet = OcrFromHBitmapDirect($_hHBitmap, $g_sOcrNameWhitelist, 7, $language, True)
			; PSM 7 returns '' for short names ("Miner", "Bowler" in the Lab list, adb test 27 Oct), PSM 13 reads them
			If StringStripWS($sRet, $STR_STRIPALL) = "" Then $sRet = OcrFromHBitmapDirect($_hHBitmap, $g_sOcrNameWhitelist, 13, $language, True)
			$sRet = StringRegExpReplace($sRet, "\s+", " ")
			; Koreksi otomatis huruf yang mirip pada font CoC
			$sRet = StringReplace($sRet, "Roval", "Royal")
			$sRet = StringReplace($sRet, "Elixik", "Elixir")
			Return StringStripWS($sRet, $STR_STRIPLEADING + $STR_STRIPTRAILING)

		Case "coc-loot-ts" ; ranked battle result loot
			Return OcrFromHBitmapDirect($_hHBitmap, "0123456789 ", 7, $language, True)

		Case "coc-buildcost" ; upgrade cost in Build menu, fallback when template font lost a digit
			; PSM 13 (raw line): PSM 7 returned '' for clean "60 000" / "10 000" (Lab DE costs, Oct 2026 screenshots)
			Return OcrFromHBitmapDirect($_hHBitmap, "0123456789 ", 13, $language, True)

		Case "coc-buildtime" ; upgrade time in Build menu ("2d 3h"), only partly readable: use BuildMenuTimeToMin() (lower bound)
			Return OcrFromHBitmapDirect($_hHBitmap, "0123456789dhmsDHMSlI ", 7, $language, True)

		Case "coc-magicitem-capa" ; small white "0/1" capacity on Trader items, no MBR template font matches it
			$sRet = OcrFromHBitmapDirect($_hHBitmap, "0123456789/", 7, $language, True)
			$sRet = StringRegExpReplace($sRet, "^(\d)7(\d)$", "$1/$2") ; slash is often read as 7
			Return StringReplace($sRet, "/", "#")

		Case Else
			Local $result = DllCallMyBot("ocr", "ptr", $_hHBitmap, "str", $language, "int", $g_bDebugOcr ? 1 : 0)
			If IsArray($result) Then Return $result[0]
			Return ""
	EndSwitch
EndFunc   ;==>getOcr

; Ubah teks putih CoC (outline gelap, background berwarna) menjadi teks hitam di atas putih,
; potong kolom setelah celah kosong lebar (mis. teks waktu "11d" di kanan), lalu upscale + padding.
; Return: GDI+ bitmap baru (harus di-dispose pemanggil) atau 0 jika gagal
Func _OcrPreprocessWhiteText($hBitmap, $iScale = 3, $iPad = 10, $iMinWhite = 200, $iMaxSpread = 60, $iMaxGap = 30)
	Local $iW = _GDIPlus_ImageGetWidth($hBitmap)
	Local $iH = _GDIPlus_ImageGetHeight($hBitmap)
	If $iW <= 0 Or $iH <= 0 Then Return 0

	Local $tSrcData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	If @error Then Return 0
	Local $iStridePx = DllStructGetData($tSrcData, "Stride") / 4
	Local $pScan0 = DllStructGetData($tSrcData, "Scan0")
	Local $tSrc = DllStructCreate("uint[" & $iStridePx * $iH & "]", $pScan0)
	Local $tMask = DllStructCreate("uint[" & $iW * $iH & "]")
	Local $abCol[$iW]
	Local $iPix, $r, $g, $b, $iMin, $iMax, $iRow, $iMaskRow

	For $y = 0 To $iH - 1
		$iRow = $y * $iStridePx
		$iMaskRow = $y * $iW
		For $x = 0 To $iW - 1
			$iPix = DllStructGetData($tSrc, 1, $iRow + $x + 1)
			$r = BitAND(BitShift($iPix, 16), 0xFF)
			$g = BitAND(BitShift($iPix, 8), 0xFF)
			$b = BitAND($iPix, 0xFF)
			$iMin = $r < $g ? $r : $g
			If $b < $iMin Then $iMin = $b
			$iMax = $r > $g ? $r : $g
			If $b > $iMax Then $iMax = $b
			If ($iMin > $iMinWhite And ($iMax - $iMin) < $iMaxSpread) Or ($g_bOcrGreenText And $g >= 190 And $r >= 130 And $g - $b >= 100) Then
				DllStructSetData($tMask, 1, 0xFF000000, $iMaskRow + $x + 1) ; text -> black
				$abCol[$x] = True
			Else
				DllStructSetData($tMask, 1, 0xFFFFFFFF, $iMaskRow + $x + 1) ; background -> white
			EndIf
		Next
	Next
	_GDIPlus_BitmapUnlockBits($hBitmap, $tSrcData)

	; cari celah kosong lebar setelah teks pertama, buang semua di kanannya
	Local $iCutW = $iW, $iLast = -1
	For $x = 0 To $iW - 1
		If $abCol[$x] Then
			If $iLast >= 0 And $x - $iLast > $iMaxGap Then
				$iCutW = $iLast + 1
				ExitLoop
			EndIf
			$iLast = $x
		EndIf
	Next

	Local $hMask = _GDIPlus_BitmapCreateFromScan0($iW, $iH, $GDIP_PXF32ARGB, $iW * 4, $tMask)
	If @error Or $hMask = 0 Then Return 0
	Local $hOut = _GDIPlus_BitmapCreateFromScan0($iCutW * $iScale + 2 * $iPad, $iH * $iScale + 2 * $iPad)
	If @error Or $hOut = 0 Then
		_GDIPlus_BitmapDispose($hMask)
		Return 0
	EndIf
	Local $hGfx = _GDIPlus_ImageGetGraphicsContext($hOut)
	_GDIPlus_GraphicsClear($hGfx, 0xFFFFFFFF)
	_GDIPlus_GraphicsSetInterpolationMode($hGfx, $GDIP_INTERPOLATIONMODE_HIGHQUALITYBILINEAR)
	_GDIPlus_GraphicsDrawImageRectRect($hGfx, $hMask, 0, 0, $iCutW, $iH, $iPad, $iPad, $iCutW * $iScale, $iH * $iScale)
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_BitmapDispose($hMask)
	Return $hOut
EndFunc   ;==>_OcrPreprocessWhiteText

; Cari semua teks putih (nama) dalam satu pita horizontal, OCR masing-masing.
; Dipakai untuk kartu Pet House / Hero Hall yang posisinya bergeser saat di-scroll.
; Return array [n][3] = [teks OCR, x tengah teks, y tengah teks] (koordinat layar); array kosong jika tidak ada teks.
Func OcrNamesInBand($x1, $y1, $x2, $y2, $iMinGap = 25, $iMinWidth = 10, $iMinWhite = 225)
	Local $aRet[0][3]
	Local $iW = $x2 - $x1, $iH = $y2 - $y1
	_CaptureRegion2($x1, $y1, $x2, $y2)
	Local $hBand = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	If @error Or $hBand = 0 Then Return $aRet

	; kolom yang berisi piksel putih
	Local $tData = _GDIPlus_BitmapLockBits($hBand, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iStridePx = DllStructGetData($tData, "Stride") / 4
	Local $tPix = DllStructCreate("uint[" & $iStridePx * $iH & "]", DllStructGetData($tData, "Scan0"))
	Local $abCol[$iW], $abWhite[$iW][$iH], $iPix, $r, $g, $b, $iMin, $iMax
	For $x = 0 To $iW - 1
		For $y = 0 To $iH - 1
			$iPix = DllStructGetData($tPix, 1, $y * $iStridePx + $x + 1)
			$r = BitAND(BitShift($iPix, 16), 0xFF)
			$g = BitAND(BitShift($iPix, 8), 0xFF)
			$b = BitAND($iPix, 0xFF)
			$iMin = $r < $g ? $r : $g
			If $b < $iMin Then $iMin = $b
			$iMax = $r > $g ? $r : $g
			If $b > $iMax Then $iMax = $b
			If $iMin > $iMinWhite And ($iMax - $iMin) < 60 Then
				$abCol[$x] = True
				$abWhite[$x][$y] = True
			EndIf
		Next
	Next
	_GDIPlus_BitmapUnlockBits($hBand, $tData)
	_GDIPlus_BitmapDispose($hBand)

	; kelompokkan kolom menjadi kata/nama, pisah jika celah > $iMinGap
	Local $aGroups[0][2], $iStart = -1, $iLast = -1
	For $x = 0 To $iW
		If $x < $iW And $abCol[$x] Then
			If $iStart = -1 Then
				$iStart = $x
			ElseIf $x - $iLast > $iMinGap Then
				If $iLast - $iStart + 1 >= $iMinWidth Then _ArrayAdd($aGroups, $iStart & "|" & $iLast)
				$iStart = $x
			EndIf
			$iLast = $x
		EndIf
	Next
	If $iStart <> -1 And $iLast - $iStart + 1 >= $iMinWidth Then _ArrayAdd($aGroups, $iStart & "|" & $iLast)

	; OCR tiap kelompok dari frame yang sama
	Local $iGx1, $iGx2, $hArea, $sText
	For $i = 0 To UBound($aGroups) - 1
		$iGx1 = Number($aGroups[$i][0]) - 4
		$iGx2 = Number($aGroups[$i][1]) + 5
		If $iGx1 < 0 Then $iGx1 = 0
		If $iGx2 > $iW Then $iGx2 = $iW
		$hArea = GetHHBitmapArea($g_hHBitmap2, $iGx1, 0, $iGx2, $iH)
		$sText = OcrFromHBitmapDirect($hArea, $g_sOcrNameWhitelist, 7, "band", True)
		GdiDeleteHBitmap($hArea)
		$sText = StringStripWS(StringRegExpReplace($sText, "\s+", " "), $STR_STRIPLEADING + $STR_STRIPTRAILING)
		If $sText = "" Then ContinueLoop
		; vertical center of the text of this group
		Local $iTop = $iH, $iBottom = -1
		For $x = Number($aGroups[$i][0]) To Number($aGroups[$i][1])
			For $y = 0 To $iH - 1
				If $abWhite[$x][$y] Then
					If $y < $iTop Then $iTop = $y
					If $y > $iBottom Then $iBottom = $y
				EndIf
			Next
		Next
		Local $aAdd[1][3] = [[$sText, $x1 + Int((Number($aGroups[$i][0]) + Number($aGroups[$i][1])) / 2), $y1 + Int(($iTop + $iBottom) / 2)]]
		_ArrayAdd($aRet, $aAdd)
	Next
	Return $aRet
EndFunc   ;==>OcrNamesInBand

Func OcrFromHBitmapDirect(ByRef Const $_hHBitmap, $sWhitelist = "", $iPSM = 7, $sTagName = "ocr", $bPreprocess = False)
	Local $hWorkerWnd = _GetOcrWorkerHWND()
	If $hWorkerWnd = 0 Or $g_pOcrSharedBuf = 0 Then
		$hWorkerWnd = StartOcrWorkerClient()
		If $hWorkerWnd = 0 Or $g_pOcrSharedBuf = 0 Then Return ""
	EndIf

	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($_hHBitmap)
	If @error Or $hBitmap = 0 Then Return ""

	If $bPreprocess Then
		Local $hPrep = _OcrPreprocessWhiteText($hBitmap)
		If $hPrep <> 0 Then
			_GDIPlus_BitmapDispose($hBitmap)
			$hBitmap = $hPrep
		EndIf
	EndIf

	; Simpan gambar debug jika opsi debug aktif
	If $g_bDebugOcrTS Then
		Local $sDebugDir = @ScriptDir & "\lib\debug\ocr"
		If Not FileExists($sDebugDir) Then DirCreate($sDebugDir)
		Local $sTime = @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & @SEC & "_" & @MSEC
		_GDIPlus_ImageSaveToFile($hBitmap, $sDebugDir & "\" & $sTagName & "_" & $sTime & ".png")
	EndIf

	Local $iW = _GDIPlus_ImageGetWidth($hBitmap)
	Local $iH = _GDIPlus_ImageGetHeight($hBitmap)
	Local $iPixelBytes = $iW * $iH * 4
	If ($iPixelBytes + 256) > $OCR_SHM_SIZE Then
		_GDIPlus_BitmapDispose($hBitmap)
		Return ""
	EndIf

	Local $tBitmapData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $iW, $iH, $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	If @error Then
		_GDIPlus_BitmapDispose($hBitmap)
		Return ""
	EndIf
	Local $pScan0 = DllStructGetData($tBitmapData, "Scan0")

	; Tulis Header
	Local $tHeader = DllStructCreate("int Width;int Height;int PSM;int SaveImg;int WriteLog;char Whitelist[64];char TagName[64]", $g_pOcrSharedBuf)
	DllStructSetData($tHeader, "Width", $iW)
	DllStructSetData($tHeader, "Height", $iH)
	DllStructSetData($tHeader, "PSM", $iPSM)
	DllStructSetData($tHeader, "SaveImg", 0)
	DllStructSetData($tHeader, "WriteLog", ($g_bDebugOcrTS ? 1 : 0))
	DllStructSetData($tHeader, "Whitelist", StringLeft($sWhitelist, 63))
	DllStructSetData($tHeader, "TagName", StringLeft($sTagName, 63))

	; Salin piksel
	DllCall("kernel32.dll", "none", "RtlMoveMemory", "ptr", $g_pOcrSharedBuf + 256, "ptr", $pScan0, "ulong_ptr", $iPixelBytes)

	_GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)
	_GDIPlus_BitmapDispose($hBitmap)

	; Kirim sinyal ke Worker, dengan timeout agar bot tidak ikut hang bila worker macet
	; SMTO_BLOCK (0x1) | SMTO_ABORTIFHUNG (0x2)
	Local $aSend = DllCall("user32.dll", "lresult", "SendMessageTimeoutW", "hwnd", $hWorkerWnd, "uint", $WM_OCR_TRIGGER, _
			"wparam", 0, "lparam", 0, "uint", 0x3, "uint", $OCR_SEND_TIMEOUT, "dword_ptr*", 0)
	If @error Or Not IsArray($aSend) Or $aSend[0] = 0 Then
		SetLog("OCR worker not responding, restarting it", $COLOR_ERROR)
		StopOcrWorkerClient()
		Return ""
	EndIf
	If $aSend[7] <> 1 Then Return "" ; worker menolak request (header invalid), buffer masih berisi header

	Local $tResult = DllStructCreate("char[1024]", $g_pOcrSharedBuf)
	Local $sText = StringStripWS(DllStructGetData($tResult, 1), $STR_STRIPLEADING + $STR_STRIPTRAILING)

	If $g_bDebugOcrTS Then SetDebugLog($sTagName & ": " & $sText)
	Return $sText
EndFunc   ;==>OcrFromHBitmapDirect

; Jarak edit minimum antara $aName dan awalan teks OCR dengan panjang (len-1 .. len+1).
; Satu matriks DP per nama: baris = huruf nama, kolom = huruf OCR, sehingga semua panjang awalan dihitung sekaligus.
; Input berupa array kode ASCII (StringToASCIIArray) agar cepat.
Func _OcrPrefixDistance(ByRef $aName, ByRef $aOcr)
	Local $iL = UBound($aName), $iK = UBound($aOcr)
	If $iK > $iL + 1 Then $iK = $iL + 1
	Local $aPrev[$iK + 1], $aCur[$iK + 1], $iCost, $c
	For $j = 0 To $iK
		$aPrev[$j] = $j
	Next
	For $i = 1 To $iL
		$aCur[0] = $i
		$c = $aName[$i - 1]
		For $j = 1 To $iK
			$iCost = ($aOcr[$j - 1] = $c) ? 0 : 1
			$aCur[$j] = $aPrev[$j] + 1
			If $aCur[$j - 1] + 1 < $aCur[$j] Then $aCur[$j] = $aCur[$j - 1] + 1
			If $aPrev[$j - 1] + $iCost < $aCur[$j] Then $aCur[$j] = $aPrev[$j - 1] + $iCost
		Next
		$aPrev = $aCur
	Next
	Local $iBest = 999
	For $k = $iL - 1 To $iL + 1
		If $k < 0 Or $k > $iK Then ContinueLoop
		If $aPrev[$k] < $iBest Then $iBest = $aPrev[$k]
	Next
	If $iBest = 999 Then $iBest = $aPrev[$iK] ; teks OCR lebih pendek dari nama
	Return $iBest
EndFunc   ;==>_OcrPrefixDistance

; Cocokkan hasil OCR nama dengan daftar nama yang dikenal ($aNames = array 1D).
; Membandingkan awalan teks OCR (abaikan sisa noise di belakang), huruf kecil tanpa spasi/simbol.
; Return nama dari daftar jika cocok (jarak <= $fMaxRatio x panjang nama), selain itu teks OCR aslinya (@extended = 0).
Func OcrMatchName($sOcr, $aNames, $fMaxRatio = 0.3)
	Local $sNorm = StringLower(StringRegExpReplace($sOcr, "[^A-Za-z0-9]", ""))
	$sNorm = StringReplace(StringReplace(StringReplace($sNorm, "0", "o"), "5", "s"), "1", "l")
	If StringLen($sNorm) < 3 Then Return SetExtended(0, $sOcr)
	Local $aOcr = StringToASCIIArray($sNorm)

	Local $fBest = 99, $iBest = -1, $fRatio, $aName
	For $i = 0 To UBound($aNames) - 1
		If $aNames[$i] = "" Then ContinueLoop
		$aName = StringToASCIIArray(StringLower(StringRegExpReplace($aNames[$i], "[^A-Za-z]", "")))
		If UBound($aName) = 0 Then ContinueLoop
		$fRatio = _OcrPrefixDistance($aName, $aOcr) / UBound($aName)
		; prefer the longer name on equal score ("Super Wizard Tower" vs "Wizard Tower" is decided by distance, "Golem" vs "Ice Golem" too)
		If $fRatio < $fBest Or ($fRatio = $fBest And $iBest >= 0 And StringLen($aNames[$i]) > StringLen($aNames[$iBest])) Then
			$fBest = $fRatio
			$iBest = $i
		EndIf
	Next
	If $iBest >= 0 And $fBest <= $fMaxRatio Then Return SetExtended(1, $aNames[$iBest])

	; fallback: start of text is garbled, compare the last word of each name with every OCR word
	; ("Hlimium P RiNCE" -> "Minion Prince", "Raval Crtampion" -> "Royal Champion")
	Local $aWords = StringRegExp(StringLower($sOcr), "[a-z]{3,}", $STR_REGEXPARRAYGLOBALMATCH)
	If Not IsArray($aWords) Then Return SetExtended(0, $sOcr)
	Local $aLast, $aWord, $iHits = 0
	$fBest = 99
	$iBest = -1
	For $i = 0 To UBound($aNames) - 1
		$aLast = StringRegExp(StringLower($aNames[$i]), "([a-z]+)[^a-z]*$", $STR_REGEXPARRAYMATCH)
		If Not IsArray($aLast) Or StringLen($aLast[0]) < 4 Then ContinueLoop
		$aName = StringToASCIIArray($aLast[0])
		For $w = 0 To UBound($aWords) - 1
			$aWord = StringToASCIIArray($aWords[$w])
			$fRatio = _OcrPrefixDistance($aName, $aWord) / UBound($aName)
			If $fRatio < $fBest Then
				$fBest = $fRatio
				$iBest = $i
				$iHits = 1
			ElseIf $fRatio = $fBest And $i <> $iBest Then
				$iHits += 1 ; same score for another name: ambiguous
			EndIf
		Next
	Next
	If $iBest >= 0 And $fBest <= 0.34 And $iHits = 1 Then Return SetExtended(1, $aNames[$iBest])
	Return SetExtended(0, $sOcr)
EndFunc   ;==>OcrMatchName

; Laboratory research names (troops, spells, sieges) as written in game
Func OcrMatchTroopName($sOcr, $fMaxRatio = 0.3)
	Static $aNames = 0
	If Not IsArray($aNames) Or $aNames[0] = "" Then
		Local $aTmp[$g_iLabAnySpell - 1]
		For $i = 1 To $g_iLabAnySpell - 1
			$aTmp[$i - 1] = $g_avLabTroops[$i][3]
		Next
		$aNames = $aTmp
	EndIf
	Local $sMatch = OcrMatchName($sOcr, $aNames, $fMaxRatio)
	Return SetExtended(@extended, $sMatch)
EndFunc   ;==>OcrMatchTroopName

; Home village building names as written in game (all names of $g_asUpgradeIgnore)
Func OcrMatchBuildingName($sOcr, $fMaxRatio = 0.3)
	Static $aNames = 0
	If Not IsArray($aNames) Then
		Local $sAll = ""
		For $i = 0 To UBound($g_asUpgradeIgnore) - 1
			$sAll &= ($sAll = "" ? "" : "|") & $g_asUpgradeIgnore[$i][1]
		Next
		$aNames = StringSplit($sAll, "|", $STR_NOCOUNT)
	EndIf
	Local $sMatch = OcrMatchName($sOcr, $aNames, $fMaxRatio)
	Return SetExtended(@extended, $sMatch)
EndFunc   ;==>OcrMatchBuildingName
