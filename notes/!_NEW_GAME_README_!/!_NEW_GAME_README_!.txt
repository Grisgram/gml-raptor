
	Veeeeeeeeeeeery important!!
	
	Don't forget to set (or automate) the included file "version.json" to the correct game version!
	Best practise is to create this file through your build job, if you have one.
	
	-----------------------------
	If you're making a HTML game:
	-----------------------------
	Do these steps before you do ANYTHING ELSE
	
		- set rmMain, rmPlay and rmStartup (green game_setup folder)
		  to 1920x940 resolution (room, cam, viewport)!
		
		- Game Options - HTML - General - Index.html back to DEFAULT!
		
		- Start the game
		
		- In the Browser press Shift-Ctrl-I (inspect) and look at the Source if index.html
		
		- In line ~82/83 you find something like that:
		  <script type="text/javascript" src="game/default-game.js?AWDAC=1242070312"></script>
		  
		- This src part contains the name of your game project and its ID
		  src="game/default-game.js?AWDAC=1242070312"
		  
		- Copy this part at the corresponding position in index.html in the included files

		- Then you can set back to "index.html" in the game options
		
		- TEST NOW!!
		
		- If you see the flag in the browser, all is good. Go ahead, start developing!
