Hotkey_Control(State=1)  {
	Static IsStart
	If (!IsStart)
		Hotkey_ExtKeyInit(State), IsStart := 1
	Hotkey_WindowsHookEx(!!State)
}

Hotkey_Main(VKCode, SCCode = 0, Option = 0, IsMod = 0)  {
	Local sIsMod
	Static K:={}, ModsOnly, Prefix := {"Alt":"!","Ctrl":"^","Shift":"+","Win":"#"}
		, LRPrefix := {"LAlt":"<!","LCtrl":"<^","LShift":"<+","LWin":"<#"
				,"RAlt":">!","RCtrl":">^","RShift":">+","RWin":">#"}
		, VkMouse := {"MButton":"vk4","WheelDown":"vk9E","WheelUp":"vk9F","WheelRight":"vk9D"
				,"WheelLeft":"vk9C","XButton1":"vk5","XButton2":"vk6","LButton":"vk1","RButton":"vk2"}
		, Symbols := "|vkBA|vkBB|vkBC|vkBD|vkBE|vkBF|vkC0|vkDB|vkDC|vkDD|vkDE|vk41|vk42|"
				. "vk43|vk44|vk45|vk46|vk47|vk48|vk49|vk4A|vk4B|vk4C|vk4D|vk4E|"
				. "vk4F|vk50|vk51|vk52|vk53|vk54|vk55|vk56|vk57|vk58|vk59|vk5A|"
	If (Option = "Down")
	{
		If (K["M" IsMod] != "")
			Return 1
		sIsMod := SubStr(IsMod, 2)
		K["M" sIsMod] := sIsMod "+", K["P" sIsMod] := Prefix[sIsMod]
		K["M" IsMod] := IsMod "+", K["P" IsMod] := LRPrefix[IsMod]
	}
	Else If (Option = "Up")
	{
		sIsMod := SubStr(IsMod, 2)
		K["M" IsMod] := K["P" IsMod] := ""
		If (K["ML" sIsMod] = "" && K["MR" sIsMod] = "")
			K["M" sIsMod] := K["P" sIsMod] := ""
		If (K.HK != "")
			return 1
	}
	Else If (Option = "OnlyMods")
	{
		If !ModsOnly
			Return 0
		K.MCtrl := K.MAlt := K.MShift := K.MWin := K.Mods := ""
		K.PCtrl := K.PAlt := K.PShift := K.PWin := K.Pref := ""
		K.PLCtrl := K.PLAlt := K.PLShift := K.PLWin := K.LRPref := ""
		K.PRCtrl := K.PRAlt := K.PRShift := K.PRWin := ""
		K.MLCtrl := K.MLAlt := K.MLShift := K.MLWin := K.LRMods := ""
		K.MRCtrl := K.MRAlt := K.MRShift := K.MRWin := ""
		%Hotkey_TargetFunc%(K*)
		Return ModsOnly := 0
	}
	Else If (VKCode = "GetMod")
		Return K.PCtrl K.PAlt K.PShift K.PWin
	K.VK := VKCode, K.SC := SCCode
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.TK := GetKeyName(VKCode SCCode), K.TK := K.TK = "" ? VKCode SCCode : K.TK
	(IsMod) ? (K.HK := K.Pref := K.LRPref := K.Name := "", ModsOnly := K.Mods = "" ? 0 : 1)
	: (K.HK := InStr(Symbols, "|" VKCode "|") ? VKCode : K.TK
	, K.Name := K.HK = "vkBF" ? "/" : K.TK
	, K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	, K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	, ModsOnly := 0)
	%Hotkey_TargetFunc%(K*)
	Return 1

Hotkey_PressName:
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	K.HK := K.Name := K.TK := A_ThisHotkey, ModsOnly := 0, K.SC := ""
	K.VK := !InStr(A_ThisHotkey, "Joy") ? VkMouse[A_ThisHotkey] : ""
	%Hotkey_TargetFunc%(K*)
	Return 1
}

Hotkey_ExtKeyInit(Options)   {
	Local SaveFormat, MouseKey
	#If Hotkey_Hook
	#If Hotkey_Hook && !Hotkey_Main("GetMod")
	#If Hotkey_Hook && Hotkey_Main("GetMod")
	#If
	IfInString, Options, M
	{
		MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
		Hotkey, IF, Hotkey_Hook
		Loop, Parse, MouseKey, |
			Hotkey, %A_LoopField%, Hotkey_PressName
	}
	IfInString, Options, L
	{
		Hotkey, IF, Hotkey_Hook && Hotkey_Main("GetMod")
		Hotkey, LButton, Hotkey_PressName
	}
	IfInString, Options, R
	{
		Hotkey, IF, Hotkey_Hook
		Hotkey, RButton, Hotkey_PressName
	}
	IfInString, Options, J
	{
		SaveFormat := A_FormatInteger
		SetFormat, IntegerFast, D
		Hotkey, IF, Hotkey_Hook && !Hotkey_Main("GetMod")
		Loop, 128
			Hotkey % Ceil(A_Index/32) "Joy" Mod(A_Index-1,32)+1, Hotkey_PressName
		SetFormat, IntegerFast, %SaveFormat%
	}
	Hotkey, IF
}

Hotkey_Reset()   {
	Return Hotkey_Hook := 0, Hotkey_Main(0, 0, "OnlyMods")
}

    ;  http://forum.script-coding.com/viewtopic.php?id=6350

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam)   {
	Local VkCode, SCCode, sc, IsMod
	Static Mods := {"vkA4":"LAlt","vkA5":"RAlt","vkA2":"LCtrl","vkA3":"RCtrl"
		,"vkA0":"LShift","vkA1":"RShift","vk5B":"LWin","vk5C":"RWin"}, SaveFormat
	If !Hotkey_Hook
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	SaveFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	VKCode := "vk" SubStr(NumGet(lParam+0, 0, "UInt"), 3)
	sc := NumGet(lParam+0, 8, "UInt") & 1, sc := sc << 8 | NumGet(lParam+0, 4, "UInt")
	SCCode := "sc" SubStr(sc, 3), IsMod := Mods[VKCode]
	SetFormat, IntegerFast, %SaveFormat%
	If (wParam = 0x100 || wParam = 0x104)   ;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
		IsMod ? Hotkey_Main(VKCode, SCCode, "Down", IsMod) : Hotkey_Main(VKCode, SCCode)
	Else If ((wParam = 0x101 || wParam = 0x105) && VKCode != "vk5D")   ;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105, AppsKey = "vk5D"
		nCode := -1, IsMod ? Hotkey_Main(VKCode, SCCode, "Up", IsMod) : 0
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1
}

Hotkey_WindowsHookEx(State)   {
	Static Hook
	If State
		Hook := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
				, "Int", 13   ;  WH_KEYBOARD_LL
				, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
				, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
				, "UInt", 0, "Ptr")
	Else
		DllCall("UnhookWindowsHookEx", "Ptr", Hook), Hook := "", Hotkey_Reset()
}
