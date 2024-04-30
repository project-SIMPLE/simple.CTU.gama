/**
* Name: Complex Object Loading
* Author:  Arnaud Grignard
* Description: Provides a  complex geometry to agents (svg,obj or 3ds are accepted). The geometry becomes that of the agents.
* Tags:  load_file, 3d, skill, obj
*/
model obj_loading

global {
	geometry shape <- square(200);

	init {
		create object {
			rot <- 0;
			location <- a[0].location;
		}

		create object {
			rot <- 1;
			active <- true;
			location <- a[1].location;
		}

		create object {
			rot <- 2;
			location <- a[3].location;
		}

		create object {
			rot <- 3;
			location <- a[2].location;
		}

	}

}

grid a width: 2 height: 2 {
}
species enemy{}
species object {
	int rot <- 0;
	bool active <- false;
	geometry shape <- rotated_by((obj_file("../includes/SM_base2.obj") as geometry), -90::{1, 0, 0});

	aspect default {
		draw shape size: 102 color: active ? #green : #grey rotate: 90 * rot::{0, 0, 1};
	}

}

experiment Display type: gui {
	output {
		display complex background: #black type: 3d axes: false {
			light #ambient intensity: 50;
			species object; 
		}

	}

}
