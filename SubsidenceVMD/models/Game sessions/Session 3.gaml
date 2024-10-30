
model Session3

import "../CommonVR.gaml"  


experiment session3  autorun: false type: unity  {
//minimal time between two simulation step
	float minimum_cycle_duration <- 0.01;

	//name of the species used for the unity_linker
	string unity_linker_species <- string(unity_linker);

	//allow to hide the "map" display and to only display the displayVR display 
	list<string> displays_to_hide <- ["Digital Elevation Model", "W1", "Subsidence - Groundwater extracted"];

	//action called by the middleware when a player connects to the simulation
	action create_player (string id) {
		ask unity_linker { 
			do create_player(id);
		} 
	}
 
	//action called by the middleware when a plyer is remove from the simulation
	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}

		}

	}

	
	
	map<rgb, rgb> text_colors <- [#green::#white, #yellow::#black, #red::#white, #blue::#white];
	font text <- font("Arial", 24, #bold);
	font title <- font("Arial", 18, #bold);
	int x_origin <- 50;
	int x_interval <- 60;
	int y_interval <- 40; 
	int box_size <- 30;
	
	output {
		
		display "Groundwater extracted" type: 3d background: #black axes: false {
//			camera 'default' location: {243237.2195, 132619.9172, 310954.9886} target: {243237.2195, 132614.49, 0.0};
		
			overlay position: {0 #px, 0 #px} size: {0 #px, 0 #px} background: #white border: #white rounded: false {
				float y <- 2 * y_interval #px;
				draw rectangle((10 * x_interval) #px, 10 * box_size #px) at: {x_origin + (4 * x_interval) #px, y} color: rgb(0, 0, 0, 0.5);
				draw "Team score" at: {x_origin + (1 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				draw "Player" at: {x_origin + (4 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				draw "Score" at: {x_origin + (6 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				draw "Time left" at: {x_origin + (8 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				map<rgb, team> temp <- [];
				

				loop p over: reverse(temp.pairs) {
					draw rectangle((10 * x_interval) #px, box_size #px) at: {x_origin + (4 * x_interval) #px, y} color: (p.key);
					//draw rectangle(x_interval #px, box_size #px) at: {x_interval / 2, y} color: p.key;
					draw string(p.value.score) at: {x_origin + (1 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
					draw "#" + p.value.generation at: {x_origin + (4 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
					/*GPlayLand last <- last(p.value.players);
					if (last != nil) {
						draw string(last.current_score) at: {x_origin + (6 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
						draw string(last.remaining_time) + " sec" at: {x_origin + (8 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
					}*/
					y <- y + y_interval #px;
				}


			}
			species Pumper;
		}

		

	}

}
