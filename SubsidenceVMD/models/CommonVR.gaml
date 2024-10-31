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
	bool do_send_world <- false;

	//number of players in the game
	int number_players <- 1 max: 1;

	//max number of players that can play the game
	int max_num_players <- number_players;

	//min number of players to start the simulation
	int min_num_players <- 99999;

	list<point> init_locations <- [any_location_in(world) + {0,0,1}];
	

	
	reflex let_player_start when: cycle = 0 {
		do send_message(unity_player as list, ["readyToStart"::""]);
	}
	
	reflex send_fresh_water_spawn_rate when: every(pumper_rate_refresh_rate#cycle) {
		list<string> ids <- Pumper collect each._id;
		list<float> spawn_rate <- Pumper collect round(precision * each.fresh_water_generation_rate);
		do send_message(unity_player as list, ["pumpers"::ids, "spawnrates"::spawn_rate]);
	}


	point toGAMACoordinate(int x, int y) {
		float xa <- 2426.08;
		float xb <- 181088.094;
		float ya <- -2534.754;
		float yb <- 199992.122;
		return {x/precision * xa + xb, y/precision * ya + yb};
	}
	
	action update_player_pos(string idP,  int x, int y, int o) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		Pl.location <-  toGAMACoordinate(x,y);
		Pl.heading <- float(o/precision);
	}

	action create_trees(string idP, string idTsStr, string xsStr, string ysStr) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		list<string> idTs <- idTsStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));
		loop i from: 0 to: length(idTs) -2 {
			string idT <- idTs[i];
			int x <- xs[i];
			int y <- ys[i];
			point pt <- toGAMACoordinate(x,y);
			//write idT + " x: " + (x/precision)  + " y:" + (y/precision) + " pt: " + pt;
			create tree {
				_id <- idT;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.trees << self;
				location <- pt;
			}	
		}
		//write sample(GPlayLand[0].trees);
	}
	
	action delete_tree(string idP, string idT) {
		unity_player Pl <- first(unity_player where (each.name = idP));
		tree t <- Pl.myland.trees first_with (each._id = idT);
		Pl.myland.trees >> t;
		ask t { 
			do die;
		}
	}
	
	action move_create_warning(string idP, string idw, int x, int y) {
		point pt <- toGAMACoordinate(x,y);
		unity_player Pl <- first(unity_player where (each.name = idP));
		warning wp <- Pl.myland.warnings first_with (each._id = idw);
		if (wp != nil) {
			wp.location <- pt;
		} else {
			create warning {
				_id <- idw;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.warnings << self;
				location <- pt;
			}
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
	
	
	action update_salty_water(string idP, string swsStr, string xsStr, string ysStr) {
		list<string> sws <- swsStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));
		unity_player Pl <- first(unity_player where (each.name = idP));
		list<enemy> to_remove <- enemy as list;
		if (length(sws) > 1) {
			loop i from: 0 to: length(sws) -2 {
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
		}
		
		if not empty(to_remove) {
			ask to_remove {
				Pl.myland.enemies >> self;
				do die;
			}
		}
	} 
	
	
	action update_fresh_water(string idP,string fwsStr, string xsStr, string ysStr) {
		list<string> fws <- fwsStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));
		
		unity_player Pl <- first(unity_player where (each.name = idP));
		list<freshwater> to_remove <- freshwater as list;
		if (length(fws) > 1) {
			loop i from: 0 to: length(fws) -2 {
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
		}
		if not empty(to_remove) {
			ask to_remove {
				Pl.myland.fresh_waters >> self;
				do die;
			}
		}
	}  
	
}

species unity_player parent: abstract_unity_player {
//size of the player in GAMA
	float player_size <- 10000.0;
	GPlayLand myland;
	//color of the player in GAMA
	rgb color ; 

	//vision cone distance in GAMA 
	float cone_distance <- 5.0 * player_size;

	//vision cone amplitude in GAMA
	float cone_amplitude <- 90.0;

	//rotation to apply from the heading of Unity to GAMA
	float player_rotation <- 90.0;
	
	

	init {
		myland <- GPlayLand[length(unity_player) - 1];
		color <- myland.my_team.color;
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

	
	aspect default {
		draw square(player_size / 2.0) border:#black at: location + {0, 0, z_offset} color: color;
		draw player_perception_cone()border:#black color: rgb(color, 0.5);

	}

}
