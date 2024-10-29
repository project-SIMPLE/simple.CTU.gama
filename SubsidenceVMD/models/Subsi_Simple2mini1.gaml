model LoadSubsi
import "Elevation.gaml"
global { 
	image_file itree <- image_file("../includes/tree.png");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file igate <- image_file("../includes/gate.png");
	image_file ilake <- image_file("../includes/lake.png");
	image_file iwarning <- image_file("../includes/warn.png");
//	geometry sland <- rotated_by((obj_file("../includes/SM_base2.obj") as geometry), -90::{1, 0, 0});
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM <- "M1/M1_";
	string currentScenario;
	int _year <- 2018;
	grid_file dem_file <- grid_file("../includes/DEM/dem_500x500_extendbound.tif");
	grid_file volumeqh_file <- grid_file("../includes/groundwater/1_volume_qh_500.tif");
	grid_file volumeqp3_file <- grid_file("../includes/groundwater/2_volume_qp3_500.tif");
	grid_file subsidence2018_file <- grid_file("../includes/Cum_subsidence/B1/B1_2018.tif");
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	//	field DEM <- copy(field(dem_file));
	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ.tif");
	float pixelSize <- 500.0 * 500.0; //  500*500/10000 ha  (ha)
	float total_waterused <- 0.0; //total water used 
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	field SubsidenceCell_elevation <- field(dem_file);
	field SubsidenceCell_gridvalue <- copy(SubsidenceCell_elevation);
	field AquiferQHCell_volume <- field(volumeqh_file);
	field AquiferQHCell_groundWaterDepth <- copy(AquiferQHCell_volume);
	field AquiferQP3Cell_volume <- field(volumeqp3_file);
	field AquiferQP3Cell_groundWaterDepth <- copy(AquiferQP3Cell_volume);
	//	field groundwater2_qp3 <- field(volumeqp3_file);
	field subsidence2018 <- field(subsidence2018_file);
	geometry shape <- envelope(volumeqp3_file);
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

	map<rgb, team> player_teams <- [];
	list<rgb> village_colors <- [#green, #yellow, #red, #blue];
	init {
		loop c over: village_colors {
			create team with: [color::c] returns: t;
			player_teams[c] <- first(t);
		}
		create GPlayLand number: 4  {
			playerLand_ID <- int(self);
			my_team<-team[int(self)];
		//create the list of construction read from VRGame
		/*create constrction from VRPumper */
			/*create Pumper number: 10 {
				location <- any_location_in(myself.shape);
				shape <- square(5000);
				playerLand_ID <- myself.playerLand_ID;
				myself.playerPumper << self;
				mysub <- SubsidenceCell_elevation cells_in self;
			}*/

		}

		//do load_WU_data;

	}

	reflex mainReflex {
		//do updateSubsidenceAquifer;


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
			ask player_temp.pumpers {
				Pumper tmpPumper <- self;
				loop s over: mysub { // update subsi at Pumper 
				//					ask self neighbors_at 6 {
				//										ask AquiferQHCell_volume[self.grid_x, self.grid_y] {
					if (AquiferQHCell_volume[geometry(s).location] > 0) {
					//								write "Volum QH:" + volume;
						AquiferQHCell_volume[geometry(s).location] <- AquiferQHCell_volume[geometry(s).location] - (player_temp.volumePump / 1000000);
						//								grid_value <- volume;
					} else {
					//								ask AquiferQP3Cell_volume[self.grid_x, self.grid_y] {
					//									write "Volum QP3:" + volume;
						AquiferQP3Cell_volume[geometry(s).location] <- AquiferQP3Cell_volume[geometry(s).location] - (player_temp.volumePump / 1000000);
						//									grid_value <- volume;
						//								}

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

			ask player_temp.pumpers {
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

//species Pumper {
//	int playerLand_ID;
//	string _id;
//	string aquifer; // 'qh', 'qp3'
//	list mysub;
//	geometry shape <- square(5000);
//
//	aspect default {
//		draw ipumper border: #red size: 1000;
//
//	}
//
//
//}
//
//
//species GPlayLand {
//	int playerLand_ID;
//	list<Pumper> playerPumper;
//	bool subside <- false;
//	int cntDem <- 0;
//	int numberPumper <- 1;
//	int numberLake <- 1;
//	int numberSluice <- 1;
//	float volumePump <- 0.0;
//
//	aspect default {
//		draw shape.contour + 1000 color: #red;
//	}
//
//	reflex {
//		volumePump <- numberPumper * pumVolumeHour;
//	}
//
//	int rot <- 0;
//	bool active <- false;
//
//	aspect land2d {
//		draw sland at: location + {1000, 0, 0} size: 12000 color: active ? #green : #grey rotate: 90 * 2::{0, 0, 1};
//	}
//
//}

