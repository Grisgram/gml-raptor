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
			var hello = savedata.refstack[$ tdname].testdata;
			global.test.assert_equals("Hello World", hello, "testdata");
			global.test.finish_async();
		});
	}
 
	ut.tests.savegame_load_ok = function(test, data) {
		GLOBALDATA.testdata = "Hello World";
		
		test.start_async();
		savegame_save_game("unit_test" + DATA_FILE_EXTENSION)
		.on_finished(function(result) {
			global.test.assert_true(result, "success");
			GLOBALDATA.testdata = undefined;
			
			savegame_load_game("unit_test" + DATA_FILE_EXTENSION)
			.on_finished(function(content) {
				global.test.assert_equals("Hello World", GLOBALDATA.testdata, "testdata");
				global.test.finish_async();
			})
		});
	}
 
	ut.run();
}
