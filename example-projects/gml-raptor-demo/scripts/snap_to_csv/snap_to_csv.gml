/// @return CSV string that encodes the provided 2D array
/// 
/// @param array2D             The 2D array to encode
/// @param [cellDelimiter]     Character to use to indicate where cells start and end. First 127 ASCII chars only. Defaults to a comma
/// @param [stringDelimiter]   Character to use to indicate where strings start and end. First 127 ASCII chars only. Defaults to a double quote
/// 
/// @jujuadams 2022-07-03

//In the general case, functions/methods cannot be deserialised so we default to preventing their serialisation to begin with
//If you'd like to throw an error whenever this function tries to serialise a function/method, set SNAP_CSV_SERIALISE_FUNCTION_NAMES to -1
//If you'd like to simply ignore functions/methods when serialising structs/arrays, set SNAP_CSV_SERIALISE_FUNCTION_NAMES to 0
//If you'd like to use some clever tricks to deserialise functions/methods in a manner specific to your game, set SNAP_CSV_SERIALISE_FUNCTION_NAMES to 1
#macro SNAP_CSV_SERIALISE_FUNCTION_NAMES  -1

function snap_to_csv()
{
    var _root_array       = argument[0];
    var _cell_delimiter   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : ",";
    var _string_delimiter = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : "\"";
    
    var _cell_delimiter_ord      = ord(_cell_delimiter);
    var _string_delimiter_double = _string_delimiter + _string_delimiter;
    var _string_delimiter_ord    = ord(_string_delimiter);
    
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    var _y = 0;
    repeat(array_length(_root_array))
    {
        var _row_array = _root_array[_y];
        var _x = 0;
        repeat(array_length(_row_array))
        {
            var _value = _row_array[_x];
            
            if (is_string(_value))
            {
                var _old_size = string_byte_length(_value);
                _value = string_replace_all(_value, _string_delimiter, _string_delimiter_double);
                
                if ((_old_size != string_byte_length(_value)) || (string_pos(_cell_delimiter, _value) > 0))
                {
                    buffer_write(_buffer, buffer_u8, _string_delimiter_ord);
                    buffer_write(_buffer, buffer_text, _value);
                    buffer_write(_buffer, buffer_u8, _string_delimiter_ord);
                }
                else
                {
                    buffer_write(_buffer, buffer_text, _value);
                }
            }
            else if (is_method(_value))
            {
                if (SNAP_CSV_SERIALISE_FUNCTION_NAMES <= 0)
                {
                    if (SNAP_CSV_SERIALISE_FUNCTION_NAMES < 0) show_error("Functions/methods cannot be serialised\n(Please edit macro SNAP_CSV_SERIALISE_FUNCTION_NAMES to change this behaviour)\n ", true);
                }
                else
                {
                    buffer_write(_buffer, buffer_text, string(_value));
                }
            }
            else if (is_struct(_value) || is_array(_value))
            {
                show_error("Array contains a nested struct or array. This is incompatible with CSV\n ", true);
            }
            else
            {
                // YoYoGames in their finite wisdom added a new datatype in GMS2022.5 that doesn't stringify nicely
                //     string(instance.id) = "ref 100001"
                // This means we end up writing a string with a space in it to CSV. This is leads to difficulties when deserializing data
                // We can check <typeof(id) == "ref"> but string comparison is slow and gross
                // 
                // Instance IDs have the following detectable characteristics:
                // typeof(value)       = "ref"
                // is_array(value)     = false  *
                // is_bool(value)      = false
                // is_infinity(value)  = false
                // is_int32(value)     = false
                // is_int64(value)     = false
                // is_method(value)    = false  *
                // is_nan(value)       = false
                // is_numeric(value)   = true
                // is_ptr(value)       = false
                // is_real(value)      = false
                // is_string(value)    = false  *
                // is_struct(value)    = false  *
                // is_undefined(value) = false
                // is_vec3(value)      = false  *  (covered by is_array())
                // is_vec4(value)      = false  *  (covered by is_array())
                // 
                // Up above we've already tested the datatypes marked with asterisks
                // We can fish out instance references by checking <is_numeric() == true> and then excluding other numeric datatypes
                // ...but that's a lot of function calls so a <typeof(id) == "ref"> check is probably faster
                
                if (is_numeric(_value) && (typeof(_value) == "ref"))
                {
                    buffer_write(_buffer, buffer_text, string(real(_value))); //Save the numeric component of the instance ID
                }
                else
                {
                    buffer_write(_buffer, buffer_text, string(_value));
                }
            }
            
            buffer_write(_buffer, buffer_u8, _cell_delimiter_ord);
            ++_x;
        }
        
        buffer_write(_buffer, buffer_u8, 13);
        ++_y;
    }
    
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    return _string;
}