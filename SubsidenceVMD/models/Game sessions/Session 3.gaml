
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

	point player_size <- {0.45, 0.45};
	point player_1_position <- {0.025, 0.025};
	point player_2_position <- {0.525, 0.025};
	point player_3_position <- {0.025, 0.525};
	point player_4_position <- {0.525, 0.525};
	output {
		layout #split consoles:false parameters:false;
		display "Main display" background: #black type: 2d axes: false {
			agents "P1 background" value: [GPlayLand[0]] size: {0.5, 0.5} position: {0, 0} refresh: false;
			graphics "image1" refresh: false size: player_size position: player_1_position {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw "Cây chết: " + ((GPlayLand[0].deadtrees)) font: font("Helvetica", 24, #bold) at: {-20000, 100} color: #red;
				draw "Nước sạch: " + (length(GPlayLand[0].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {-20000, 18000} color: #red;
				draw "Máy bơm: " + (length(GPlayLand[0].pumpers.values)) font: font("Helvetica", 24, #bold) at: {-20000, 38000} color: #red;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[0].playerLand_ID))) at: {-20000, 58000} font: font("Helvetica", 24, #bold) color: #red;
				draw "Time: " + current_date.hour+":"+ current_date.minute  at: {-20000, 78000} font: font("Helvetica", 24, #bold) color: #red;
			}
			agents "P1 Tree" value: GPlayLand[0].trees.values size: player_size position: player_1_position;
			agents "P1 warning" value: GPlayLand[0].enemy_spawners.values size: player_size position: player_1_position+{0,0,0.1};
			agents "P1 Pumper" value: GPlayLand[0].pumpers.values size: player_size position: player_1_position;
			agents "P1 enemy" value: GPlayLand[0].enemies.values size: player_size position: player_1_position;
			agents "P1 fresh water" value: GPlayLand[0].fresh_waters.values size: player_size position: player_1_position;
			agents "P1" value: unity_player where (each.myland = GPlayLand[0]) transparency: 0.25 size: player_size position: player_1_position;
			
			
			agents "P2 background" value: [GPlayLand[1]] size: {0.5, 0.5} position: {0.5, 0} refresh: false;
			graphics "image2" refresh: false size: player_size position: player_2_position {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw "Cây chết: " + ((GPlayLand[0].deadtrees)) font: font("Helvetica", 24, #bold) at: {3e5, 100} color: #red;
				draw "Nước sạch: " + (length(GPlayLand[0].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {3e5, 18000} color: #red;
				draw "Máy bơm: " + (length(GPlayLand[1].pumpers.values)) font: font("Helvetica", 24, #bold) at: {3e5, 38000} color: #red;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[1].playerLand_ID))) at: {3e5, 58000} font: font("Helvetica", 24, #bold) color: #red;
				draw "Time: " + current_date.hour + ":" + current_date.minute at: {3e5, 78000} font: font("Helvetica", 24, #bold) color: #red;
			}
			agents "P2 Tree" value: GPlayLand[1].trees.values size: player_size position: player_2_position;
			agents "P2 warning" value: GPlayLand[1].enemy_spawners.values size: player_size position: player_2_position;
			agents "P2 Pumper" value: GPlayLand[1].pumpers.values size: player_size position: player_2_position;
			agents "P2 enemy" value: GPlayLand[1].enemies.values size: player_size position: player_2_position;
			agents "P2 fresh water" value: GPlayLand[1].fresh_waters.values size: player_size position: player_2_position;
			agents "P2" value: unity_player where (each.myland = GPlayLand[1]) transparency: 0.5 size: player_size position: player_2_position;
			
			
			agents "P3 background" value: [GPlayLand[2]] size: {0.5, 0.5} position: {0.0, 0.5} refresh: false;
			graphics "image3" refresh: false size: player_size position: player_3_position {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw "Cây chết: " + ((GPlayLand[0].deadtrees)) font: font("Helvetica", 24, #bold) at: {-20000, 100} color: #yellow;
				draw "Nước sạch: " + (length(GPlayLand[0].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {-20000, 18000} color: #yellow;
				draw "Máy bơm: " + (length(GPlayLand[2].pumpers.values)) font: font("Helvetica", 24, #bold) at: {-20000, 38000} color: #yellow;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[2].playerLand_ID))) at: {-20000, 58000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "Time: " + current_date.hour + ":" + current_date.minute at: {-20000, 78000} font: font("Helvetica", 24, #bold) color: #yellow;
			}
			agents "P3 Tree" value: GPlayLand[2].trees.values size: player_size position: player_3_position;
			agents "P3 warning" value: GPlayLand[2].enemy_spawners.values size: player_size position: player_3_position;
			agents "P3 Pumper" value: GPlayLand[2].pumpers.values size: player_size position: player_3_position;
			agents "P3 enemy" value: GPlayLand[2].enemies.values size: player_size position: player_3_position;
			agents "P3 fresh water" value: GPlayLand[2].fresh_waters.values size: player_size position: player_3_position;
			agents "P3" value: unity_player where (each.myland = GPlayLand[2]) transparency: 0.5 size: player_size position: player_3_position;
			
			
			agents "P4 background" value: [GPlayLand[3]] size: {0.5, 0.5} position: {0.5, 0.5} refresh: false;
			graphics "image4" refresh: false size: player_size position: player_4_position {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw "Cây chết: " + ((GPlayLand[0].deadtrees)) font: font("Helvetica", 24, #bold) at: {3e5, 100} color: #yellow;
				draw "Nước sạch: " + (length(GPlayLand[0].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {3e5, 18000} color: #yellow;
				draw "Máy bơm: " + (length(GPlayLand[2].pumpers.values)) font: font("Helvetica", 24, #bold) at: {3e5, 38000} color: #yellow;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[2].playerLand_ID))) at: {3e5, 58000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "Time: " + current_date.hour + ":" + current_date.minute at: {3e5, 78000} font: font("Helvetica", 24, #bold) color: #yellow;
			}
			agents "P4 Tree" value: GPlayLand[3].trees.values size: player_size position: player_4_position;
			agents "P4 warning" value: GPlayLand[3].enemy_spawners.values size: player_size position: player_4_position;
			agents "P4 Pumper" value: GPlayLand[3].pumpers.values size: player_size position: player_4_position;
			agents "P4 enemy" value: GPlayLand[3].enemies.values size: player_size position: player_4_position;
			agents "P4 fresh water" value: GPlayLand[3].fresh_waters.values size: player_size position: player_4_position;
			agents "P4" value: unity_player where (each.myland = GPlayLand[3]) transparency: 0.5 size: player_size position: player_4_position;
		
			
			graphics "common" refresh: false size: player_size position: {0.275, 0.275} {
				draw circle(100000) color:#grey;
				draw "Sụt lún toàn cục: " + (mean(cell collect each.grid_value)) at: {1.1e5, 1.4e5} font: font("Helvetica", 24, #bold) color: #yellow;
				
			}
		}

	}

}
