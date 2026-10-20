; #FUNCTION# ====================================================================================================================
; Name ..........: GetDPI_Ratio
; Description ...: Returns the current user DPI setting for display.
; Syntax ........: GetDPI_Ratio()
; Parameters ....: None
; Return values .: Ratio of DPI to standard 96 DPI display
; Author ........: Spiff59 (AutoIt Forums posted 9/23/2013)
; Modified ......: KnowJack
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: None
; Link ..........: https://www.autoitscript.com/forum/topic/154885-autoit-and-dpi-awareness/
; Example .......: No
; ===============================================================================================================================

Global Const $g_iDPI_Ratio = 1

Func GetDPI_Ratio()
	Local $g_hAndroidWindow = 0
	Local $hDC = DllCall("user32.dll", "long", "GetDC", "long", $g_hAndroidWindow)
	If @error Then Return SetError(1, @extended, 0)
	Local $aRet = DllCall("gdi32.dll", "long", "GetDeviceCaps", "long", $hDC[0], "long", 90)
	If @error Then Return SetError(2, @extended, 0)
	$hDC = DllCall("user32.dll", "long", "ReleaseDC", "long", $g_hAndroidWindow, "long", $hDC)
	If @error Then Return SetError(3, @extended, 0)
	If $aRet[0] = 0 Then $aRet[0] = 96
	Return $aRet[0] / 96
EndFunc   ;==>GetDPI_Ratio


; #FUNCTION# ====================================================================================================================
; Name ..........: GUISetFont_DPI
; Description ...: Automaticaly adjust GUI font size for User DPI setting
; Syntax ........: GUISetFont_DPI($isize[, $iweight = ""[, $iattribute = ""[, $sfontname = ""]]])
; Parameters ....: $isize               - an integer value.
;                  $iweight             - [optional] an integer value. Default is "".
;                  $iattribute          - [optional] an integer value. Default is "".
;                  $sfontname           - [optional] a string value. Default is "".
; Return values .: None
; Author ........: Spiff59 (AutoIt Forums posted 9/23/2013)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: None
; Link ..........: https://github.com/MyBotRun/MyBot/wiki https://www.autoitscript.com/forum/topic/154885-autoit-and-dpi-awareness/
; Example .......: N
; ===============================================================================================================================

Func GUISetFont_DPI($isize, $iweight = "", $iattribute = "", $sfontname = "")
	GUISetFont($isize / $g_iDPI_Ratio, $iweight, $iattribute, $sfontname)
EndFunc   ;==>GUISetFont_DPI


