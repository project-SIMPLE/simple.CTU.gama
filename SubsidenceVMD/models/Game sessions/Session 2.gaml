
model Session2

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
	
	
	point player_size <- {0.45,0.45};
	point player_1_position <- {0.025,0.025};
	point player_2_position <- {0.525,0.025};
	point player_3_position <- {0.025,0.525};
	point player_4_position <- {0.525,0.525};
	
	
	
	
	output {
		display "Main display" background: #black type: 2d axes: false {
			agents "P1 background" value: [GPlayLand[0]]  size: {0.5,0.5} position: {0,0} refresh: false;
			image image_file("../includes/scene.jpg") refresh: false size: player_size position: player_1_position;
			agents "P1 Tree" value: GPlayLand[0].trees  size: player_size position: player_1_position;
			agents "P1 warning" value: GPlayLand[0].warnings size: player_size position: player_1_position;
			agents "P1 Pumper" value: GPlayLand[0].pumpers  size: player_size position: player_1_position;
			agents "P1 enemy" value: GPlayLand[0].enemies  size: player_size position: player_1_position;
			agents "P1 fresh water" value: GPlayLand[0].enemies  size: player_size position: player_1_position;
			agents "P1" value: unity_player where (each.myland = GPlayLand[0]) transparency: 0.5  size: player_size position: player_1_position;
			
			agents "P2 background" value: [GPlayLand[1]]  size: {0.5,0.5} position: {0.5,0} refresh: false;
			image image_file("../includes/scene.jpg")  refresh: false size: player_size position: player_2_position;
			agents "P2 Tree" value: GPlayLand[1].trees size: player_size position: player_2_position;
			agents "P2 warning" value: GPlayLand[1].warnings size: player_size position: player_2_position;
			agents "P2 Pumper" value: GPlayLand[1].pumpers size: player_size position: player_2_position;
			agents "P2 enemy" value: GPlayLand[1].enemies size: player_size position: player_2_position;
			agents "P2 fresh water" value: GPlayLand[0].enemies  size: player_size position: player_2_position;
			agents "P2" value:  unity_player where (each.myland = GPlayLand[1]) transparency: 0.5 size: player_size position: player_2_position;
		
			agents "P3 background" value: [GPlayLand[2]]  size: {0.5,0.5} position: {0.0,0.5} refresh: false;
			image image_file("../includes/scene.jpg") refresh: false  size: player_size position: player_3_position;
			agents "P3 warning" value: GPlayLand[2].warnings size: player_size position: player_3_position;
			agents "P3 warning" value: GPlayLand[2].warnings size: player_size position: player_3_position;
			agents "P3 Pumper" value: GPlayLand[2].pumpers size: player_size position: player_3_position;
			agents "P3 enemy" value: GPlayLand[2].enemies size: player_size position: player_3_position;
			agents "P3 fresh water" value: GPlayLand[0].enemies  size: player_size position: player_3_position;
			agents "P3" value: unity_player where (each.myland = GPlayLand[2]) transparency: 0.5 size: player_size position: player_3_position;

			agents "P4 background" value: [GPlayLand[3]]  size: {0.5,0.5} position: {0.5,0.5} refresh: false;
			image image_file("../includes/scene.jpg")  refresh: false size: player_size position: player_4_position;
			agents "P4 Tree" value: GPlayLand[3].trees  size: player_size position: player_4_position;
			agents "P4 warning" value: GPlayLand[3].warnings  size: player_size position: player_4_position;
			agents "P4 Pumper" value: GPlayLand[3].pumpers  size: player_size position: player_4_position;
			agents "P4 enemy" value: GPlayLand[3].enemies  size: player_size position: player_4_position;
			agents "P4 fresh water" value: GPlayLand[0].enemies  size: player_size position: player_4_position;
			agents "P4" value:  unity_player where (each.myland = GPlayLand[3]) transparency: 0.5  size: player_size position: player_4_position;
		}

	}

}
