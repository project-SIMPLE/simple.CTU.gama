/**
* Name: Parameters
* Based on the internal empty template. 
* Author: patricktaillandier
* Tags: 
*/


model Parameters 

global { 
	image_file itree <- image_file("../includes/tree.png");
	list<image_file> itrees <- [image_file("../includes/tree1.png"), image_file("../includes/tree2.png"), image_file("../includes/tree3.png")];
	image_file iscene <- image_file("../includes/scene.jpg");
	image_file ipumper <- image_file("../includes/pumper.png");
	image_file igate <- image_file("../includes/gate.png");
	image_file ilake <- image_file("../includes/lake.png");
	image_file iwarning <- image_file("../includes/warn.png");
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	
	float pixelSize <- 500.0 * 500.0; //  500*500/10000 ha  (ha)
	

	grid_file ground_water_level_grid <- grid_file("../includes/groundwater/groundwaterLevel.tif");
	float refill_rate <- 0.001;
	list<float> refill_rates <- [0.001,0.001,0.001,0.001];
	
	// para of Pumper 
	float pumVolumeHour <- 5.0; //2,4 - 6 m3/h // alow <  10m3/day--> 10 * 30day*3months
	float pumHourperDay <- 6.0;
	float pumDayperMonth <- 30.0;
	float pumMonthperYear <- 6.0;
	list<float> water_pump_distance <- [0.7,0.2,0.1]; //rate of extraction per distance 1,2,3
	float reference_fresh_water_generation_time <- 1.0;	
	float min_fresh_water_generation_time <- 10.0;
	list<rgb> color_lands <- [#yellow, #lightgreen, #violet, #red];
	
	int pumper_rate_refresh_rate <- 10; // in number of cycles
	int enemy_genetation_rate_refresh_rate <- 100; // in number of cycles
	int update_subsidence_refresh_rate <- 7;

	float enemy_generation_rate_visibility_threshold <- 0.01;
	
	
	int duration_preparation <- 1; //in seconds;
	int duration_defense<- 240; //in seconds;
	
}