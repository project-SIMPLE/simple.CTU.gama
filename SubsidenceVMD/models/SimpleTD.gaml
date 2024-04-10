/**
* Name: SimpleTD
* Based on the internal empty template. 
* Author: hqn88
* Tags: 
*/
model SimpleTD

global {
	shape_file MKD_province0_shape_file <- shape_file("../includes/AdminBound/MKD_province.shp");
	shape_file road_polyline0_shape_file <- shape_file("../includes/AdminBound/road_polyline.shp");
	shape_file MKD_WGS840_shape_file <- shape_file("../includes/AdminBound/MKD_WGS84.shp");
	grid_file dem_file <- grid_file("../includes/DEM/dem_500x500_extendbound.tif");

	//	shape_file MKD_district0_shape_file <- shape_file("../includes/AdminBound/MKD_district.shp");
	//	shape_file river_region0_shape_file <- shape_file("../includes/AdminBound/river_region.shp");
	geometry shape <- envelope(MKD_province0_shape_file);
	geometry bound <- (geometry(MKD_WGS840_shape_file));
	point center <- {251580, 90238};
	float step <- 0.1;
	geometry east;
	geometry west;
	float P_v0_mean <- 1.3 #m / #s;
	float P_v0_std <- 0.2 #m / #s;
	float P_teta0 <- 90.0; //degrees
	float P_disc_factor <- 100.0;
	float P_tau <- 0.5 #s;
	float P_dmax <- 8.0 #m * 1000;
	float P_k <- 1.0 * 10 ^ 3;
	float size_factor <- 10000.0;
	field DEM <- copy(field(dem_file));
	float seed <- 0.5810964478013678;

	init {
		create land from: MKD_province0_shape_file;
		create river from: road_polyline0_shape_file;
		loop times: 5 {
			create tower {
				location <- any_location_in(any(river));
			}

		}

	}

	reflex loops when: flip(0.01) {
		create water {
			location <- any_location_in(bound.contour);
			o <- center;
			color <- #cyan;
		}

	}

}

species water {
	float m <- rnd(60.0, 100.0);
	float shoulder_length <- m / 320.0 * size_factor;
	float speed <- 0.0;
	geometry shape <- circle(shoulder_length);
	rgb color <- rnd_color(255);
	point o;
	float v0 <- gauss(P_v0_mean, P_v0_std);
	float teta0 <- P_teta0; //degrees
	float tau <- P_tau;
	float dmax <- P_dmax;
	float disc_factor <- P_disc_factor;
	float k <- P_k;
	float alpha0;
	float v;
	float dh;
	list<geometry> visu_ray;
	list<float> val_angles;
	float heading;
	point acc <- {0, 0};
	point vi <- {0, 0};
	float c;

	init {
		int num <- int(2 * teta0 / disc_factor);
		heading <- location towards o;
		loop i from: 0 to: num {
			val_angles << ((i * disc_factor) - teta0);
		}

	}

	reflex move_pedestrian {
		c <- 0.0;
		float dist_o <- location distance_to o;
		alpha0 <- location towards o;
		visu_ray <- [];
		dh <- #max_float;
		float dmin <- #max_float;
		float h0 <- copy(heading);
		loop a over: val_angles {
			float alpha <- a + h0;
			list<float> r <- compute_distance(alpha, min(dist_o, dmax));
			float dist <- r[0];
			if (dist < dmin) {
				dmin <- dist;
				dh <- r[1];
				heading <- alpha;
			}

		}

		do manage_move(dist_o);
		if (self distance_to o) < 1000.0 {
			do die;
		}

	}

	list<float> compute_distance (float alpha, float dist_o) {
		float f_alpha <- f(alpha, dist_o);
		return [dist_o ^ 2 + f_alpha ^ 2 - 2 * dist_o * f_alpha * cos(alpha0 - alpha), f_alpha];
	}

	point force_repulsion (water other) {
		float strength <- (k * (other.shoulder_length + shoulder_length - (location distance_to other.location))) / size_factor;
		c <- c + strength;
		point vv <- {location.x - other.location.x, location.y - other.location.y};
		float n <- norm(vv);
		return vv * (strength / n);
	}

	float f (float alpha, float dmax_r) {
		geometry line <- line([location, location + ({cos(alpha), sin(alpha)} * dmax_r)]);
		list<water> ps <- (water overlapping line) - self;
		loop p over: ps {
			line <- line - p;
			if line = nil {
				return 0.0;
			}

		}

		line <- line.geometries first_with (location in each.points);
		if line = nil {
			return 0.0;
		}

		line <- line - self;
		if line = nil {
			return 0.0;
		}

		visu_ray << line;
		return line.perimeter;
	}

	point compute_sf_pedestrian {
		point sf <- {0.0, 0.0};
		loop p over: water overlapping self {
			sf <- sf + force_repulsion(p);
		}

		return sf / m;
	}

	action manage_move (float dist_o) {
		float vdes <- min(v0, dh / tau);
		point vdes_vector <- {cos(heading), sin(heading)};
		vdes_vector <- vdes_vector * vdes;
		acc <- (vdes_vector - vi) / tau + compute_sf_pedestrian();
		vi <- vi + (acc * step);
		location <- location + (vi * step * size_factor / 5);
	}

	aspect default {
	//		draw circle(shoulder_length*20000) rotate: heading + 90.0 color: color;
	//		draw shape rotate: heading + 90.0 color: color;
		draw sphere(shoulder_length) at: location - {0, 0, 1000} color: color;
	}

}

species tower {
	float radius <- 5 * size_factor;
	int freq <- 50;

	reflex shooting when: ((cycle mod freq) = 0) {
		water tar <- first(water at_distance radius);
		if (tar != nil) {
			create bullet {
				location <- myself.location;
				mytarget <- tar;
			}

		}

	}

	aspect default {
		draw circle(radius) wireframe: true color: #pink;
		draw pyramid(size_factor) color: #green;
	}

}

species bullet skills: [moving] {
	water mytarget;
	float speed <- 12000 #m / #s;

	reflex chase {
		do goto target: mytarget;
		if (self distance_to mytarget) < 100.0 {
			ask mytarget {
				m <- m - 10;
				if (m < 10) {
					do die;
				}

			}

			do die;
		}

	}

	aspect default {
		draw triangle(size_factor / 3) depth: 1000  at: location+ {0, 0, 1000} rotate: heading + 90 color: #green;
	}

}

species land {

	aspect default {
		draw shape color: #gray;
	}

}

species river {

	aspect default {
		draw shape + 1000 color: #blue;
	}

}

experiment main type: gui {
	list<rgb> depth_color <- palette([#grey, #black]);
	output synchronized: true {
		layout #stack consoles: false parameters: false;
		display d1 type: 3d background: #black axes:false{
			species land;
			species river;
			mesh DEM color: depth_color no_data: -9999.0 smooth: false triangulation: true;
			species tower;
			species bullet;
			species water;
		}
		//		display d2 type: 3d background:#black{
		//			camera 'default' location: {260886.2195,95533.6623,1922.7942} target: {255245.6687,100793.5609,0.0};
		//			species land;
		////			mesh DEM color:depth_color scale:2000 no_data: -9999.0 smooth:true triangulation:true;
		//			species river;
		//			species water;
		//		}

	}

}