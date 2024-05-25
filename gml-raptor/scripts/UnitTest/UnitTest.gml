/*
	Basic unit testing library for GML.
	Unit Testing is a very important step when coding libraries and classes.
	They are reproducible, stable environments that find side-effects and bugs after code changes.
	
	How unit testing works:
	You create a new UnitTest and now have 4 functions, that you can override (re-define):
	suite_start		- called once when you run() the tests.
	test_start		- called before each test. set up (and return) your test_data for each test of the suite in this function
	test_finish		- called after each test. use it to clean up, if necessary
	suite_finish	- called after the last test of the run(). use it to clean up, if necessary

	Alternatively, if you do not want (or need) to override test_start to create test_data, you can simply set .test_data
	to any struct you want, but keep in mind, that this is a reference type, so if your test modifies that data, the next
	test sees the modified version and not the original data.
	In doubt, it is always better to supply fresh generated test_data to EACH test.

	To add a test to the suite, you have 2 ways:
	1) simply set tests.name = func(...) {}
	2) call add_test(name, func)
	
	To run your unit tests simply call the run() method and watch the log.
	NOTE: To record your test in the suite, you MUST call one of the assert_*(...) methods to compare your values,
	otherwise the suite can not detect if a test failed or not!
	
	Long story short: Here is a short example, based on the java-standard test of 2+2, which uses no specific test_data.
	
	var math_test = new UnitTest("basic_math");
	math_test.add_test("add", function(test, data) { test.assert_equals(4, 2+2); });
	math_test.run();
	
	Produces this output:
	------------------------------------------------------------------------------------
	0: I <----- START TEST SUITE 'basic_math' ----->
	0: I  OK : add
	0: I DONE: TEST RESULTS 'basic_math': 1 tests, 1 succeeded, 0 failed
	------------------------------------------------------------------------------------
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT

*/

// Unit test automation
#macro __RUN_UNIT_TESTS					ilog("Unit tests disabled");
#macro unit_testing:__RUN_UNIT_TESTS	ilog("Running unit tests");									\
										var ids = asset_get_ids(asset_script);						\
										for (var i = 0, len = array_length(ids); i < len; i++) {	\
											var scr = script_get_name(ids[@i]);						\
											if (string_starts_with(scr, UNIT_TEST_FUNCTION_PREFIX))	\
												ids[@i]();											\
										}															\
										ilog("Unit tests finished");								\
										game_end();

if (!CONFIGURATION_UNIT_TESTING) exit;

