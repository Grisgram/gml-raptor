
	Veeeeeeeeeeeery important!!
	
	Don't forget to set (or automate) the included file "version.json" to the correct game version!
	Best practise is to create this file through your build job, if you have one.
	
	-----------------------------
	If you're making a HTML game:
	-----------------------------
	Do these steps before you do ANYTHING ELSE
	
		- set rmMain and rmStartup (in the _GAME_SETUP_ folder)
		  to 1920x940 resolution (room, camera, viewport)!
		
		- Game Options - HTML - General - Index.html back to DEFAULT!
		
		- Start the game
		
		- In the Browser inspect the site with Shift-Ctrl-I and look at the Source of index.html
		
		- In line ~82/83 you find something like that (instead of "gml-raptor", your game name should be there):
		  <script type="text/javascript" src="game/gml-raptor.js?cachebust=435882189"></script>
		  
		- This src part contains the correct javascript file name
		  src="game/gml-raptor.js?cachebust=435882189"
		  
		- Copy this part at the corresponding position in index.html in the included files

		- Then you can set back to "index.html" in the game options
		
		- TEST NOW!!
		
		- If you see the flag in the browser, all is good. Go ahead, start developing!
