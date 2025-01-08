if (!CONFIGURATION_UNIT_TESTING) exit;

function unit_test_little_helpers() {
 
	var ut = new UnitTest("LittleHelpers");
 
	ut.tests.bit_operations_enum_ok = function(test, data) {		
		var t = 0;
		t = bit_set_enum(t, bits_enum.b3, true);	test.assert_equals(t, bits_enum.b3, "b3 set");
		t = bit_set_enum(t, bits_enum.b2, true);	test.assert_equals(t, bits_enum.b3 | bits_enum.b2, "b2 set");
		t = bit_set_enum(t, bits_enum.b3, false);	test.assert_equals(t, bits_enum.b2, "b2 check");
		
		test.assert_true (bit_get_enum(t, bits_enum.b2), "b2 get");
		test.assert_false(bit_get_enum(t, bits_enum.b3), "b2 get");
	}
 
	ut.tests.bit_operations_variable_ok = function(test, data) {
		var t = 0;
		t = bit_set(t, 3, true);	test.assert_equals(t, bits_enum.b3, "b3 set");
		t = bit_set(t, 2, true);	test.assert_equals(t, bits_enum.b3 | bits_enum.b2, "b2 set");
		t = bit_set(t, 3, false);	test.assert_equals(t, bits_enum.b2, "b2 check");
		
		test.assert_true (bit_get(t, 2), "b2 get");
		test.assert_false(bit_get(t, 3), "b2 get");		
	}
 
	ut.run();
}
