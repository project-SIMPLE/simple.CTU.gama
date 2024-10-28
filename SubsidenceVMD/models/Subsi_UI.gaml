model LoadSubsi

import "Elevation.gaml"

global {
	shape_file players0_shape_file <- shape_file("../includes/1players.shp");

	geometry shape <- envelope(players0_shape_file);

	int num_players <- 4;
	map<rgb, team> player_teams <- [];
	list<rgb> village_colors <- [#green, #yellow, #red, #blue];
 
	init {
		create route from: routes0_shape_file;
		avai_space <- world.shape - union(route collect (each.shape + 1000));
		create tree number: 100 {
			iid <- rnd(2);
			isz <- 1000 + (3 - iid) * 1000;
			location <- any_location_in(avai_space);
		}

		loop c over: village_colors {
			create team with: [color::c] returns: t;
			player_teams[c] <- first(t);
		}
		create GPlayLand from: players0_shape_file with: [playerLand_ID::int(read('region'))] {
			my_team<-team[int(self)];
					my_team.players << self;
			
			create Pumper number: 10 {
				location <- any_location_in(myself.shape);
				playerLand_ID <- myself.playerLand_ID;
				myself.playerPumper << self;
				mysub <- SubsidenceCell_elevation cells_in self;
			}


		}

		road_network <- as_edge_graph(route);
		create river from: river_region0_shape_file;
		//
	}


	reflex {
		ask GPlayLand {
			bool cond <- flip(0.8);
			if (!finished) {
				if (not active) {
					current_score <- 0;
					active <- true;
				}

				if cond {
					remaining_time <- remaining_time - 1;
				}

				if remaining_time <= 0 {
					active <- false;
					finished <- true;
//					my_team.generation <- my_team.generation + 1;
				} else {
					if cond and flip(0.1) {
						current_score <- current_score + 1;
						my_team.score <- my_team.score + 1;
					}

				}

			}

		}

	} 
	
	reflex mainReflex when: (cycle > 0) and (cycle mod 50 = 0) {
		create enemy {
			location <- any(route_source);
			target <- route_target;
		}

	}

	action mouse_up {

		if (selected_agent != nil) {
			ask Pumper(selected_agent) {
			//				write "relocate"; 
				mysub <- SubsidenceCell_elevation cells_in self;
			}

			selected_agent <- nil;
		} else {
			ask agents of_generic_species DraggedAgent {
				if (self covers #user_location) {
				// Selects the agent
					selected_agent <- self;
				}

			}

		}

	}

	action adding_construction {
	/*
		 * Adding construction for each GPlayLand 
		 */
		ask GPlayLand {
		//create the list of construction read from VRGame
		/*create constrction from VRPumper */
			create Pumper number: 1 {
				location <- any_location_in(myself.shape);
				playerLand_ID <- myself.playerLand_ID;
				myself.playerPumper << self;
			}

		}

	}

}


experiment main1 type: gui {
//	float minimum_cycle_duration <- 0.05;
	list<font>
	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white, #blue]);
	list<rgb> depth_color <- palette([#grey, #black]);
	
	map<rgb, rgb> text_colors <- [#green::#white, #yellow::#black, #red::#white, #blue::#white];
	font text <- font("Arial", 24, #bold);
	font title <- font("Arial", 18, #bold);
	int x_origin <- 50;
	int x_interval <- 60;
	int y_interval <- 40;
	int box_size <- 30;
	
	output synchronized: true {
		layout #split consoles: false;
		display "Subsidence - Groundwater extracted" type: 3d axes: false background: #black {
		//			camera #from_above locked: true;
		
			overlay position: { 0, 0 } size: {0 #px, 0 #px} background: #black border: #black rounded: false {
				float y <- 2 * y_interval #px;
				draw rectangle((10 * x_interval) #px, 10 * box_size #px) at: {x_origin + (4 * x_interval) #px, y} color: rgb(0, 0, 0, 0.5);
				draw "Team score" at: {x_origin + (1 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				draw "Player" at: {x_origin + (4 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				draw "Score" at: {x_origin + (6 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				draw "Time left" at: {x_origin + (8 * x_interval) #px, y_interval #px} anchor: #top_center color: #white font: title;
				map<rgb, team> temp <- [];
				loop t over: (player_teams.values sort_by each.score) {
					temp[t.color] <- t;
				}

				loop p over: reverse(temp.pairs) {
					draw rectangle((10 * x_interval) #px, box_size #px) at: {x_origin + (4 * x_interval) #px, y} color: (p.key);
					//draw rectangle(x_interval #px, box_size #px) at: {x_interval / 2, y} color: p.key;
					draw string(p.value.score) at: {x_origin + (1 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
					draw "#" + p.value.generation at: {x_origin + (4 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
					GPlayLand last <- last(p.value.players);
					if (last != nil) {
						draw string(last.current_score) at: {x_origin + (6 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
						draw string(last.remaining_time) + " sec" at: {x_origin + (8 * x_interval) #px, y} anchor: #center color: text_colors[p.key] font: text;
					}
					y <- y + y_interval #px;
				}

			}
			event #mouse_down {
				ask simulation {
					do mouse_down;
				}

			}

			event #mouse_up {
				ask simulation {
					do mouse_up;
				}

			}

			event #mouse_move {
				ask simulation {
					do mouse_move;
				}

			}

			//			mesh SubsidenceCell scale: 5000 color: scale([#darkblue::-7.5, #blue::-5, #lightblue::-2.5, #white::0, #green::1]) no_data: -9999.0 smooth: true triangulation: true;
			species GPlayLand position: {0, 0, -0.01};
			species Pumper;
			species Lake;
			species SluiceGate;
			species enemy;
			species freshwater;
			species tree;
//			species route;
			//			graphics information {
			//				draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM_subsidence) + " - max:" + max(DEM_subsidence) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
			//			}

		}

		display "Groundwater extracted" type: 3d background: #black {
			camera 'default' location: {13628.8873, 59598.4979, 3068.073} target: {13628.8873, 15712.0028, 0.0};
			mesh SubsidenceCell_elevation scale: -1 color: scale([#darkblue::-7.5, #blue::-5, #lightblue::-2.5, #white::0, #green::1]) no_data: -9999.0 smooth: true triangulation: true;
			//			species GPlayLand position: {0, 0, 0.01};
			species Pumper;
		}

	}

}
