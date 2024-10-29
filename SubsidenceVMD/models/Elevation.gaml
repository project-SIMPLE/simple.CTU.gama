model LoadSubsi

import "Entities.gaml" 

global {
	int fsize <- 100;
	field SubsidenceCell_elevation <- field(fsize, fsize);
	field SubsidenceCell_gridvalue <- copy(SubsidenceCell_elevation);
	//	field AquiferQHCell_volume <- field(fsize,fsize);
	//	field AquiferQHCell_groundWaterDepth <- copy(AquiferQHCell_volume);
	//	field AquiferQP3Cell_volume <- field(fsize,fsize);
	//	field AquiferQP3Cell_groundWaterDepth <- copy(AquiferQP3Cell_volume);
	field subsidence2018 <- field(fsize, fsize);
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	int pixelSize <- fsize * fsize; //  500*500/10000 ha  (ha)
	float total_waterused <- 0.0; //total water used 
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	geometry shape <- envelope(players0_shape_file);
	//	map<int, float> wu_cost; //(unit: m3/ha) <-[5::34,34::389,12::180,6::98,14::294,101::150];//waterused of GPlayLanduse types 
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

	
	reflex mainReflex2 {
		do updateSubsidenceAquifer;
		diffuse var: phero on: SubsidenceCell_elevation proportion: 1;
	}

	action updateSubsidenceAquifer {
		totalGroundVolumeUsed <- 0.0;
		float tmpDepthLose <- 0.0;
		float totalLosdepth <- 0.0;
		loop player_temp over: GPlayLand {
			player_temp.volumePump <- player_temp.numberPumper * pumVolumeHour * pumHourperDay * pumDayperMonth * pumMonthperYear; // volum hour * hour*days*months m3	
			//			write "Pump volume of player " + player_temp + ":" + player_temp.volumePump;
			tmpDepthLose <- player_temp.volumePump / pixelSize; //m
			ask player_temp.pumpers {
				Pumper tmpPumper <- self;
				loop s over: mysub {
					SubsidenceCell_elevation[geometry(s).location] <- SubsidenceCell_elevation[geometry(s).location] + 100; // rateSubsidence[tmpPumper.aquifer] * tmpDepthLose;

				}

			}

			totalGroundVolumeUsed <- totalGroundVolumeUsed + player_temp.volumePump / 1E6;
		}

	}

}


