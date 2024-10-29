
model LoadSubsi_model_VR

import "../CommonVR.gaml"
 

experiment session2  autorun: false type: unity  {
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

		write unity_player as list;
	}

	//action called by the middleware when a plyer is remove from the simulation
	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}

		}

	}

	//variable used to avoid to move too fast the player agent
	float t_ref;
	
	
	map<rgb, rgb> text_colors <- [#green::#white, #yellow::#black, #red::#white, #blue::#white];
	font text <- font("Arial", 24, #bold);
	font title <- font("Arial", 18, #bold);
	int x_origin <- 50;
	int x_interval <- 60;
	int y_interval <- 40;
	int box_size <- 30;
	
	output {
		layout #split toolbars:true;
		display "P1" background: #black type: 3d axes: false {
			image image_file("../includes/scene.jpg");
			agents "P1 Tree" value: GPlayLand[0].trees;
			agents "P1 warning" value: GPlayLand[0].warnings;
			agents "P1 Pumper" value: GPlayLand[0].pumpers;
			agents "P1 enemy" value: GPlayLand[0].enemies;
			agents "P1" value: [unity_player[0]] transparency: 0.5; 
		}

		display "P2" background: #black type: 3d axes: false {
			image image_file("../includes/scene.jpg");
			agents "P2 Tree" value: GPlayLand[1].trees;
			agents "P2 warning" value: GPlayLand[1].warnings;
			agents "P2 Pumper" value: GPlayLand[1].pumpers;
			agents "P2 enemy" value: GPlayLand[1].enemies;
			agents "P2" value: [unity_player[1]] transparency: 0.5; 
		}

		display "P3" background: #black type: 3d axes: false {
			image image_file("../includes/scene.jpg");
			agents "P3 warning" value: GPlayLand[2].warnings;
			agents "P3 warning" value: GPlayLand[2].warnings;
			agents "P3 Pumper" value: GPlayLand[2].pumpers;
			agents "P3 enemy" value: GPlayLand[2].enemies;
			agents "P3" value: [unity_player[2]] transparency: 0.5; 
		}

		display "P4" background: #black type: 3d axes: false {
			image image_file("../includes/scene.jpg");
			agents "P4 Tree" value: GPlayLand[3].trees;
			agents "P4 warning" value: GPlayLand[3].warnings;
			agents "P4 Pumper" value: GPlayLand[3].pumpers;
			agents "P4 enemy" value: GPlayLand[3].enemies;
			agents "P4" value: [unity_player[3]] transparency: 0.5; 
		}

	}

}
