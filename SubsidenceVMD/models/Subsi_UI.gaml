model LoadSubsi

import "Elevation.gaml"

global {
	shape_file players0_shape_file <- shape_file("../includes/1players.shp");
	//	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ.tif");
	//list<farming_unit> active_cell <- cell_dat where (each.grid_value != 8.0);
	//	field flooding <- field(dem_file);
	//field groundwater3_qp23 <- field(volumeqp23_file);
	//	field subsidence2018 <- field(subsidence2018_file);
	geometry shape <- envelope(players0_shape_file);
	//defining parameters
	init {
		create route from: routes0_shape_file;
		avai_space <- world.shape - union(route collect (each.shape + 1000));
		create tree number: 100 {
			iid <- rnd(2);
			isz <- 1000 + (3 - iid) * 1000;
			location <- any_location_in(avai_space);
		}

		create GPlayLand from: players0_shape_file with: [playerLand_ID::int(read('region'))] {
			create Pumper number: 10 {
				location <- any_location_in(myself.shape);
				playerLand_ID <- myself.playerLand_ID;
				myself.playerPumper << self;
				mysub <- SubsidenceCell_elevation cells_in self;
			}

			//			create enemy from: source_enemy;
			//
			//			create Lake number: 1 {
			//				location <- any_location_in(myself.shape);
			//				playerLand_ID <- myself.playerLand_ID;
			//			}
			//
			//			create SluiceGate number: 1 {
			//				location <- any_location_in(myself.shape);
			//				playerLand_ID <- myself.playerLand_ID;
			//			}

		}

		road_network <- as_edge_graph(route);
		create river from: river_region0_shape_file;
		//
	}

	reflex mainReflex when: (cycle > 0) and (cycle mod 100 = 0) {
		create enemy {
			location <- any(route_source);
			target <- route_target;
		}

	}

	action mouse_up {
	//		if(selected_agent != nil) {
	//			selected_agent <- nil;
	//		}
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
	list<font>
	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white, #blue]);
	list<rgb> depth_color <- palette([#grey, #black]);
	output synchronized: true {
		layout #split consoles: false;
		display "Subsidence - Groundwater extracted" type: 3d axes: false background: #black {
		//			camera #from_above locked: true;
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
			species route;
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
