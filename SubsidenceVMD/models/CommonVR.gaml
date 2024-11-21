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

	
	//max number of players that can play the game
	int max_num_players <- 99999;

	//min number of players to start the simulation
	int min_num_players <- 99999;

	list<point> init_locations <- [any_location_in(world) + {0,0,1}];
	
	
	
	
	 
	action new_connection(string id) {
		
		current_time_def <- gama.machine_time + (duration_defense + duration_preparation) * 1000.0;
		if (id in player_agents.keys) {
			if (not let_gama_manage_game) {
				do restart(id);
				ask unity_player(player_agents[id]) {
					do die;	
				}
				remove key:id from: player_agents ;
				do create_player(id);
			} else {
				
			}
		} 
	}
	
	action restart(string id) {
		unity_player Pl <- player_agents[id];
		ask Pl.myland.trees {
			do die;
		}
		ask Pl.myland.pumpers {
			do die;
		}
		ask Pl.myland.fresh_waters {
			do die;
		}
		ask Pl.myland.enemies {
			do die;
		}
		ask Pl.myland.enemy_spawners {
			do die;
		} 
		Pl.myland.started<-false;
		Pl.myland.cntDem <- 0;
		Pl.myland.subside <- false;
	    Pl.myland.deadtrees<-0;
		Pl.myland.pumpers <- [];
		Pl.myland.trees <- [];
		Pl.myland.fresh_waters <- [];
		Pl.myland.enemies <- [];
		Pl.myland.enemy_spawners <- [];
		ask cell {
			water_level[Pl.myland.playerLand_ID] <- grid_value;
		}
		Pl.ready_to_start <- false;
	}
	
	action change_state(string idP, string new_state) {
		unity_player Pl <- player_agents[idP];
		Pl.current_state <- new_state;
	}
	
	action player_ready(string idP) {
		unity_player Pl <- player_agents[idP];
		Pl.ready_to_start <- true;
	}
	
	action player_finish_game(string idP) {
		write "END FOR " + idP;
		if (let_gama_manage_game) {
			unity_player Pl <- player_agents[idP];
			Pl.finish_game <- true;
		}
		
	}
	
	reflex let_player_start when: not empty(unity_player where !each.ready_to_start) {
		if (not let_gama_manage_game) {
			do send_message(unity_player where !each.ready_to_start, ["readyToStart"::""]);
		} else {
			do send_message(unity_player where !each.ready_to_start, ["startGame"::true, "time_prep"::duration_preparation,"time_def"::duration_defense ]);
	
		}
		
	} 
	
	
	reflex end_sequence when: (let_gama_manage_game) and empty(unity_player where not each.finish_game)  {
		write "END OF GAME";
		ask unity_player {
			finish_game <- false;
		} 
		current_time_def <- 0.0;
		ask world {
			do pause;
		}	
	}
	
	reflex send_fresh_water_spawn_rate when: every(pumper_rate_refresh_rate#cycle) {
		ask unity_player where not (dead(each) and each.ready_to_start) {
			list<string> ids <- myland.pumpers collect each._id;
			list<float> spawn_rate <-  myland.pumpers collect round(myself.precision * each.fresh_water_generation_rate);
			ask myself {
				do send_message([myself], ["pumpers"::ids, "spawnrates"::spawn_rate]);
			}
		}
		
	}

	reflex send_enemy_spawn_rate when: every(enemy_genetation_rate_refresh_rate#cycle) {
		ask unity_player where not (dead(each) and each.ready_to_start){
			list<string> ids <- myland.enemy_spawners collect each._id;
			list<float> spawn_rate <-  myland.enemy_spawners collect round(myself.precision * each.enemy_generation_rate);
			ask myself {
				do send_message([myself], ["enemyspawners"::ids, "spawnrates"::spawn_rate]);
			}
		}
	}

	reflex send_info_subsidence when: every(update_subsidence_refresh_rate#cycle) {
		list<float> waters <-list_with(length(GPlayLand), 0.0);
		float sum_water_init <- cell sum_of (each.grid_value);
		ask cell {
			loop i from: 0 to: length(GPlayLand) -1 {
				waters[i] <- waters[i] + water_level[i];
			}
		}
		ask unity_player where not (dead(each) and each.ready_to_start){
			
			list<int> subsidence_values <- cell collect each.subsidence(myland.playerLand_ID);
			float subsi_score<-(mean(cell collect each.subsidence(myland.playerLand_ID)) with_precision 2);
			ask myself {
				do send_message([myself], ["subsidences"::subsidence_values,"subsi_score"::subsi_score,"waterGlobal"::round(precision * sum(waters)/(length(GPlayLand) * sum_water_init)), "waterLocal"::round(precision * waters[myself.myland.playerLand_ID]/ sum_water_init)]);
			}
		}
	}


	point toGAMACoordinate(int x, int y) {
		float xa <- 2426.08;
		float xb <- 181088.094;
		float ya <- -2534.754;
		float yb <- 199992.122;
		return {x/precision * xa + xb, y/precision * ya + yb};  
//		return {y/precision * ya + yb,x/precision * xa + xb };
	}
	
	action update_player_pos(string idP,  int x, int y, int o, int remaining_time) {
		unity_player Pl <- player_agents[idP];
		Pl.location <-  toGAMACoordinate(x,y);
		Pl.heading <- float(o/precision)+90;
		Pl.to_display <- true;
		Pl.myland.cntTime <- max(0,remaining_time);
	}

	action create_trees(string idP, string idTsStr, string xsStr, string ysStr) {
//		ask GPlayLand {
//		 	ask trees{
//				do die;
//			}
//			trees <- [];
//		}
		unity_player Pl <- player_agents[idP];
		Pl.myland.started<-true;
		list<string> idTs <- idTsStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));
		
		loop i from: 0 to: length(xs) -1 {
			string idT <- idTs[i];
			int x <- xs[i];
			int y <- ys[i];
			point pt <- toGAMACoordinate(x,y);
			//write idT + " x: " + (x/precision)  + " y:" + (y/precision) + " pt: " + pt;
			create tree {
				_id <- idT;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.trees[idT] <- self;
				location <- pt;
			}	
		}
		//write sample(GPlayLand[0].trees);
	}
	
	action delete_tree(string idP, string idT) {
		unity_player Pl <- player_agents[idP];
		tree t <- Pl.myland.trees[idT];
		if (t != nil ){
				remove key: idT from: Pl.myland.trees ;				
				Pl.myland.deadtrees<-Pl.myland.deadtrees+1;
				
			ask t { 
				do die;
			}
		} 
	
		
	}
	
	action create_enemy_spawners(string idP, string idESStr, string xsStr, string ysStr) {
//		ask GPlayLand {
//		 	ask enemy_spawners{
//				do die;
//			}
//			enemy_spawners <- [];
//		}
		unity_player Pl <- player_agents[idP];
		list<string> idESs <- idESStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));
		list<enemy_spawner> eps;
		loop i from: 0 to: length(idESs) -1 {
			string idT <- idESs[i];
			int x <- xs[i];
			int y <- ys[i];
			point pt <- toGAMACoordinate(x,y);
			create enemy_spawner {
				_id <- idT;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.enemy_spawners[idT] <- self;
				location <- pt;
				eps << self;
			}	
		}
		if (not empty(eps)) {
			int max_x <- cell max_of each.grid_x;
			int current_x <- 0;
			int step_x <- round(max_x/length(eps));
			map<enemy_spawner,int> esp <- eps as_map (each :: cell(each.location).grid_x);
			loop i from: 0 to: length(enemy_spawner) - 1 {
				list<cell> cells <- cell where ((each.grid_x >= current_x) and (each.grid_x <= (current_x + step_x)));
				int mid <- int(current_x + step_x/2.0);
				enemy_spawner es <- esp.keys with_min_of abs(mid - esp[each]);
				es.my_cells <- cells;
				current_x <- current_x + step_x;
			}
		}
		
		
	}
	
	action move_create_pumper(string idP, string idwp, int x, int y) {
		point pt <- toGAMACoordinate(x,y);
		unity_player Pl <- player_agents[idP];
		Pumper wp <- Pl.myland.pumpers[idwp];
		if (wp != nil) {
			wp.location <- pt;
			wp.my_cell <- cell(wp.location);
		} else {
			create Pumper {
				_id <- idwp;
				playerLand_ID <- Pl.myland.playerLand_ID;
				Pl.myland.pumpers[idwp] <- self;
				location <- pt;
				my_cell <- cell(location);
			} 
		}
		
	}
	
	action delete_water_pump(string idP, string idwp) {
		unity_player Pl <- player_agents[idP];
		Pumper wp <- Pl.myland.pumpers[idwp];
		remove key:idwp from: Pl.myland.pumpers ;
		if not dead(wp) {
			ask wp {
//				do die;
			}
		}
	}
	
	
	action update_salty_water(string idP, string swsStr, string xsStr, string ysStr) {
		list<string> sws <- swsStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));
		unity_player Pl <- player_agents[idP];
		list<enemy> to_remove <- copy(Pl.myland.enemies.values);
		if (length(sws) > 1) {
			loop i from: 0 to: length(xs) -1 {
				string idsw <- sws[i];
				int x <- xs[i];
				int y <- ys[i];
				point pt <- toGAMACoordinate(x,y);
				enemy sw <- Pl.myland.enemies[idsw];
				if (sw != nil) {
					sw.location <- pt;
					to_remove >> sw;
				} else {
					create enemy {
						_id <- idsw;
						playerLand_ID <- Pl.myland.playerLand_ID;
						Pl.myland.enemies[idsw] <- self;
						location <- pt;
					} 
				}
				
			}
		}
		
		if not empty(to_remove) {
			ask to_remove {
				remove key: _id from: Pl.myland.enemies;
				do die;
			}
		}
	} 
	
	
	action update_fresh_water(string idP,string fwsStr, string xsStr, string ysStr) {
		list<string> fws <- fwsStr split_with(",");
		list<int> xs <- (xsStr split_with (",")) collect (int(each));
		list<int> ys <-(ysStr split_with (",")) collect (int(each));	
		unity_player Pl <- player_agents[idP];
		list<freshwater> to_remove <- copy(Pl.myland.fresh_waters.values);
		if (length(fws) > 1) {
			loop i from: 0 to: length(xs) -1 {
				string idfw <- fws[i];
				int x <- xs[i];
				int y <- ys[i];
				point pt <- toGAMACoordinate(x,y);
				freshwater sw <- Pl.myland.fresh_waters[idfw];
				if (sw != nil) {
					sw.location <- pt;
					to_remove >> sw;
				} else {
					create freshwater {
						_id <- idfw;
						playerLand_ID <- Pl.myland.playerLand_ID;
						Pl.myland.fresh_waters[idfw] <- self;
						location <- pt; 
					}
				}
			}
		}
		if not empty(to_remove) {
			ask to_remove {
				remove key: _id from: Pl.myland.fresh_waters;
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
	float player_rotation <- -90.0;
	
	bool to_display <- false;
	
	bool ready_to_start <- false;
	
	bool finish_game <- false;
	
	string current_state;

	init {
		myland <- GPlayLand[length(unity_player) - 1];
		color <- myland.my_team.color;
		do Restart(myland.playerLand_ID); 
	}

	action Restart (int id) {
		ask tree where (each.playerLand_ID = id) {
			do die;
		}

		ask enemy_spawner where (each.playerLand_ID = id) {
			do die;
		}

		ask enemy where (each.playerLand_ID = id) {
			do die;
		} 

	
		ask Pumper where (each.playerLand_ID = id) {
			do die;
		}

		myland.cntDem <- 0;
		myland.subside <- false;
		myland.deadtrees<-0;
		
		myland.started<-false;

	}

	float z_offset <- 2.0;

	
	aspect default {
		if (to_display) {
			draw square(player_size / 2.0) border:#black at: location + {0, 0, z_offset} color: color;
			draw player_perception_cone() border:#black color: rgb(color, 0.5);
			
		}
	
	}

}
