/**
* Name: SimpleTD
* Based on the internal empty template. 
* Author: hqn88
* Tags: 
*/
model SimpleTD

global {
	shape_file aezone_MKD_region_simple_region0_shape_file <- shape_file("../includes/AEZ/aezone_MKD_region_simple_region.shp");
 
	shape_file players0_shape_file <- shape_file("../includes/4players.shp");

	geometry shape <- envelope(aezone_MKD_region_simple_region0_shape_file); 
//	list<point> pp<-[{220000,58000},{210000,108000},{157000,148000},{70000,170000}];
	init { 
		create aez from:aezone_MKD_region_simple_region0_shape_file;
		create land from:players0_shape_file;
//		create land from:pp{
//			shape<-square(30000);
//		}
//		save land to:"../includes/4players.shp" format:"shp";
	} 

}

species aez {

	aspect default {
		draw shape color: #gray wireframe:true;
	}

}

species land {

	aspect default {
		draw shape color: #red wireframe:true;
	}

}
 

experiment main type: gui { 
	output synchronized: true {
		layout #stack consoles: false parameters: false;
		display d1 type: 3d background: #black axes: false {
			species aez; 
			species land;
		} 

	}

}