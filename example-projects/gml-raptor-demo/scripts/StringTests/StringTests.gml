if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_Strings() {
	if (!script_exists(asset_get_index("string_skip_start"))) {
		ilog($"Skipped unit tests for 'Strings': Not in project.");
		return;
	}

	var ut = new UnitTest("Strings");
	
	ut.tests.sprintf_ok		= function(test, data) {
		var t = sprintf("{{0}+{1}={2}}", 1, 1, 2);
		test.assert_equals("{1+1=2}", t);
	};

	ut.tests.skip_start_ok	= function(test, data) {
		var t = string_skip_start("1234567890", 1);
		test.assert_equals("234567890", t, "skip 1");
		
		t = string_skip_start("1234567890", 3);
		test.assert_equals("4567890", t, "skip 3");
	};

	ut.tests.skip_end_ok	= function(test, data) {
		var t = string_skip_end("1234567890", 1);
		test.assert_equals("123456789", t, "skip 1");
		
		t = string_skip_end("1234567890", 3);
		test.assert_equals("1234567", t, "skip 3");
	};

	ut.tests.starts_with_ok	= function(test, data) {
		test.assert_true(string_starts_with("1234567890", "123"));
		test.assert_false(string_starts_with("1234567890", "012"));
	};

	ut.tests.ends_with_ok	= function(test, data) {
		test.assert_true(string_ends_with("1234567890", "890"));
		test.assert_false(string_ends_with("1234567890", "789"));
	};

	ut.tests.is_empty_ok	= function(test, data) {
		test.assert_true(string_is_empty(undefined));
		test.assert_true(string_is_empty(""));
		test.assert_true(string_is_empty(" \t\n"));
	};

	ut.tests.contains_ok	= function(test, data) {
		test.assert_true(string_contains("1234567890", "890"));
		test.assert_true(string_contains("1234567890", "456"));
		test.assert_false(string_contains("1234567890", "4456"));
	};

	ut.tests.parse_hex_ok	= function(test, data) {
		test.assert_equals(255, string_parse_hex("$FF"));
		test.assert_equals(49152, string_parse_hex("C000"));
	};

	ut.tests.convert_hex_ok	= function(test, data) {
		test.assert_equals("FF", string_get_hex(255));
		test.assert_equals("00ff", string_get_hex(255,4,false));
		test.assert_equals("c000", string_get_hex(49152,,false));
	};

	ut.tests.string_first_ok = function(test, data) {
		test.assert_equals("Ghost", string_first("Ghostbusters", 5));
		test.assert_equals("Ghostbusters", string_first("Ghostbusters", 99));
		test.assert_equals("", string_first("Ghostbusters", 0));
	}

	ut.tests.string_last_ok = function(test, data) {
		test.assert_equals("busters", string_last("Ghostbusters", 7));
		test.assert_equals("Ghostbusters", string_last("Ghostbusters", 99));
		test.assert_equals("", string_last("Ghostbusters", 0));
	}

	ut.tests.string_substring_ok = function(test, data) {
		test.assert_equals("1", string_substring("1234",1,1));
		test.assert_equals("2", string_substring("1234",2,1));
		test.assert_equals("34", string_substring("1234",3));
	}

	ut.tests.string_format_number_ok = function(test, data) {
		test.assert_equals("  42", string_format_number(42,4));
		test.assert_equals("  42.0", string_format_number(42,4,1));
		test.assert_equals("0042.0", string_format_number(42,4,1, true));
		test.assert_equals("42.0", string_format_number(42,1,1, true));
	}
	
	ut.tests.string_format_number_right_ok = function(test, data) {
		test.assert_equals("  42", string_format_number_right(42,4));
		test.assert_equals("  42.0", string_format_number_right(42,4,1));
		test.assert_equals("42.0", string_format_number_right(42,1,1, true));
	}

	ut.tests.string_format_number_left_ok = function(test, data) {
		test.assert_equals("42", string_format_number_left(42,4));
		test.assert_equals("42.0", string_format_number_left(42,4,1));
		test.assert_equals("42.0", string_format_number_left(42,1,1));
	}

	ut.tests.string_index_of_ok = function(test, data) {
		test.assert_equals( 5, string_index_of("data/files/file.txt", "/"   ));
		test.assert_equals(11, string_index_of("data/files/file.txt", "/", 6));
		test.assert_equals( 0, string_index_of("data/files/file.txt", ":"   ));
	}

	ut.tests.string_last_index_of_ok = function(test, data) {
		test.assert_equals(11, string_last_index_of("data/files/file.txt", "/"   ));
		test.assert_equals(11, string_last_index_of("data/files/file.txt", "/", 6));
		test.assert_equals( 0, string_last_index_of("data/files/file.txt", ":"   ));
	}

	ut.tests.string_to_real_ok = function(test, data) {
		test.assert_equals(42, string_to_real(" 42 "));
		test.assert_equals(-42, string_to_real(" -42 "));
		test.assert_equals(42, string_to_real(" 42,43,44 "));
		test.assert_null(string_to_real("hello world 42"));
		
		test.assert_equals(42, string_to_real_ex(" 42 "));
		test.assert_equals(-42, string_to_real_ex(" -42. "));
		test.assert_null(string_to_real_ex(" 42-43.44 "));
		test.assert_null(string_to_real_ex(" 42.43.44 "));
		test.assert_null(string_to_real_ex(" 42,43,44 "));
		test.assert_null(string_to_real_ex("hello world 42"));		
	}

	ut.tests.string_to_int_ok = function(test, data) {
		test.assert_equals(42, string_to_int(" 42 "));
		test.assert_equals(-42, string_to_int(" -42,43,44 "));
		test.assert_null(string_to_int("hello world 42"));
		
		test.assert_equals(42, string_to_int_ex(" 42 "));
		test.assert_equals(-42, string_to_int_ex(" -42 "));
		test.assert_null(string_to_int_ex(" -42. "));
		test.assert_null(string_to_int_ex(" 42-43.44 "));
		test.assert_null(string_to_int_ex(" 42.43.44 "));
		test.assert_null(string_to_int_ex(" 42,43,44 "));
		test.assert_null(string_to_int_ex("hello world 42"));
	}

	ut.run();
}
