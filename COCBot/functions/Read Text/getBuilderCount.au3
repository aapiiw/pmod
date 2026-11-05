
Func getBuilderCount($bSuppressLog = False, $bBuilderBase = False)
	Local $bRet = False, $sBuilderInfo, $aGetBuilders
	If Not $g_bRunState Then Return
	SetDebugLog("getBuilderCount for " & ($bBuilderBase ? "BuilderBase" : "NormalBase"))
	
	; OCR can miss while screen is animating, retry with a fresh capture before giving up
	For $iTry = 1 To 3
		If $bBuilderBase Then
			$sBuilderInfo = getBuilders($aBuildersDigitsBuilderBase[0], $aBuildersDigitsBuilderBase[1]) ; get BB builder string with OCR
		Else
			$sBuilderInfo = getBuilders($aBuildersDigits[0], $aBuildersDigits[1]) ; get builder string with OCR
		EndIf
		If StringRegExp($sBuilderInfo, "^\d+#\d+$") Then ExitLoop
		If $iTry < 3 And _Sleep(300) Then Return
	Next
	
	If StringRegExp($sBuilderInfo, "^\d+#\d+$") Then ; check for valid OCR read
		$aGetBuilders = StringSplit($sBuilderInfo, "#", $STR_NOCOUNT) ; Split into free and total builder strings
		If $bBuilderBase Then
			$g_iFreeBuilderCountBB = Int($aGetBuilders[0]) ; update global values
			$g_iTotalBuilderCountBB = Int($aGetBuilders[1])
		Else
			$g_iFreeBuilderCount = Int($aGetBuilders[0]) ; update global values
			$g_iTotalBuilderCount = Int($aGetBuilders[1])
			GoblinBuilderAdjust($g_iFreeBuilderCount, $g_iTotalBuilderCount, "Main")
		EndIf
		$g_iGfxErrorCount = 0
		$bRet = True
	Else
		SetLog("Bad OCR read Free/Total Builders: '" & $sBuilderInfo & "'", $COLOR_ERROR) ; OCR returned unusable value?
		; only count as graphic error when the village screen is really visible (otherwise it is just a wrong screen, not a gfx glitch)
		If ($bBuilderBase ? isOnBuilderBase() : isOnMainVillage()) Then $g_iGfxErrorCount += 1
		If $g_iGfxErrorCount > $g_iGfxErrorMax Then 
			SetLog("gfxError occured, set to Reboot Android Instance", $COLOR_INFO)
			$g_bGfxError = True
			CheckAndroidReboot()
		EndIf
	EndIf
	
	If $bRet Then
		If $bBuilderBase Then 
			SetDebugLog("No. of Free/Total Builders: " & $g_iFreeBuilderCountBB & "/" & $g_iTotalBuilderCountBB)
		Else
			SetDebugLog("No. of Free/Total Builders: " & $g_iFreeBuilderCount & "/" & $g_iTotalBuilderCount)
		EndIf
	EndIf
	
	Return $bRet
EndFunc   ;==>getBuilderCount

; Goblin Builder (event, gems): never used. The counter shows the goblin (icon + goblin in free/total, 1/7) only while it
; is the free one; with a real builder free it shows the builder icon and real builders only (1/6, 26 Oct 2026).
; Goblin icon: free and total lowered by 1. Returns True when lowered
Func GoblinBuilderAdjust(ByRef $iFree, ByRef $iTotal, $sWhere)
	If $iTotal < 2 Or Not IsGoblinCounter($sWhere) Then Return False
	$iFree = _Max(0, $iFree - 1)
	$iTotal -= 1
	SetDebugLog("Goblin Builder not counted, real builders: " & $iFree & "/" & $iTotal)
	Return True
EndFunc   ;==>GoblinBuilderAdjust

; True when the counter icon is a goblin face (Goblin Builder / Goblin Researcher is the free slot).
; Colors read 26 Oct 2026 (same on every Build menu tab)
Func IsGoblinCounter($sWhere)
	Switch $sWhere
		Case "Main" ; main screen builder counter icon (builder: FCB15B / 293110)
			Return _ColorCheck(_GetPixelColor(771, 528, True), Hex(0x929431, 6), 25) And _ColorCheck(_GetPixelColor(785, 540, True), Hex(0xFFBB71, 6), 25)
		Case "MainLab" ; main screen lab counter icon, right of the builder counter
			Return _ColorCheck(_GetPixelColor(817, 529, True), Hex(0x849834, 6), 25) And _ColorCheck(_GetPixelColor(831, 541, True), Hex(0xFFB96F, 6), 25)
		Case "MenuBuilder" ; Build menu tab 1 icon (builder: DD9548 / F7C294)
			Return _ColorCheck(_GetPixelColor(548, 606, True), Hex(0xFFFF72, 6), 25) And _ColorCheck(_GetPixelColor(545, 612, True), Hex(0xDFF555, 6), 25)
		Case "MenuLab" ; Build menu tab 2 icon
			Return _ColorCheck(_GetPixelColor(634, 606, True), Hex(0xF4FF6A, 6), 25) And _ColorCheck(_GetPixelColor(631, 612, True), Hex(0x869233, 6), 25)
	EndSwitch
	Return False
EndFunc   ;==>IsGoblinCounter
