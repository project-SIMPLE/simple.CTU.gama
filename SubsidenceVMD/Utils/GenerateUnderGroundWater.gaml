/**
* Name: GenerateUnderGroundWater
* Based on the internal skeleton template. 
* Author: patricktaillandier
* Tags: 
*/

model GenerateUnderGroundWater

global {
	grid_file volumeqp3_file <- grid_file("../includes/groundwater/2_volume_qp3_500.tif");
	
	int dimension <- 10;
	geometry shape <- envelope(volumeqp3_file);
	
	init {
		ask cell where (each.grid_x < dimension/3) {
			grid_value <- 10.0;
		}
		ask cell where ((each.grid_x >= dimension/3) and (each.grid_x < 2*dimension/3)){
			grid_value <- 20.0;
		}
		ask cell where ((each.grid_x >= 2*dimension/3)){
			grid_value <- 10.0;
		}
		ask cell {
			float val <- 1 - (grid_value /25.0);
			color <- rgb(255*val, 255*val, 255);
		}
		save cell format:"geotiff" to:"../includes/groundwater/groundwaterLevel.tif";
	}
	
}
grid cell width: dimension height: dimension {
	
}

experiment GenerateUnderGroundWater type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		display map {
			grid cell border: #black;
		}
	}
}
