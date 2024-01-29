model LoadSubsi

global {
	shape_file MKD_WGS840_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	geometry shape <- envelope(MKD_WGS840_shape_file);
	string scenario <- "B1/BI_";
	//	string scenario<-"M1/M1_";
	int y <- 2018;
	field allField <- field(grid_file("../includes/Cum_subsidence/" + scenario + y + ".tif"));

	reflex load {
		y<-(y+1)>2099?2018:(y+1);
		allField <- field(grid_file("../includes/Cum_subsidence/" + scenario + y + ".tif"));
	}

}

experiment main type: gui {
	output {
		display "field through mesh" type: 3d {
			mesh allField scale: -10000;
		}

	}

}
