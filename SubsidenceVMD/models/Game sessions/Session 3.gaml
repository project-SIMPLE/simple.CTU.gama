model Session3

import "../CommonVR.gaml"
global{
	
}
experiment session3 autorun: false type: unity {
//minimal time between two simulation step
	float minimum_cycle_duration <- 0.01;

	//name of the species used for the unity_linker
	string unity_linker_species <- string(unity_linker);

	//allow to hide the "map" display and to only display the displayVR display 
	list<string> displays_to_hide <- ["Digital Elevation Model", "W1", "Subsidence - Groundwater extracted"];
	
	parameter "let_gama_manage_time" var: let_gama_manage_game <- true among:[true];

	//action called by the middleware when a player connects to the simulation
	action create_player (string id) {
		ask unity_linker {
			do create_player(id);
		} 

	}
	//action called by the middleware when a plyer is remove from the simulation
	action remove_player (string id_input) {
		if (not empty(unity_player)) {
			ask unity_linker {
				if (id_input in player_agents.keys) {
					do restart(id_input);
					ask unity_player(player_agents[id_input]) {
						do die;	
					}
					remove key:id_input from: player_agents ;
				}
				
			}

		}

	}

	point player_size <- {0.45, 0.45};
	point p_size <- {0.75, 0.75};
	point player_1_position <- {0.025, 0.025};
	point p1_position <- {-1e2, 2e4};
	point player_2_position <- {0.525, 0.025};
	point player_3_position <- {0.025, 0.525};
	point player_4_position <- {0.525, 0.525};
	output synchronized: true {
		layout #split consoles: false parameters: false toolbars: false tabs: false controls: false;
		display "P1" type: 3d axes: false {
		//			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};
			camera 'default' location: {182996.6598, 120195.8174, 191377.8334} target: {183000.0, 120195.8174, 0.0};
			graphics "image11" refresh: true {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw rectangle(1.5e5, 2.8e5).contour + 5e3 color: #violet at:location+{0,0,0.001};
			}

			graphics "image12" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 0;
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: font("Helvetica", 24, #bold) at: {-20000, 100} color: #yellow;
				draw "Nước sạch: " + (length(GPlayLand[nP].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {-20000, 18000} color: #yellow;
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: font("Helvetica", 24, #bold) at: {-20000, 38000} color: #yellow;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {-20000, 58000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "Time: " + GPlayLand[nP].cntTime at: {-20000, 78000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "P1 " + (length(unity_player) > 0 ? (unity_player[nP].name) : "") at: {-20000, 98000} font: font("Helvetica", 24, #bold) color: #yellow;
			}

			agents "P1 Tree" value: GPlayLand[0].trees.values;
			agents "P1 warning" value: GPlayLand[0].enemy_spawners.values;
			agents "P1 Pumper" value: GPlayLand[0].pumpers.values;
			agents "P1 enemy" value: GPlayLand[0].enemies.values;
			agents "P1 fresh water" value: GPlayLand[0].fresh_waters.values;
			agents "P1" value: unity_player where (each.myland = GPlayLand[0]) transparency: 0.25;
		}

		display "P2" type: 3d axes: false {
		//			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};
			camera 'default' location: {182996.6598, 120195.8174, 191377.8334} target: {183000.0, 120195.8174, 0.0};

			/////P2
			//			agents "P2 background" value: [GPlayLand[1]] size: {0.5, 0.5} position: {0.5, 0} refresh: false;
			graphics "image21" refresh: false {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw rectangle(1.5e5, 2.8e5).contour + 5e3 color: #cyan at:location+{0,0,0.001};
			}

			graphics "image22" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 1;
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: font("Helvetica", 24, #bold) at: {-20000, 100} color: #yellow;
				draw "Nước sạch: " + (length(GPlayLand[nP].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {-20000, 18000} color: #yellow;
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: font("Helvetica", 24, #bold) at: {-20000, 38000} color: #yellow;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {-20000, 58000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "Time: " + GPlayLand[nP].cntTime at: {-20000, 78000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "P2 " + (length(unity_player) > 1 ? (unity_player[nP].name) : "") at: {-20000, 98000} font: font("Helvetica", 24, #bold) color: #yellow;
			}

			agents "P2 Tree" value: GPlayLand[1].trees.values;
			agents "P2 warning" value: GPlayLand[1].enemy_spawners.values;
			agents "P2 Pumper" value: GPlayLand[1].pumpers.values;
			agents "P2 enemy" value: GPlayLand[1].enemies.values;
			agents "P2 fresh water" value: GPlayLand[1].fresh_waters.values;
			agents "P2" value: unity_player where (each.myland = GPlayLand[1]) transparency: 0.5;
		}

		display "P3" type: 3d axes: false {
		//			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};
			camera 'default' location: {182996.6598, 153208.4937, 191377.8334} target: {183000.0, 153208.4937, 0.0};
			/////P3
			//			agents "P3 background" value: [GPlayLand[2]] size: {0.5, 0.5} position: {0.0, 0.5} refresh: false;
			graphics "image31" refresh: false {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw rectangle(1.5e5, 2.8e5).contour + 5e3 color: #violet at:location+{0,0,0.001};
			}

			graphics "image32" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 2;
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: font("Helvetica", 24, #bold) at: {-20000, 100} color: #yellow;
				draw "Nước sạch: " + (length(GPlayLand[nP].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {-20000, 18000} color: #yellow;
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: font("Helvetica", 24, #bold) at: {-20000, 38000} color: #yellow;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {-20000, 58000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "Time: " + GPlayLand[nP].cntTime at: {-20000, 78000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "P3 " + (length(unity_player) > 2 ? (unity_player[nP].name) : "") at: {-20000, 98000} font: font("Helvetica", 24, #bold) color: #yellow;
			}

			agents "P3 Tree" value: GPlayLand[2].trees.values;
			agents "P3 warning" value: GPlayLand[2].enemy_spawners.values;
			agents "P3 Pumper" value: GPlayLand[2].pumpers.values;
			agents "P3 enemy" value: GPlayLand[2].enemies.values;
			agents "P3 fresh water" value: GPlayLand[2].fresh_waters.values;
			agents "P3" value: unity_player where (each.myland = GPlayLand[2]) transparency: 0.5;
		}

		display "P4" type: 3d axes: false {
		//			camera 'default' location: {182997.1146, 136750.0, 165319.368} target: {183000.0, 136750.0, 0.0};
			camera 'default' location: {182996.6598, 153208.4937, 191377.8334} target: {183000.0, 153208.4937, 0.0};
			/////P4
			//			agents "P4 background" value: [GPlayLand[3]] size: {0.5, 0.5} position: {0.5, 0.5} refresh: false;
			graphics "image41" refresh: false {
				draw rectangle(world.shape.height * 1177 / 1421, world.shape.height) texture: image_file("../includes/scene.png");
				draw rectangle(1.5e5, 2.8e5).contour + 5e3 color: #cyan at:location+{0,0,0.001};
			}

			graphics "image42" refresh: true rotate: -90 size: {0.45, 0.45} position: {9e4, 6e4, 0.01} {
				int nP <- 3;
				draw "Cây chết: " + ((GPlayLand[nP].deadtrees)) font: font("Helvetica", 24, #bold) at: {-20000, 100} color: #yellow;
				draw "Nước sạch: " + (length(GPlayLand[nP].fresh_waters.values)) font: font("Helvetica", 24, #bold) at: {-20000, 18000} color: #yellow;
				draw "Máy bơm: " + (length(GPlayLand[nP].pumpers.values)) font: font("Helvetica", 24, #bold) at: {-20000, 38000} color: #yellow;
				draw "Sụt lún: " + (mean(cell collect each.subsidence(GPlayLand[nP].playerLand_ID)) with_precision 2) at: {-20000, 58000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "Time: " + GPlayLand[nP].cntTime at: {-20000, 78000} font: font("Helvetica", 24, #bold) color: #yellow;
				draw "P4 " + (length(unity_player) > 3 ? (unity_player[nP].name) : "") at: {-20000, 98000} font: font("Helvetica", 24, #bold) color: #yellow;
			}

			agents "P4 Tree" value: GPlayLand[3].trees.values;
			agents "P4 warning" value: GPlayLand[3].enemy_spawners.values;
			agents "P4 Pumper" value: GPlayLand[3].pumpers.values;
			agents "P4 enemy" value: GPlayLand[3].enemies.values;
			agents "P4 fresh water" value: GPlayLand[3].fresh_waters.values;
			agents "P4" value: unity_player where (each.myland = GPlayLand[3]) transparency: 0.5;
		}

	}

}
