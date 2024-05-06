function unit_test_Race() {
	if (!script_exists(asset_get_index("Race"))) {
		ilog($"Skipped unit tests for 'Race': Not in project.");
		return;
	}

	ENSURE_RACE;
	
	var ut = new UnitTest("Race");

	ut.test_start = function(name, data) {
		data.t = new Race("demotable");
	}

	ut.test_finish = function(name, data) {
		data.t.clear();
	}

	ut.tests.file_load_ok = function(test, data) {
		var race = data.t;
		
		var names = struct_get_names(race.tables);
		
		test.assert_equals(3, array_length(names));
		test.assert_true(race.table_exists("demotable"), "demotable");
		test.assert_true(race.table_exists("subtable_copy"), "subtable_copy");
		test.assert_true(race.table_exists("subtable_ref"), "subtable_ref");
		
		test.assert_equals(6, race.tables.demotable.loot_count);
		test.assert_equals(1, race.tables.subtable_copy.loot_count);
		test.assert_equals(1, race.tables.subtable_ref.loot_count);
	};

	ut.tests.global_cache_ok = function(test, data) {
		var race = data.t;
		
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var names = struct_get_names(cache);
		
		test.assert_equals(3, array_length(names));
		test.assert_not_null(vsget(cache, "demotable"), "demotable");
		test.assert_not_null(vsget(cache, "subtable_copy"), "subtable_copy");
		test.assert_not_null(vsget(cache, "subtable_ref"), "subtable_ref");
		
		test.assert_equals(6, cache.demotable.loot_count);
		test.assert_equals(1, cache.subtable_copy.loot_count);
		test.assert_equals(1, cache.subtable_ref.loot_count);
	};

	ut.tests.add_table_manually_ok = function(test, data) {
		var race = data.t;
		
		race.add_table(new RaceLootTable(race, "_temp", {
			loot_count: 3,
			items: {
				some: {type: "something", always: 0, unique: 0, enabled: 1, chance : 10.0, }
			}
		}));
		
		test.assert_true(race.table_exists("_temp"), "_temp exists");

		// now test, that this temp table is NOT in the global cache
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var names = struct_get_names(cache);
		test.assert_null(vsget(cache, "_temp"), "cache hit");
		
		// now remove the table
		race.remove_table("_temp");
		test.assert_false(race.table_exists("_temp"), "_temp gone");
	}

	ut.tests.clone_table_ok = function(test, data) {
		var race = data.t;
		
		var ori = race.get_table("demotable");
		var tbl = race.clone_table("demotable");
		test.assert_true(string_starts_with(tbl.name, __RACE_TEMP_TABLE_PREFIX), "temp name");
		
		test.assert_equals(6, tbl.loot_count, "clone count");
		
		// change the loot count - the original may NOT change
		tbl.loot_count = 42;
		test.assert_equals(42, tbl.loot_count, "modified tbl count");
		test.assert_equals( 6, ori.loot_count, "modified ori count");
		
		// change an inner item to ensure, even the sub structs are clones
		tbl.items.object.chance = 999;
		test.assert_equals(999, tbl.items.object.chance, "modified tbl chance");
		test.assert_equals( 10, ori.items.object.chance, "modified ori chance");
	}

	ut.tests.clear_local_ok = function(test, data) {
		var race = data.t;
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var rnames = struct_get_names(race.tables);
		var cnames = struct_get_names(cache);
		
		// make sure, 3 tables in race and cache
		test.assert_equals(3, array_length(rnames), "before clear race" );
		test.assert_equals(3, array_length(cnames), "before clear cache");
		
		// now only race is deleted, cache still alive
		race.clear(false);
		rnames = struct_get_names(race.tables);
		cnames = struct_get_names(cache);
		test.assert_equals(0, array_length(rnames), "after local clear race" );
		test.assert_equals(3, array_length(cnames), "after local clear cache");

	}

	ut.tests.clear_global_ok = function(test, data) {
		var race = data.t;
		test.assert_not_null(vsget(__RACE_CACHE, race.__cache_name), "cache");
		var cache = __RACE_CACHE[$ race.__cache_name];
		
		var rnames = struct_get_names(race.tables);
		var cnames = struct_get_names(cache);
		
		// make sure, 3 tables in race and cache
		test.assert_equals(3, array_length(rnames), "before clear race" );
		test.assert_equals(3, array_length(cnames), "before clear cache");
		
		// now both are cleared		
		race.clear(true);
		rnames = struct_get_names(race.tables);
		cnames = struct_get_names(cache);
		test.assert_equals(0, array_length(rnames), "after global clear race" );
		test.assert_equals(0, array_length(cnames), "after global clear cache");
	}

	ut.tests.reset_table_loaded_ok = function(test, data) {
		var race = data.t;
		
		test.assert_equals(6, race.tables.demotable.loot_count);
		
		// modify the loot count, reset non-recursive, must be 6 again
		race.tables.demotable.loot_count = 42;
		race.tables.subtable_ref.items.object.chance = 99;
		
		race.reset_table("demotable", false);
		test.assert_equals(6 , race.tables.demotable.loot_count, "loot count non-recursive");
		test.assert_equals(99, race.tables.subtable_ref.items.object.chance, "chance non-recursive");
		
		race.tables.demotable.loot_count = 42;
		race.reset_table("demotable");
		test.assert_equals(6 , race.tables.demotable.loot_count, "loot count recursive");
		test.assert_equals(10, race.tables.subtable_ref.items.object.chance, "chance recursive");
	}

	ut.tests.reset_table_cloned_ok = function(test, data) {
		var race = data.t;
		var tbl = race.clone_table("demotable");
		
		tbl.loot_count = 42;
		race.reset_table(tbl.name);
		// still 42, as temp tables can't be reset
		test.assert_equals(42, tbl.loot_count);
	}
	
	ut.tests.reset_manual_table_ok = function(test, data) {
		var race = data.t;
		var tbl = new RaceLootTable(race, "_temp", {
			loot_count: 3,
			items: {
				some: {type: "something", always: 0, unique: 0, enabled: 1, chance : 10.0, }
			}
		});

		race.add_table(tbl);
		tbl.loot_count = 42;
		race.reset_table(tbl.name);
		// still 42, as temp tables can't be reset
		test.assert_equals(42, tbl.loot_count);
	}

	ut.run();
}
