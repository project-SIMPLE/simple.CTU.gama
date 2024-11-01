model LoadSubsi

import "Parameters.gaml"

import "Entities.gaml"

global { 
	float total_waterused <- 0.0; //total water used 
	
	
	geometry shape <- envelope(ground_water_level_grid);
	
	map<int, float> wu_cost; //(unit: m3/ha) <-[5::34,34::389,12::180,6::98,14::294,101::150];//waterused of GPlayLanduse types 
	
	float totalGroundVolumeUsed <- 0.0;

	//salt water quantity level
	float saltwaterQuantity <- 1.0;


	
	float pump_per_step <-  pumVolumeHour * pumHourperDay * pumDayperMonth * pumMonthperYear / pixelSize; 
	init {
		create GPlayLand number: 4  {
			playerLand_ID <- int(self); 
			create team with: [color::color_lands[int(self)]] {
				myself.my_team <- self;
			}  
		}	
	} 
	

}
