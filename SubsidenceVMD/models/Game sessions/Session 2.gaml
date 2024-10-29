
model LoadSubsi_model_VR

import "../CommonVR.gaml"


experiment session2 parent: main autorun: false type: unity  {
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

			//build invisible walls surrounding the free_area geometry
			//			do build_invisible_walls(player: last(unity_player), //player to send the information to
			//			id: "wall_for_world", //id of the walls
			//			height: 40.0, //height of the walls
			//			wall_width: 0.5, //width ot the walls
			//			geoms: [world.shape] //geometries used to defined the walls - the walls will be generated from the countour of these geometries
			//);
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
		display "P1" background: #black type: 3d axes: false {
			camera 'default' location: {327596.9917, 58818.3336, 12993.7722} target: {327596.9917, 58818.1068, 0.0};
			species GPlayLand aspect:d2;
			species tree;
			species SluiceGate;
			species Lake;
			species warning position: {0, 0, 0.1};
			species Pumper;
			species enemy;
			species unity_player transparency: 0.5; 
		}

		display "P2" background: #black type: 3d axes: false {
			camera 'default' location: {317651.54, 108884.4166, 17807.3996} target: {317651.54, 108884.1058, 0.0};
			species GPlayLand aspect:d2;
			species unity_player;
			species tree;
			species SluiceGate;
			species Lake;
			species warning;
			species Pumper;
			species enemy; 
		}

		display "P3" background: #black type: 3d axes: false {
			camera 'default' location: {264110.5481, 148732.6871, 20206.4384} target: {264110.5481, 148732.3344, 0.0};
			species GPlayLand aspect:d2;
			species unity_player;
			species tree;
			species SluiceGate;
			species Lake;
			species warning;
			species Pumper;
			species enemy;
		}

		display "P4" background: #black type: 3d axes: false {
			camera 'default' location: {177075.0127, 170800.3465, 20978.6759} target: {177075.0127, 170799.9803, 0.0};
			species GPlayLand aspect:d2;
			species unity_player transparency: 0.5;
			species tree;
			species SluiceGate;
			species Lake;
			species warning;
			species Pumper;
			species enemy;
		}

	}

}
