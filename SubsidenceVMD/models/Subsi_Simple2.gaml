model LoadSubsi

global {
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM <- "M1/M1_";
	string currentScenario;
	int _year <- 2018;
	grid_file dem_file <- grid_file("../includes/DEM/dem_500x500_extendbound.tif");
	
	grid_file volumeqh_file <- grid_file("../includes/groundwater/1_volume_qh_500.tif");
	grid_file volumeqp3_file <- grid_file("../includes/groundwater/2_volume_qp3_500.tif");
	//grid_file volumeqp23_file <- grid_file("../includes/groundwater/3_volume_qp23_500.tif");
	grid_file subsidence2018_file <- grid_file("../includes/Cum_subsidence/B1/B1_2018.tif");
	//field diffB1_M1_file <- field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");
	field DEM <- copy(field(dem_file));
	file cell_file <- grid_file("../includes/ht2015_500x500_cutPQ.tif");
	float pixelSize <- 500.0*500.0;  //  500*500/10000 ha  (ha)
	float total_waterused <-0.0; //total water used 
	//list<farming_unit> active_cell <- cell_dat where (each.grid_value != 8.0);
	//	field flooding <- field(dem_file);
	shape_file river_region0_shape_file <- shape_file("../includes/river_region.shp");
	
	field DEM_subsidence <- field(dem_file);
	field groundwater1_qh <- field(volumeqh_file);
	field groundwater2_qp3 <- field(volumeqp3_file);
	//field groundwater3_qp23 <- field(volumeqp23_file);
	field subsidence2018 <-  field(subsidence2018_file);
	
	geometry shape <- envelope(volumeqp3_file);
	//defining parameters
	map<int,float> wu_cost;//(unit: m3/ha) <-[5::34,34::389,12::180,6::98,14::294,101::150];//waterused of GPlayLanduse types 
	// para of Pumper 
	float pumVolumeHour <- 5.0 ;  //2,4 - 6 m3/h // alow <  10m3/day--> 10 * 30day*3months
	float pumHourperDay <- 6.0;
	float pumDayperMonth <- 30.0;
	float pumMonthperYear <- 6.0;
	//int totalNumberPumper <-1;
	float totalGroundVolumeUsed <-0.0;
	map<string,float> rateSubsidence <-['sluice'::0.1, 'qh'::1,'qp3'::1.3,'qp23'::1.5]; 

	//salt water quantity level
	float saltwaterQuantity<-1.0;	
		
	init {
		create aez from: aezone_MKD_region_simple_region0_shape_file;
		create GPlayLand from: players0_shape_file with:[playerLand_ID::int(read('region'))]{
			create Pumper number:1{
				location <- any_location_in (myself.shape);
				playerLand_ID<- myself.playerLand_ID;
				myself.playerPumper<<self;
			}
			create Lake number:1{
				location <- any_location_in (myself.shape);
				playerLand_ID<- myself.playerLand_ID;
			}
			create SluiceGate number:1{
				location <- any_location_in (myself.shape);
				playerLand_ID<- myself.playerLand_ID;
			}			
		}
		create river from: river_region0_shape_file;
//		do initGPLand;
		do load_WU_data;	
		//do load_profile_adaptation;
		total_waterused <- calWater_unit();
		//
	}
	reflex mainReflex{
		do updateSubsidenceAquifer;
		do readVR;
		do adding_contrucsion;		
	}
	action adding_contrucsion{
		/*
		 * Adding construction for each GPlayLand 
		 */
		 ask GPlayLand {
			//create the list of construction read from VRGame
			/*create constrction from VRPumper */ 
			create Pumper number:1{
					location <- any_location_in (myself.shape);
					playerLand_ID<- myself.playerLand_ID;
					myself.playerPumper<<self;
			}
		}
	}
	action readVR{
		// Nghi read list of construction from VR to the Para
		
	}
	// load map landuse :: water demand
	action load_WU_data {
		matrix cb_matrix <- matrix(csv_file("../includes/water_need_landuse.csv", true));
		loop i from: 0 to: cb_matrix.rows - 1 {
			int lu <- int(cb_matrix[0, i]);
			wu_cost <+ (lu)::float(cb_matrix[2, i]); 
		} 
		write wu_cost;
	}
	// calculate total water unit of the data
	float calWater_unit{
		float totalWu<-0.0;
		ask LandCell {
			totalWu <- totalWu + wu_cost[landuse]*pixelSize /1E6; // million m3 ;
		}
		return totalWu;
	}
	// subsidence at radius 3 cell around Pumper
	action updateSubsidenceAquifer {	
		/*
		 * Calculate water pumped for each GPlayRegion
		 * Calculate elevation sinking corespond with extracted ground water
		 * update ground water volume. 
		 */
		totalGroundVolumeUsed<-0.0;
		float tmpDepthLose<-0.0;
		float totalLosdepth<-0.0;
		loop player_temp over: GPlayLand{	
			// luong nuoc bơm. Sẽ chỉnh lại lượng nwocs bơn tại vị trí của máy bơm lấy từ Game play
			player_temp.volumePump <-player_temp.numberPumper * pumVolumeHour*pumHourperDay*pumDayperMonth*pumMonthperYear;// volum hour * hour*days*months m3	
			write "Pump volume of player "+	player_temp + ":"+ player_temp.volumePump;
			tmpDepthLose<-player_temp.volumePump/pixelSize;  //m
			ask player_temp.playerPumper {
				Pumper tmpPumper <- self;
				float rateSubsi <-1.0;
				ask SubsidenceCell overlapping self { // update subsi at Pumper
					ask self neighbors_at 6{
						ask AquiferQHCell[self.grid_x, self.grid_y]{
							if (volume - (player_temp.volumePump/1000000))>0{ 
//								write "Volum QH:" +volume;
								volume <- volume - (player_temp.volumePump/1000000);
								grid_value <- volume;
								rateSubsi <- 1.0;
							}
							else{
								ask AquiferQP3Cell[self.grid_x, self.grid_y]{
//										write "Volum QP3:" +volume;
										volume <- volume - (player_temp.volumePump/1000000);
										grid_value <- volume;
										rateSubsi <- 1.05;
								}
							} 
						}
						//lose elevation = subsidence rate of aquifer * depth lose . 
						
						elevation <- elevation - rateSubsi*tmpDepthLose;
						//cấu trúc lệnh này ko chạy đc: SubsidenceCell[self.grid_x, self.grid_y].elevation<- SubsidenceCell[self.grid_x, self.grid_y].elevation -tmpDepthLose; // Million m3
						grid_value <- elevation;
					}
				}// end update subsidence at pumper
				// Update subsidence 
				ask player_temp.playerSluicegate {
					ask SubsidenceCell overlapping self {
						ask self neighbors_at 6{
							elevation <- elevation - rateSubsidence['sluice']*tmpDepthLose;
						}
					}
				}
		}
			totalGroundVolumeUsed <- totalGroundVolumeUsed+player_temp.volumePump/1E6;
		}// and loop
//		write " Total lost depth:" + totalLosdepth;
		write "Total ground water used (Million m3):"+ totalGroundVolumeUsed;
	}// end action 
}
species Pumper {
	
	int playerLand_ID;
	string aquifer; // 'qh', 'qp3'
	aspect default {
		draw circle(1000) color: #pink;
	}
	reflex update_aqifer{ //aquifer qh have no more water 
		if (groundwater1_qh[geometry(self).location]>0 ){ 
			aquifer <-'qh';
		}
		else {
			aquifer <-'qp3';
		}
	}
}

