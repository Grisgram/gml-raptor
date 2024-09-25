if (!CONFIGURATION_UNIT_TESTING) exit;
 
function unit_test_Structs() {
	if (!script_exists(asset_get_index("struct_join"))) {
		ilog($"Skipped unit tests for 'Structs': Not in project.");
		return;
	}

	var ut = new UnitTest("Structs");
 
	ut.TestRoot = function(_val = 42) constructor {
		construct("TestRoot");
		some_var = _val;
		
		virtual("TestRoot", "virt", function() {
			return 42;
		});
	}
	 
	ut.tests.construct_ok = function(test, data) {
		var root = new test.TestRoot();	
		test.assert_equals(root[$ __CONSTRUCTOR_NAME], "TestRoot", "construct");
		test.assert_true(is_class_of(root, "TestRoot"), "class of");	
		test.assert_true(is_child_class_of(root, "TestRoot"), "child class of");	
	}
 	
	ut.tests.implement_ok = function(test, data) {
		var root = {};
		with (root) implement(test.TestRoot);
		test.assert_equals(42, root.some_var, "implement default");
		
		with (root) implement(test.TestRoot, 1337);
		test.assert_equals(1337, root.some_var, "implement 1337");

		test.assert_true(implements(root, "TestRoot"), "implements TestRoot");
	}
	
	ut.tests.struct_join_ok = function(test, data) {
		var s1 = { m1: 0 };
		var s2 = { m2: 0 };
		
		var s3 = struct_join(s1, s2);
		
		test.assert_true(struct_exists(s3, "m1"), "m1");
		test.assert_true(struct_exists(s3, "m2"), "m2");
		
		test.assert_false(struct_exists(s2, "m1"), "s2.m1");
		test.assert_false(struct_exists(s1, "m2"), "s1.m2");
	}

	ut.tests.struct_join_into_ok = function(test, data) {
		var s1 = { m1: 0, sub: { sub1: 1, } };
		var s2 = { m2: 0, sub: { sub2: 1, } };
		var s3 = { m3: 0, sub: { sub3: 1, } };
		
		struct_join_into(s1, s2, s3);
		
		test.assert_true(struct_exists(s1, "m1"), "m1");
		test.assert_true(struct_exists(s1, "m2"), "m2");
		test.assert_true(struct_exists(s1, "m3"), "m3");

		test.assert_true(struct_exists(s1.sub, "sub1"), "sub1");
		test.assert_true(struct_exists(s1.sub, "sub2"), "sub2");
		test.assert_true(struct_exists(s1.sub, "sub3"), "sub3");

	}

	ut.tests.vsgetx_ok = function(test, data) {
		var root = new test.TestRoot();	

		test.assert_null(vsget(root, "hello"), "hello before");
		vsgetx(root, "hello", undefined, false);		
		test.assert_null(vsget(root, "hello"), "hello after"); // still null
		
		vsgetx(root, "hello", "world");
		test.assert_equals("world", vsget(root, "hello"), "hello world");

	}

	ut.tests.vsget_ok = function(test, data) {
		var root = new test.TestRoot();	

		test.assert_null(vsget(root, "hello"), "hello");
		test.assert_equals(42, vsget(root, "some_var"), "42");
		test.assert_equals(1337, vsget(root, "hello", 1337), "1337");
	}

	ut.tests.versioned_data_struct_names_ok = function(test, data) {
		var vds = new VersionedDataStruct();
		var names = struct_get_names(vds);
		test.assert_equals(2, array_length(names), "length");
		test.assert_true(array_contains(names, __CONSTRUCTOR_NAME), "const");
		test.assert_true(array_contains(names, __PARENT_CONSTRUCTOR_NAME), "parent const");
		
		names = vds.get_names();
		test.assert_zero(array_length(names), "zero");
	}

	ut.run();
}

