function unit_test_StringBuilder() {
	if (!script_exists(asset_get_index("StringBuilder"))) {
		ilog($"Skipped unit tests for 'StringBuilder': Not in project.");
		return;
	}

	var ut = new UnitTest("StringBuilder");

	ut.test_start = function(name, data) {
		data.t = new StringBuilder();
	}

	ut.test_finish = function(name, data) {
		data.t.clean_up();
	}
	
	ut.tests.empty_ok = function(test, data) {
		test.assert_equals(0, data.t.length(), "empty");
		test.assert_equals("", data.t.toString());
	};

	ut.tests.clean_up_ok = function(test, data) {
		data.t.clean_up();
		test.assert_null(data.t._buffer, "buffer is null");
		try {
			data.t.append(".");
			test.fail(); // must crash, as _buffer should be undefined
		} catch (_) {
			test.success();
		}
	};

	ut.tests.append_ok = function(test, data) {
		data.t.append("Hello");
		test.assert_equals("Hello", data.t.toString());
	}

	ut.tests.append_word_ok = function(test, data) {
		data.t.append("Hello").append_word("World");
		test.assert_equals("Hello World", data.t.toString());
	}

	ut.tests.append_line_ok = function(test, data) {
		data.t.append_line("Hello").append("World");
		test.assert_equals("Hello\nWorld", data.t.toString());
	}

	ut.run();
}