/// @func					UnitTest(name = "UnitTest", _test_data = {})
/// @desc				Create a new unit test suite to perform a group of tests
/// @param {string} name		Optional, for log output only
/// @param {struct} _test_data	Optional, will be sent to each test function as second argument
/// @returns {UnitTest}
function UnitTest(name = "UnitTest", _test_data = {}) constructor {

	__test_suite_name	= name;
	__current_test_ok	= true;
	__current_test_name = "";
	__current_test_msg	= "";
	__current_test_exc	= undefined;
	
	tests = {};

	test_data = _test_data ?? {};

	suite_start = function(data) {
	}
	
	suite_finish = function(data) {
	}
	
	test_start = function(current_test_name, data) {
		return data;
	}
	
	test_finish = function(current_test_name, data) {
	}

	#region ASSERTS
	static __assert_condition = function(condition, expected, actual, message) {
		__current_test_msg	= message;
		if (!condition) {
			elog($"FAIL: {__current_test_name} *ASSERT*: expected='{expected}'; actual='{actual}'; message='{message}';");
			__current_test_ok	= false;
		}		
	}
	
	/// @func fail(message = "")
	/// @desc fails the test immediately
	static fail = function(message = "") {
		elog($"FAIL: {__current_test_name} *fail() reached*: message='{message}';");
		__current_test_ok = false;
	}
	
	/// @func success()
	static success = function() {
		__current_test_ok = true;
	}
	
	/// @func expect_exception(_error_message_contains = "")
	static expect_exception = function(_error_message_contains = "") {
		__current_test_exc = _error_message_contains;
	}
	
	/// @func					assert_equals(expected, actual, message = "")
	/// @desc				performs an equality value check. test fails, if "expected != actual"
	static assert_equals = function(expected, actual, message = "") {
		if (is_array(actual))
			__assert_condition(array_equals(expected, actual), expected, actual, message);
		else
			__assert_condition(expected == actual, expected, actual, message);
	}
	
	/// @func					assert_not_equals(expected, actual, message = "")
	/// @desc				performs an non-equality value check. test fails, if "expected == actual"
	static assert_not_equals = function(expected, actual, message = "") {
		if (is_array(actual))
			__assert_condition(!array_equals(expected, actual), expected, actual, message);
		else
			__assert_condition(expected != actual, expected, actual, message);
	}

	/// @func					assert_true(actual, message = "")
	/// @desc				performs a value check for true. test fails, if actual == false
	static assert_true = function(actual, message = "") {
		__assert_condition(actual, true, actual, message);
	}

	/// @func					assert_false(actual, message = "")
	/// @desc				performs a value check for false. test fails, if actual == true
	static assert_false = function(actual, message = "") {
		__assert_condition(!actual, false, actual, message);
	}
	
	/// @func					assert_null(actual, message = "")
	/// @desc				performs a value check against "undefined" and "noone". test fails, if actual is neither.
	static assert_null = function(actual, message = "") {
		__assert_condition(actual == undefined || actual == noone, true, actual, message);
	}
	
	/// @func					assert_not_null(actual, message = "")
	/// @desc				performs a value check against "undefined" and "noone". test fails, if actual is any of them.
	static assert_not_null = function(actual, message = "") {
		__assert_condition(actual != undefined && actual != noone, true, actual, message);
	}
	#endregion
	
	/// @func					add_test(name, func)
	/// @desc				add a unit test. alternatively you can simply set tests.name = func;
	///								a test function receives one argument, the test_data. This is the struct
	///								you set up in the test_start function.
	static add_test = function(name, func) {
		struct_set(tests, name, func);
	}

	/// @func					run()
	/// @desc				runs all tests and prints the results to the log
	static run = function() {
		ilog($"<----- START TEST SUITE '{__test_suite_name}' ----->");
		// ---- SUITE FINISH ----
		try {
			suite_start(test_data);
		} catch (_ex) {
			elog($"FAIL: suite_start threw '{_ex.message}';");
			return;
		}
		
		var fail_count = 0;
		var names = struct_get_names(tests);
		array_sort(names, true);
		var i = 0; repeat(array_length(names)) {
			__current_test_name = names[i++];
			__current_test_ok	= true;
			__current_test_exc	= undefined;
			__current_test_msg	= "";
			var new_data;
			var data_for_test = test_data;
			
			// ---- TEST START ----
			try {
				new_data = test_start(__current_test_name, test_data);
				if (is_struct(new_data))
					data_for_test = new_data;
			} catch (_ex) {
				elog($"FAIL: test_start of '{__current_test_name}' threw '{_ex.message}';");
				__current_test_ok = false;
			}
			
			// ---- TEST RUN ----
			if (__current_test_ok) {
				try {
					struct_get(tests, __current_test_name)(self, data_for_test);
				} catch (_ex) {
					if (__current_test_exc == undefined ||
						(!string_is_empty(__current_test_exc) && !string_contains(_ex.message, __current_test_exc))) {
						elog($"FAIL: {__current_test_name} exception='{_ex.message}'; {__current_test_msg}");
						__current_test_ok = false;
					}
				}
			}
			
			// ---- TEST FINISH ----
			try {
				test_finish(__current_test_name, data_for_test);
			} catch (_ex) {
				elog($"FAIL: test_finish of '{__current_test_name}' threw '{_ex.message}';");
				__current_test_ok = false;
			}
			
			if (__current_test_ok) {
				ilog($" OK : {__current_test_name}");
			} else {
				fail_count++;
			}
		}
		
		// ---- SUITE FINISH ----
		try {
			suite_finish(test_data);
		} catch (_ex) {
			elog($"FAIL: suite_finish threw '{_ex.message}';");
		}
		
		var total = array_length(names);
		ilog($"DONE: TEST RESULTS '{__test_suite_name}': {total} tests, {(total - fail_count)} succeeded, {fail_count} failed");
	}

}

