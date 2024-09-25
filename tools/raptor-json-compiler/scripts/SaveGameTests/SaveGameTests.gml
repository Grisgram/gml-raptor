if (!CONFIGURATION_UNIT_TESTING) exit;
 
function unit_test_SaveGame() {
 
	var ut = new UnitTest("SaveGames");
 
	ut.test_start = function(name, data) {
		GLOBALDATA.testdata = undefined;
	}
 
	ut.tests.savegame_save_ok = function(test, data) {
		GLOBALDATA.testdata = "Hello World";
		
		test.start_async();
		savegame_save_game("unit_test" + DATA_FILE_EXTENSION)
		.on_finished(function(result) {
			global.test.assert_true(result, "success");
			// test the file contents manually with a sync file load
			var savedata = file_read_struct($"{SAVEGAME_FOLDER}/unit_test{DATA_FILE_EXTENSION}");
			var tdname = savedata.global_data;
			var glob = savedata.refstack[$ tdname];
			var hello = glob.testdata;
			global.test.assert_equals("Hello World", hello, "testdata");
			
			global.test.finish_async();
		});
	}
 
	ut.tests.savegame_load_ok = function(test, data) {
		GLOBALDATA.testdata = "Hello World";
		GLOBALDATA.testarray = [1,2,3];
		GLOBALDATA.testcomplex = [
			{ hello: "world" },
			{ xp: 13, yp: 37, },
			{ 
				more_subs: [ 
					{ 
						sub1: [4,5,6], 
						sub2: ["Hello", "World"], 
						sub3: [ { a:1, b:2 }, { e:"mc²" } ],
					} 
				] 
			},
		];
		
		test.start_async();
		savegame_save_game("unit_test" + DATA_FILE_EXTENSION)
		.on_finished(function(result) {
			global.test.assert_true(result, "success");
			GLOBALDATA.testdata = undefined;
			
			savegame_load_game("unit_test" + DATA_FILE_EXTENSION)
			.on_finished(function(result) {
				// assert simple string
			global.test.assert_equals("Hello World", GLOBALDATA.testdata, "testdata");
				
				// assert simple array
				global.test.assert_equals(3, array_length(GLOBALDATA.testarray), "simple array length");
				global.test.assert_equals(1, GLOBALDATA.testarray[@0], "testarray @0");
				global.test.assert_equals(2, GLOBALDATA.testarray[@1], "testarray @1");
				global.test.assert_equals(3, GLOBALDATA.testarray[@2], "testarray @2");
				
				// assert complex struct with subs of all types
				global.test.assert_equals(3, array_length(GLOBALDATA.testcomplex), "complex array length");
				global.test.assert_equals("world", GLOBALDATA.testcomplex[@0].hello, "hello 1");
				
				global.test.assert_equals(13, GLOBALDATA.testcomplex[@1].xp, "substruct 2");
				global.test.assert_equals(37, GLOBALDATA.testcomplex[@1].yp, "substruct 2");
				
				global.test.assert_equals(1, array_length(GLOBALDATA.testcomplex[@2].more_subs), "more_subs length");
				global.test.assert_equals(3, array_length(GLOBALDATA.testcomplex[@2].more_subs[@0].sub1), "more_subs sublength 0");
				global.test.assert_equals(2, array_length(GLOBALDATA.testcomplex[@2].more_subs[@0].sub2), "more_subs sublength 1");
				global.test.assert_equals(2, array_length(GLOBALDATA.testcomplex[@2].more_subs[@0].sub3), "more_subs sublength 2");
				
				global.test.assert_equals(4, GLOBALDATA.testcomplex[@2].more_subs[@0].sub1[@0], "more_subs subarray 1-0");
				global.test.assert_equals(5, GLOBALDATA.testcomplex[@2].more_subs[@0].sub1[@1], "more_subs subarray 1-1");
				global.test.assert_equals(6, GLOBALDATA.testcomplex[@2].more_subs[@0].sub1[@2], "more_subs subarray 1-2");

				global.test.assert_equals("Hello", GLOBALDATA.testcomplex[@2].more_subs[@0].sub2[@0], "more_subs subarray 2-0");
				global.test.assert_equals("World", GLOBALDATA.testcomplex[@2].more_subs[@0].sub2[@1], "more_subs subarray 2-1");
				
				global.test.assert_equals(1, GLOBALDATA.testcomplex[@2].more_subs[@0].sub3[@0].a, "more_subs substruct 3-a");
				global.test.assert_equals(2, GLOBALDATA.testcomplex[@2].more_subs[@0].sub3[@0].b, "more_subs substruct 3-b");
				global.test.assert_equals("mc²", GLOBALDATA.testcomplex[@2].more_subs[@0].sub3[@1].e, "more_subs substruct 3-e");

				global.test.finish_async();
			})
		});
	}
 
	ut.run();
}
