model LoadSubsi

import "Mouse Event.gaml"

global {
	image_file itree <- image_file("../includes/tree.png");
	list<image_file> itrees <- [image_file("../includes/tree1.png"), image_file("../includes/tree2.png"), image_file("../includes/tree3.png")];
	image_file iscene <- image_file("../includes/scene.jpg");
	image_file iscenefull <- image_file("../includes/scenefull.jpg");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file igate <- image_file("../includes/gate.png");
	image_file ilake <- image_file("../includes/lake.png");
	image_file iwarning <- image_file("../includes/warn.png");
	shape_file routes0_shape_file <- shape_file("../includes/routes.shp");
	int fsize<-100;
	field SubsidenceCell_elevation <- field(100,100);
	field SubsidenceCell_gridvalue <- copy(SubsidenceCell_elevation);
	field AquiferQHCell_volume <- field(fsize,fsize);
	field AquiferQHCell_groundWaterDepth <- copy(AquiferQHCell_volume);
	field AquiferQP3Cell_volume <- field(fsize,fsize);
	field AquiferQP3Cell_groundWaterDepth <- copy(AquiferQP3Cell_volume);

	field subsidence2018 <- field(fsize,fsize);
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	float pixelSize <- 500.0 * 500.0; //  500*500/10000 ha  (ha)
	float total_waterused <- 0.0; //total water used 
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	geometry shape <- envelope(players0_shape_file);
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
	//		create GPlayLand from: players0_shape_file with: [playerLand_ID::int(read('region'))] {
	//		//create the list of construction read from VRGame
	//		/*create constrction from VRPumper */
	//			create Pumper number: 10 {
	//				location <- any_location_in(myself.shape);
	//				shape <- square(5000);
	//				playerLand_ID <- myself.playerLand_ID;
	//				myself.playerPumper << self;
	//				mysub <- SubsidenceCell_elevation cells_in self;
	//			}
	//
	//		}
		create river from: river_region0_shape_file;
		do load_WU_data;
	}

//	reflex mainReflex2 {
//		do updateSubsidenceAquifer;
//	}

	// load map landuse :: water demand
	action load_WU_data {
		matrix cb_matrix <- matrix(csv_file("../includes/water_need_landuse.csv", true));
		loop i from: 0 to: cb_matrix.rows - 1 {
			int lu <- int(cb_matrix[0, i]);
			wu_cost <+ (lu)::float(cb_matrix[2, i]);
		}

		//		write wu_cost;
	}

	// subsidence at radius 3 cell around Pumper
	action updateSubsidenceAquifer {
		totalGroundVolumeUsed <- 0.0;
		float tmpDepthLose <- 0.0;
		float totalLosdepth <- 0.0;
		loop player_temp over: GPlayLand {
			player_temp.volumePump <- player_temp.numberPumper * pumVolumeHour * pumHourperDay * pumDayperMonth * pumMonthperYear; // volum hour * hour*days*months m3	
			//			write "Pump volume of player " + player_temp + ":" + player_temp.volumePump;
			tmpDepthLose <- player_temp.volumePump / pixelSize; //m
			ask player_temp.playerPumper {
				Pumper tmpPumper <- self;
				loop s over: mysub { // update subsi at Pumper 
					if (AquiferQHCell_volume[geometry(s).location] > 0) {
						AquiferQHCell_volume[geometry(s).location] <- AquiferQHCell_volume[geometry(s).location] - (player_temp.volumePump / 1000000);
					} else {
						AquiferQP3Cell_volume[geometry(s).location] <- AquiferQP3Cell_volume[geometry(s).location] - (player_temp.volumePump / 1000000);
					}

					//						}
					//lose elevation = subsidence rate of aquifer * depth lose . 
					SubsidenceCell_elevation[geometry(s).location] <- SubsidenceCell_elevation[geometry(s).location] - rateSubsidence[tmpPumper.aquifer] * tmpDepthLose;
					SubsidenceCell_gridvalue[geometry(s).location] <- (SubsidenceCell_elevation[geometry(s).location] < -9999) ?
					SubsidenceCell_gridvalue[geometry(s).location] : SubsidenceCell_elevation[geometry(s).location];
					//						write grid_value;
					if (SubsidenceCell_gridvalue[geometry(s).location] < -0.0001) {
						player_temp.cntDem <- player_temp.cntDem + 1;
					}

					if (player_temp.cntDem > 50000) {
						player_temp.subside <- true;
					}

					//					}

				} // end update subsidence at pumper

				// Update subsidence 

			}

			ask player_temp.playerPumper {
				loop s over: mysub {
					float tmp <- SubsidenceCell_elevation[geometry(s).location] - rateSubsidence['sluice'] * tmpDepthLose;
					SubsidenceCell_elevation[geometry(s).location] <- (tmp < -9999) ? SubsidenceCell_elevation[geometry(s).location] : tmp;
				}

			}

			totalGroundVolumeUsed <- totalGroundVolumeUsed + player_temp.volumePump / 1E6;
		} // and loop
		//				write " Total lost depth:" + totalLosdepth;
		//		write "Total ground water used (Million m3):" + totalGroundVolumeUsed;
	} // end action 
}

species river {

	aspect default {
		draw shape + 100 color: #blue;
	}

}

species enemy skills: [moving] {
	string _id;
	int playerLand_ID;
	point target;

	reflex move {
	//we use the return_path facet to return the path followed
		do goto target: target on: road_network recompute_path: false return_path: false speed: 10.0;
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
	int isz <- 2000;

	aspect default {
	//		draw itree size: 300;
		draw itrees[iid] size: isz;
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

species Pumper parent: DraggedAgent {
	list mysub;
	int playerLand_ID;
	string _id;
	string aquifer; // 'qh', 'qp3'
	geometry shape <- square(1000);

	aspect default {
		draw cube(1000) texture: ipumper;
		//		draw shape color:#red;
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

	reflex ss {
		volumePump <- numberPumper * pumVolumeHour;
	}

	int rot <- 0;
	bool active <- false;

	aspect land2d {
		draw shape;

		//		draw sland at: location + {1000, 0, 0} size: 12000 color: active ? #green : #grey rotate: 90 * 2::{0, 0, 1};
		draw "Dead Trees:" + length(tree where !dead(each)) at: location + {1000, 0, 0} size: 10;
	}

}

species aez {

	aspect default {
		draw shape.contour + 500 color: #gray;
	}

}

//experiment main type: gui {
//	list<font>
//	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
//	list<rgb> flood_color <- palette([#white, #blue]);
//	list<rgb> depth_color <- palette([#grey, #black]);
//	output {
//		display "Groundwater extracted" type: 3d background: #black {
//		//			camera 'default' location: {183000.0, 410250.0, 0.0} target: {183000.0, 136750.0, 0.0};
//			mesh SubsidenceCell_elevation scale: 100 color: scale([#darkblue::-7.5, #blue::-5, #lightblue::-2.5, #white::0, #green::1]) no_data: -9999.0 smooth: true triangulation: true;
//			species GPlayLand position: {0, 0, 0.01};
//			species Pumper;
//		}
//
//	}
//
//}