species Lake {
	int playerLand_ID;
	aspect default {
		draw rectangle(1000,3000) color:#blue border: #black;
	}
	}
species SluiceGate {
	int playerLand_ID;
	aspect default {
		draw circle(2000) color: #gray;
	}
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
	
	int numberPumper <-1;
	int numberLake <-1; 
	int numberSluice <-1;  
	float volumePump <- 0.0;
	aspect default {
		draw shape.contour + 1000 color: #red;
	}
	reflex{
		volumePump <- numberPumper * pumVolumeHour;
	}
}

species aez {
	aspect default {
		draw shape.contour + 500 color: #gray;
	}
}
grid LandCell file: cell_file neighbors: 8 {
	int landuse <- int(grid_value);
//	float elevation;
//	float groundWaterUsed;  // total ground water used of land
	float waterDemand; 
	float plantHealth; // healthy, die
//	float waterExtracted;//: Water volume - waterExtracted
//	float loseDepth; //: groundwater extracted is converted to water depth lose (WaterExtracted/pixelSize)	
		
}
grid SubsidenceCell file: dem_file neighbors: 8 {
	float elevation <- float(grid_value);	
}
grid AquiferQHCell file: volumeqh_file neighbors: 8 {
	float volume <- float(grid_value);//volume M.m3
	float groundWaterDepth<- volume*1000000/pixelSize^2 update: volume*1000000/pixelSize^2; // (Water volume (m3)/pixel_size ^2)
}
grid AquiferQP3Cell file: volumeqp3_file neighbors: 8 {
	float volume <- float(grid_value);
	float groundWaterDepth<- volume*1000000/pixelSize^2 update: volume*1000000/pixelSize^2; // (Water volume (m3)/pixel_size ^2)
	
}
experiment main type: gui {
	list<font>
	fonts <- [font("Helvetica", 48, #plain), font("Times", 30, #plain), font("Courier", 30, #plain), font("Arial", 24, #bold), font("Times", 30, #bold + #italic), font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white, #blue]);
	list<rgb> depth_color <- palette([#grey, #black]);
	output {
			display "Digital Elevation Model" type: 3d {
				mesh DEM color:depth_color scale:1000 no_data: -9999.0 smooth:true triangulation:false;
				graphics information{
				  draw "DEM (" + _year +") min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
				}
			}
		display "Water_qh" type: 3d {
			mesh AquiferQHCell smooth: false;
			//mesh DEM color:depth_color scale:1000 no_data: -9999.0 smooth:true triangulation:false;
//			graphics information {
//							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
//						}			
			species aez;
			species river;
			species GPlayLand position: {0, 0, 0.01};
		}

		display "Subsidence - Groundwater extracted" type: 3d {
			mesh SubsidenceCell scale:1000 color:scale([#darkblue::-7.5,#blue::-5,#lightblue::-2.5,#white::0,#green::1]) no_data: -9999.0 smooth: false;
			
			species GPlayLand position: {0, 0, 0.01};
			species Pumper;
			species Lake;
			species SluiceGate;
			graphics information{
			  draw "Scenario: " + currentScenario+ " Flood- min:" + min(DEM_subsidence) + " - max:" + max(DEM_subsidence) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
			} 
		}
		
		display "Groundwater extractors" type: 3d {
			species Pumper;
			species Lake;
			species SluiceGate;
		}
		

//		display "W2" type: 3d {
//			mesh groundwater2 smooth: false;
//						graphics information {
//							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
//						}
//			species aez;
//			species river;
//			species GPlayLand position: {0, 0, 0.01};
//		}
//
//		display "W3" type: 3d {
//			mesh groundwater3 smooth: false;
//						graphics information {
//							draw "Scenario: " + currentScenario + " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color: #black font: fonts[1];
//						}
//			species aez;
//			species river;
//			species GPlayLand position: {0, 0, 0.01};
//		}

	}

}
