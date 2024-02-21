model LoadSubsi

global {
	shape_file MKD_WGS84_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	string scenarioB <- "B1/B1_";
	string scenarioM<-"M1/M1_";
	string currentScenario;
	int _year <- 2018;
	
	grid_file dem_file <- grid_file("../includes/DEM/dem_500x500_align.tif");
	field diffB1_M1_file <-field(grid_file("../includes/Cum_subsidence/diff_B1_M1.tif"));
	
	
    field DEM <- copy(field(dem_file));
	field flooding <- field(dem_file);
	
	field subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
	geometry shape <- envelope(dem_file);
	float water_consummation_rate <-0.03;
	
		
	reflex load {
		water_consummation_rate <- 0.01;//rnd(0.4);	
		if (cycle < (2099 - _year)) {
			_year <- (_year + 1) > 2099 ? 2018 : (_year + 1);
		}
        // select subsidence scenarios based on water consummation. 
		if water_consummation_rate <0.02 {
			currentScenario<-"scenarioM";
			subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioM + _year + ".tif"));
		}
		else{             
			currentScenario<-"scenarioB";
			subsidentField <- field(grid_file("../includes/Cum_subsidence/" + scenarioB + _year + ".tif"));
		}
        //calculate elevation of flooding level. <0 means flooded
		field tmpField <- copy(DEM);		
  		//flooding  <- tmpField  - allField  - SLR_level;  // ko duoc vi no-data bị tính luôn 
  		loop cell_temp over: flooding cells_in shape  {
			if (subsidentField[geometry(cell_temp).location] != -9999.0) and (tmpField[geometry(cell_temp).location] != -9999.0){
				flooding[geometry(cell_temp).location]<- (tmpField[geometry(cell_temp).location]-subsidentField[geometry(cell_temp).location]);
			}
		}	 
		save flooding to:"../results/flooding_tif.geotif" format:"geotiff" crs:"EPSG:32846";
	}
}

experiment main type: gui {
	list<font> fonts <- [font("Helvetica", 48, #plain),font("Times", 30, #plain) ,font("Courier", 30, #plain), font("Arial", 24, #bold),font("Times", 30, #bold+#italic) ,font("Geneva", 30, #bold)];
	list<rgb> flood_color <- palette([#white,#blue]);
	list<rgb> depth_color <- palette([#grey,#black]);
	
	output {
		display "Digital Elevation Model" type: 3d {
			mesh DEM color:depth_color scale:1000 no_data: -9999.0 smooth:true triangulation:false;
			graphics information{
			  draw "DEM (" + _year +") min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
			}
		}
		display "Flooding Subsidence SLR 15cm" type: 3d {
			mesh flooding scale:1000 color:scale([#darkblue::-7.5,#blue::-5,#lightblue::-2.5,#white::0,#green::1]) no_data: -9999.0 smooth: false;
			graphics information{
			  draw "Scenario: " + currentScenario+ " Flood- min:" + min(DEM) + " - max:" + max(DEM) at: {0, 0} wireframe: true width: 2 color:#black font:fonts[1];	
			} 
		}
	}

}
