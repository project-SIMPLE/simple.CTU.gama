model LoadSubsi

global {
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenario <- "B1/B1_";
	//	string scenarioM<-"M1/M1_";
	int _year <- 2018;
	file dem_file <- grid_file("../includes/DEM/dem_500x500_align.tif");
	field flooding <- field(dem_file);
	field DEM <- field(dem_file);
	field allField <- field(grid_file("../includes/Cum_subsidence/" + scenario + _year + ".tif"));
	geometry shape <- envelope(dem_file);

	reflex load {
//		if (cycle < (2099 - _year)) {
			_year <- (_year + 1) > 2099 ? 2018 : (_year + 1);
			allField <- field(grid_file("../includes/Cum_subsidence/" + scenario + _year + ".tif"));
//		}
  flooding  <- DEM  - allField  - 0.015; 

		//		loop cell_temp over: cell_dem  {
		//			if (DEM[geometry(cell_temp).location]> -9999) and (allField[geometry(cell_temp).location]< 3.40282e+38){
		//				cell_temp.grid_value <- cell_temp.elevation- allField[geometry(cell_temp).location] - 0.015;
		//				
		//			}
		//		}
	}

	init {
		create boundMK from: MKD_WGS84_shape_file;
	}

}
//grid cell_dem file: dem_file {
//	float elevation <- float(grid_value);
//	rgb color;
//
//}
species boundMK {
}

experiment main type: gui {
	output {
		display "Cumulative subsidence" type: 3d {
			mesh allField scale: -10000 grayscale: true no_data: 3.40282e+38;
		}

		display "Flooding-SLR 15cm" type: 3d {
			species boundMK;
			mesh DEM color: scale([#darkblue::-10, #blue::-3, #lightblue::-1, #cyan::-0.001, #red::1, #darkred::2, #black::30]) no_data: -9999 smooth: false;
		}

	}

}
