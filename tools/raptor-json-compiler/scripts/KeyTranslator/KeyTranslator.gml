/*
    Translate the current keyboard_key to a string.
	This code is taken from @JujuAdams & Contributors input-library and modified
	to fit the needs of my internal platform for specific cases (like the StatefulObject).
	
	Credits to @JujuAdams & Contributors at github!
*/

// Those macros are also taken from input but renamed to avoid conflicts if the game uses input library too
#macro __KEY_TRANSLATE_DESKTOP  ((os_type == os_macosx) || (os_type == os_linux) || (os_type == os_windows))
#macro __KEY_TRANSLATE_APPLE    ((os_type == os_macosx) || (os_type == os_ios)   || (os_type == os_tvos))

#macro __KEY_TRANSLATE_OPERAGX  (os_type == os_operagx)
#macro __KEY_TRANSLATE_WEB      ((os_browser != browser_not_a_browser) || __KEY_TRANSLATE_OPERAGX)

#macro __KEY_TRANSLATE_PHYS_KEYBOARD (__KEY_TRANSLATE_DESKTOP || __KEY_TRANSLATE_WEB || (os_type == os_switch) || (os_type == os_uwp))

/// @func keyboard_to_string()
/// @desc translate the current keyboard_key to a string that is
///				 as-equal-as-possible to the gamemaker constant names (like vk_home)
function keyboard_to_string(_key_to_translate = undefined) {
	if (_key_to_translate == "") return "";
	var _key = _key_to_translate == undefined ? keyboard_key : _key_to_translate;
	if (_key == undefined) return "";

	if ((_key >= ord("A")) && (_key <= ord("Z")))
    {
        //Latin letters
        return chr(_key);
    }
    else if (_key >= ord("0")) && (_key <= ord("9"))
    {
        //Top row numbers
        return chr(_key);
    }
    else 
    {
        //Universal non-UTF8 keycodes
        switch(_key)
        {             
            case vk_up:			return "vk_up";    break;
            case vk_down:		return "vk_down";  break;
            case vk_left:		return "vk_left";  break;
            case vk_right:		return "vk_right"; break;
            
            case vk_escape:		return "vk_escape";    break;
            case vk_backspace:	return "vk_backspace"; break;
            case vk_space:		return "vk_space";     break;
            case vk_tab:		return "vk_tab";       break;
            case vk_enter:		return "vk_enter";     break;
        }
        
        //Apple Web exceptions
        if (__KEY_TRANSLATE_APPLE && __KEY_TRANSLATE_WEB)
        {
            switch(_key)
            {
                case 12: return "vk_numlock";   break;
                case 92: return "vk_meta1";		break;
                case 93: return "vk_meta2";		break;
            }
        }
        
        //Switch exceptions
        if (os_type == os_switch)
        {
            switch(_key)
            {
                case 107: return "+"; break;
                case 109: return "-"; break;
                case 110: return "."; break;
            }
        }

        //Desktop platform non-UTF8 keycodes
        if (__KEY_TRANSLATE_PHYS_KEYBOARD)
        {
            //Common function row (F1 - F10)
            if ((_key >= vk_f1) && (_key <= vk_f10))
            {
                return ("F" + string(1 + _key - vk_f1));
            }

            switch(_key)
            {                 
                //Symbols
                case 186: return ";";  break;
                case 188: return ",";  break;
                case 190: return ".";  break;
                case 191: return "/";  break;
                case 219: return "[";  break;
                case 220: return "\\"; break;
                case 221: return "]";  break;
            
                //Control
                case  93: return "vk_menu";      break;
                case 144: return "vk_numlock";   break;
                case 145: return "vk_scrollock"; break;
                                                   
                //Command pairs
                case vk_ralt: return "vk_ralt";	 break;
                case vk_lalt: return "vk_lalt";  break;
                case vk_alt:  return "vk_alt";   break;

                case vk_rshift: return "vk_rshift"; break;
                case vk_lshift: return "vk_lshift";  break;
                case vk_shift:  return "vk_shift";       break;
            
                case vk_rcontrol: return "vk_rcontrol"; break;
                case vk_lcontrol: return "vk_lcontrol";  break;
                case vk_control:  return "vk_control";       break;
                
                //Numpad
                case vk_numpad0:  return "vk_numpad0";	break;
                case vk_numpad1:  return "vk_numpad1";	break;
                case vk_numpad2:  return "vk_numpad2";	break;
                case vk_numpad3:  return "vk_numpad3";	break;
                case vk_numpad4:  return "vk_numpad4";	break;
                case vk_numpad5:  return "vk_numpad5";	break;
                case vk_numpad6:  return "vk_numpad6";	break;
                case vk_numpad7:  return "vk_numpad7";	break;
                case vk_numpad8:  return "vk_numpad8";	break;
                case vk_numpad9:  return "vk_numpad9";	break;
                case vk_divide:   return "vk_divide";	break;
                case vk_decimal:  return "vk_decimal";	break;
                case vk_multiply: return "vk_multiply"; break;
                case vk_add:      return "vk_add";		break;
                case vk_subtract: return "vk_subtract"; break;            

                //Misc.
                case 20:			 return "vk_capslock";    break;
                case vk_home:        return "vk_home";         break;
                case vk_end:         return "vk_end";          break;
                case vk_insert:      return "vk_insert";       break;
                case vk_delete:      return "vk_delete";       break;
                case vk_pagedown:    return "vk_pagedown";    break;
                case vk_pageup:      return "vk_pageup";      break;
                case vk_printscreen: return "vk_printscreen"; break;
                case vk_pause:       return "vk_pause";  break;
            }
        }
        
        //Per platform non-UTF8
        var _platform = os_type;

        //Browsers normalize keycodes across platforms
        //See https://github.com/wesbos/keycodes/blob/gh-pages/scripts.js        
        if (__KEY_TRANSLATE_WEB) _platform = "browser";
        
        switch(_platform)
        {
            //UWP uses select keycodes to reflect gamepad input
            //by default this behaviour is ignored (INPUT_IGNORE_RESERVED_KEYS_LEVEL > 0)              
            case os_uwp:
               switch(_key)      
               {
                   case 195: return "gamepad_face_south"; break;
                   case 196: return "gamepad_face_east";  break;
                   case 197: return "gamepad_face_west";  break;
                   case 198: return "gamepad_face_north"; break;
											
                   case 200: return "gamepad_shoulder_l"; break;
                   case 199: return "gamepad_shoulder_r"; break;
                   case 201: return "gamepad_trigger_l";  break;
                   case 202: return "gamepad_trigger_r";  break;
											
                   case 208: return "gamepad_select"; break;
                   case 207: return "gamepad_start";  break;
											
                   case 209: return "gamepad_thumbstick_l_click"; break;
                   case 210: return "gamepad_thumbstick_r_click"; break;
											
                   case 203: return "gamepad_dpad_up";    break;
                   case 204: return "gamepad_dpad_down";  break;
                   case 205: return "gamepad_dpad_left";  break;
                   case 206: return "gamepad_dpad_right"; break;
											
                   case 214: return "gamepad_thumbstick_l_left";  break;
                   case 213: return "gamepad_thumbstick_l_right"; break;
                   case 211: return "gamepad_thumbstick_l_up";    break;
                   case 212: return "gamepad_thumbstick_l_down";  break;
													   
                   case 218: return "gamepad_thumbstick_r_left";  break;
                   case 217: return "gamepad_thumbstick_r_right"; break;
                   case 215: return "gamepad_thumbstick_r_up";    break;
                   case 216: return "gamepad_thumbstick_r_down";  break;
               }
                
            //UWP also uses Windows case
            case os_windows:
            case "browser":
                //F11 - F32
                if ((_key >= vk_f11) && (_key <= vk_f1 + 31))
                {
                    return "F" + string(_key - vk_f1 + 1);
                }
            
                switch(_key)
                {
                    case 187: return "="; break;
                    case 189: return "-"; break;
                    case 192: return "`"; break;
                    case 222: return "'"; break;
            
                    case 12:  return "vk_clear"; break;
                    
                    case 91: return "vk_meta1";  break;
                    case 92: return "vk_meta2"; break;
                }
            break;
            
            case os_macosx:
                switch(_key)      
                {
                    case 128: return "F11"; break;
                    case 129: return "F12"; break;
                    
                    case 24:  return "="; break;
                    case 109: return "-"; break;
                    case 222: return "'"; break;
                    
                    //Swapped on Mac
                    case 91:  return "vk_meta1"; break;
                    case 92:  return "vk_meta2"; break;
                }
            break;
            
            case os_linux:
                switch(_key)      
                {
                    case 128: return "F11"; break;
                    case 129: return "F12"; break;
                    
                    case 187: return "="; break;
                    case 189: return "-"; break;
                    case 192: return "'"; break;
                    case 223: return "`"; break;
                    
                    case 91:  return "vk_meta1"; break;
                    case 92:  return "vk_meta2"; break;
                }
            break;
            
            case os_android:
                switch(_key)      
                {
                    case 10: return "vk_enter";
                }
            break;
            
            case os_switch:
                switch(_key)
                {
                    case 2: case 3: case 4: 
                    case 5: case 6: case 7:
                        return string(_key);
                    break;
                    
                    case 128: return "F11"; break;
                    case 129: return "F12"; break; 
                }
            break;
        }
        
        return chr(_key); //Default to UTF8 character
    }
	
}