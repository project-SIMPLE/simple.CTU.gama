/**
* Name: CommonVR
* Based on the internal empty template. 
* Author: patricktaillandier
* Tags: 
*/


model CommonVR

import "Global.gaml"  


species unity_linker parent: abstract_unity_linker {
//name of the species used to represent a Unity player
	string player_species <- string(unity_player);
	float min_player_position_update_duration <- 0.1;

	//in this model, information about other player will be automatically sent to the Player at every step, so we set do_info_world to true
	bool do_send_world <- true;

	//number of players in the game
	int number_players <- 1 max: 1;

	//max number of players that can play the game
	int max_num_players <- number_players;

	//min number of players to start the simulation
	int min_num_players <- 99999;

	
	

	
	reflex when: cycle = 0 {
		do send_message(unity_player as list, ["readyToStart"::""]);
	}


	point toGAMACoordinate(int x, int y) {
		float xa <- 3550.0;
		float xb <- 188639.0;
		float ya <- -2387.0;
		float yb <- 151614.0;
		return {x/precision * xa + xb, y/precision * ya + yb};
	}

	action create_trees(string idP, list<string> idTs, list<int> xs, list<int> ys) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		loop i from: 0 to: length(idTs) -1 {
			string idT <- idTs[i];
			int x <- xs[i];
			int y <- ys[i];
			point pt <- toGAMACoordinate(x,y);
			
			create tree {
				_id <- idT;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.trees << self;
				location <- pt;
			}	
		}
	}
	
	action delete_tree(string idP, string idT) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		tree t <- Pl.myland.trees first_with (each._id = idT);
		Pl.myland.trees >> t;
		ask t { 
			do die;
		}
	}
	action move_create_pumper(string idP, string idwp, int x, int y) {
		point pt <- toGAMACoordinate(x,y);
		unity_player Pl <- first(unity_player where (each.name = idP));
		Pumper wp <- Pl.myland.pumpers first_with (each._id = idwp);
		if (wp != nil) {
			wp.location <- pt;
			wp.my_cell <- cell(wp.location);
		} else {
			create Pumper {
				_id <- idwp;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.pumpers << self;
				location <- pt;
				my_cell <- cell(location);
			}
		} 
	}
	
	action delete_water_pump(string idP, string idwp) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		Pumper wp <- Pl.myland.pumpers first_with (each._id = idwp);
		Pl.myland.pumpers >> wp;
		ask wp {
			do die;
		}
	}
	
	
	action update_salty_water(string idP, list<string> sws, list<int> xs, list<int> ys) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		list<enemy> to_remove <- enemy as list;
		loop i from: 0 to: length(sws) -1 {
			string idsw <- sws[i];
			int x <- xs[i];
			int y <- ys[i];
			point pt <- toGAMACoordinate(x,y);
			enemy sw <- Pl.myland.enemies first_with (each._id = idsw);
			if (sw != nil) {
				sw.location <- pt;
				to_remove >> sw;
			} else {
				create enemy {
					_id <- idsw;
					playerLand_ID <- Pl.myland.playerLand_ID;
					Pl.myland.enemies << self;
					location <- pt;
				} 
			}
		}
		if not empty(to_remove) {
			ask to_remove {
				do die;
			}
		}
	} 
	
	
	action update_fresh_water(string idP, list<string> fws, list<int> xs, list<int> ys) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		list<freshwater> to_remove <- freshwater as list;
		loop i from: 0 to: length(fws) -1 {
			string idfw <- fws[i];
			int x <- xs[i];
			int y <- ys[i];
			point pt <- toGAMACoordinate(x,y);
			freshwater sw <- Pl.myland.fresh_waters first_with (each._id = idfw);
			if (sw != nil) {
				sw.location <- pt;
				to_remove >> sw;
			} else {
				create freshwater {
					_id <- idfw;
					playerLand_ID <- Pl.myland.playerLand_ID;
					Pl.myland.fresh_waters << self;
					location <- pt;
				} 
			}
		}
		if not empty(to_remove) {
			ask to_remove {
				do die;
			}
		}
	}  
	
}

species unity_player parent: abstract_unity_player {
//size of the player in GAMA
	float player_size <- 1500.0;
	GPlayLand myland;
	//color of the player in GAMA
	rgb color <- myland.my_team.color; 

	//vision cone distance in GAMA 
	float cone_distance <- 10.0 * player_size;

	//vision cone amplitude in GAMA
	float cone_amplitude <- 90.0;

	//rotation to apply from the heading of Unity to GAMA
	float player_rotation <- 90.0;

	//display the player
	bool to_display <- true;

	init {
		myland <- GPlayLand[length(unity_player) - 1];
		write myland;
		myland.cntDem <- 0;
		myland.subside <- false;
		do Restart(myland.playerLand_ID);
	}

	action Restart (int id) {
		ask tree where (each.playerLand_ID = id) {
			do die;
		}

		ask warning where (each.playerLand_ID = id) {
			do die;
		}

		ask enemy where (each.playerLand_ID = id) {
			do die;
		}

	
		ask Pumper where (each.playerLand_ID = id) {
			do die;
		}


	}

	float z_offset <- 2.0;

	reflex ss {
		heading <- -heading;
		location <- (location * 100) + myland.location;
	}

	aspect default {
		if to_display {
			draw cube(player_size / 2.0) at: location + {0, 0, z_offset} color: color;
			draw player_perception_cone() color: rgb(color, 0.5);
		}

	}

}
