; #FUNCTION# ====================================================================================================================
; Name ..........: MBR Bot Version
; Description ...: This file contains the initialization and main loop sequences f0r the MBR Bot
; Author ........: 
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

; AutoIt version pragmas
#Au3Stripper_Off
#pragma compile(Icon, "Images\MyBot.ico")
#pragma compile(FileDescription, Clash of Clans Bot - A Free Clash of Clans bot - https://mybot.run)
#pragma compile(ProductVersion, 1.1.5)
#pragma compile(FileVersion, 1.1.5)
#pragma compile(LegalCopyright, © https://mybot.run)
#Au3Stripper_On

Global $g_sBotVersion = "v1.1.5" ;~ piwMod version (vX.y.z max). building.ini saved by 1.x is accepted in ReadBuildingConfig
Global $g_sXModversion = "v1.1.5" ; piwMod version shown in titles, GUI and log
