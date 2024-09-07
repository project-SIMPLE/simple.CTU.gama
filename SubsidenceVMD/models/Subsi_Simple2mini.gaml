model LoadSubsi

global {
	image_file itree <- image_file("../includes/tree.png");
	list<image_file> itrees <- [image_file("../includes/tree1.png"), image_file("../includes/tree2.png"), image_file("../includes/tree3.png")];
	image_file iscene <- image_file("../includes/scene.jpg");
	image_file iscenefull <- image_file("../includes/scenefull.jpg");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file igate <- image_file("../includes/gate.png");
	image_file ilake <- image_file("../includes/lake.png");
	image_file iwarning <- image_file("../includes/warn.png");
	geometry sland <- rotated_by((obj_file("../includes/SM_base2.obj") as geometry), -90::{1, 0, 0});
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	shape_file routes0_shape_file <- shape_file("../includes/routes.shp");

	//	string scenarioB <- "B1/B1_";
	//	string scenarioM <- "M1/M1_";
	string currentScenario;
	int _year <- 2018;
	//grid_file volumeqp23_file <- grid_file("../includes/groundwater/3_volume_qp23_500.tif");
	//	grid_file subsidence2018_file <- grid_file("../includes/Cum_subsidence/B1/B1_2018.tif");
	//field diffB1_M1_file <- field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	shape_file players0_shape_file <- shape_file("../includes/1players.shp");
	//	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ.tif");
	float pixelSize <- 500.0 * 500.0; //  500*500/10000 ha  (ha)
	float total_waterused <- 0.0; //total water used 
	//list<farming_unit> active_cell <- cell_dat where (each.grid_value != 8.0);
	//	field flooding <- field(dem_file);
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	//field groundwater3_qp23 <- field(volumeqp23_file);
	//	field subsidence2018 <- field(subsidence2018_file);
	geometry shape <- envelope(players0_shape_file);
	//defining parameters
	map<int, float> wu_cost; //(unit: m3/ha) <-[5::34,34::389,12::180,6::98,14::294,101::150];//waterused of GPlayLanduse types 
	// para of Pumper 
	float pumVolumeHour <- 5.0; //2,4 - 6 m3/h // alow <  10m3/day--> 10 * 30day*3months
	float pumHourperDay <- 6.0;
	float pumDayperMonth <- 30.0;
	float pumMonthperYear <- 6.0;
	//int totalNumberPumper <-1;
	float totalGroundVolumeUsed <- 0.0;
	map<string, float> rateSubsidence <- ['sluice'::0.1, 'qh'::1, 'qp3'::1.3, 'qp23'::1.5];

	//salt water quantity level
	float saltwaterQuantity <- 1.0;
	graph road_network;
	list<point> route_source <- [{14608.46364974312, 418.2869639501441}, {19463.75474771089, 333.1064177788794}, {7708.839458182105, 77.56478216056712}];
	point route_target <- {6175.589640471502, 30146.297395684524};
	//	list<point> source_enemy<-[{12904.852740244474,25972.450658208225},{12904.852740244474,25972.450658208225},{8475.46436587174,24609.561913607642}];
	geometry avai_space;
	init {
		create aez from: aezone_MKD_region_simple_region0_shape_file;
		create route from: routes0_shape_file;
		avai_space<-world.shape - union(route collect (each.shape+1000));
		create tree number:100{
			iid<-rnd(2);
			isz<-1000+(3-iid)*1000;
			location<-any_location_in(avai_space);
		}
		create GPlayLand from: players0_shape_file with: [playerLand_ID::int(read('region'))] {
			create Pumper number: 1 {
				location <- any_location_in(myself.shape);
				playerLand_ID <- myself.playerLand_ID;
				myself.playerPumper << self;
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
		//		do initGPLand;
		do load_WU_data;
		//do load_profile_adaptation;
		total_waterused <- calWater_unit();
		//
	}

	reflex mainReflex when: (cycle > 0) and (cycle mod 100 = 0) {
		create enemy {
			location <- any(route_source);
			target <- route_target;
		}

		do updateSubsidenceAquifer;
		do readVR;
		//		do adding_contrucsion;
	}

	action adding_contrucsion {
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

	action readVR virtual: true {
	// Nghi read list of construction from VR to the Para

	}
	// load map landuse :: water demand
	action load_WU_data {
		matrix cb_matrix <- matrix(csv_file("../includes/water_need_landuse.csv", true));
		loop i from: 0 to: cb_matrix.rows - 1 {
			int lu <- int(cb_matrix[0, i]);
			wu_cost <+ (lu)::float(cb_matrix[2, i]);
		}

		//		write wu_cost;
	}
	// calculate total water unit of the data
	float calWater_unit {
		float totalWu <- 0.0;
		//		ask LandCell {
		//			totalWu <- totalWu + wu_cost[landuse] * pixelSize / 1E6; // million m3 ;
		//		}
		return totalWu;
	}
	// subsidence at radius 3 cell around Pumper
	action updateSubsidenceAquifer {
	/*
		 * Calculate water pumped for each GPlayRegion
		 * Calculate elevation sinking corespond with extracted ground water
		 * update ground water volume. 
		 */
		totalGroundVolumeUsed <- 0.0;
		float tmpDepthLose <- 0.0;
		float totalLosdepth <- 0.0;
		loop player_temp over: GPlayLand {
		// luong nuoc bơm. Sẽ chỉnh lại lượng nwocs bơn tại vị trí của máy bơm lấy từ Game play
			player_temp.volumePump <- player_temp.numberPumper * pumVolumeHour * pumHourperDay * pumDayperMonth * pumMonthperYear; // volum hour * hour*days*months m3	
			//			write "Pump volume of player " + player_temp + ":" + player_temp.volumePump;
			tmpDepthLose <- player_temp.volumePump / pixelSize; //m 
			totalGroundVolumeUsed <- totalGroundVolumeUsed + player_temp.volumePump / 1E6;
		} // and loop
		//				write " Total lost depth:" + totalLosdepth;
		//		write "Total ground water used (Million m3):" + totalGroundVolumeUsed;
	} // end action 
}

species enemy skills: [moving] {
	string _id;
	int playerLand_ID;
	point target;

	reflex move {
	//we use the return_path facet to return the path followed
		do goto target: target on: road_network recompute_path: false return_path: false speed: 50.0;
		if (location = target) {
			do die;
		}

	}

	aspect default {
		draw circle(300) color: #red;
	}

}

species tree {
	string _id;
	int playerLand_ID;
	int iid;
	int isz<-2000;
	aspect default {
//		draw itree size: 300;
		draw itrees[iid] size:isz;
	}

}

species warning {
	string _id;
	int playerLand_ID;
	int count <- 0;

	//	reflex ss {
	//		count <- count + 1;
	//		if (count > 100) {
	//			do die;
	//		}
	//
	//	}
	aspect default {
		draw iwarning border: #red size: 1000;
	}

}

species Pumper {
	int playerLand_ID;
	string _id;
	string aquifer; // 'qh', 'qp3'
	aspect default {
		draw ipumper border: #red size: 1000;

		//		draw circle(1000) color: #pink;
	}

	reflex update_aqifer { //aquifer qh have no more water 
	//		if (groundwater1_qh[geometry(self).location] > 0) {
	//			aquifer <- 'qh';
	//		} else {
	//			aquifer <- 'qp3';
	//		}

	}

}

species Lake {
	int playerLand_ID;
	string _id;

	aspect default {
		draw ilake border: #red size: 1000;

		//		draw rectangle(1000, 3000) color: #blue border: #black;
	}

}

species SluiceGate {
	int playerLand_ID;
	string _id;

	aspect default {
	//		draw circle(2000) color: #gray;
		draw igate border: #red size: 1000;
	}

}

species route {
}

species river {

	aspect default {
		draw shape + 100 color: #blue;
	}

}

species GPlayLand {
	int playerLand_ID;
	list<Pumper> playerPumper;
	list<Lake> playerLake;
	list<SluiceGate> playerSluicegate;
	//exchange construction. 
	list<Pumper> VRPumper;
	list<Lake> VRLake;
	list<SluiceGate> VRSluice;
	bool subside <- false;
	int cntDem <- 0;
	int numberPumper <- 1;
	int numberLake <- 1;
	int numberSluice <- 1;
	float volumePump <- 0.0;

	aspect default {
	//		draw shape.contour + 1000 color: #red;
		draw iscene;
	}

	aspect full {
	//		draw shape.contour + 1000 color: #red;
		draw iscenefull;
	}

	reflex {
		volumePump <- numberPumper * pumVolumeHour;
	}

	int rot <- 0;
	bool active <- false;

	aspect land2d {
		draw sland at: location + {1000, 0, 0} size: 12000 color: active ? #green : #grey rotate: 90 * 2::{0, 0, 1};
		//		draw "Dead Trees:"+length(tree where !dead(each)) at: location+{1000,0,0} size:10;
	}

}

species aez {

	aspect default {
		draw shape.contour + 500 color: #gray;
	}

}

experiment main type: gui {
	list<font>
	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white, #blue]);
	list<rgb> depth_color <- palette([#grey, #black]);
	output {
		display "Subsidence - Groundwater extracted" type: 3d axes: false {
		//			mesh SubsidenceCell scale: 5000 color: scale([#darkblue::-7.5, #blue::-5, #lightblue::-2.5, #white::0, #green::1]) no_data: -9999.0 smooth: true triangulation: true;
			species GPlayLand position: {0, 0, -0.01};
			//			species route;
			species Pumper;
			species Lake;
			species SluiceGate;
			species enemy;
			species tree;
			//			graphics information {
			//				draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM_subsidence) + " - max:" + max(DEM_subsidence) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
			//			}

		}

		display "Groundwater extractors" type: 3d axes: false {
			species GPlayLand aspect: full position: {0, 0, -0.01};
			species Pumper;
			species Lake;
			species SluiceGate;
			species enemy;
		}

	}

}
