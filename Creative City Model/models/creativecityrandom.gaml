/**
* Name: creativecitygrid
* Author: Kenneth
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model creativecityrandom

global {
	//initalization of list of residential spaces for migration of people
	list<patches> residentialspaces <- [];
	list<patches> creative_spaces <- [];
	list<patches> high_creative_spaces <- [];
	//initialization of list of people in city
	list<person> all_people;
	//initialization of list of creative people in city
	list<person> cr_people;
	
//PARAMETERIZED INITIALIZATIONS
	//colors
    rgb color_1 <- rgb ("maroon") parameter: "Color of group 1:" category: "User interface: Residents";
    rgb color_2 <- rgb ("red") parameter: "Color of group 2:" category: "User interface: Residents";
    rgb color_3 <- rgb ("blue") parameter: "Color of group 3:" category: "User interface: Residents";
    rgb color_4 <- rgb ("orange") parameter: "Color of group 4:" category: "User interface: Residents";
    rgb color_5 <- rgb ("green") parameter: "Color of group 5:" category: "User interface: Residents";
    rgb color_6 <- rgb ("pink") parameter: "Color of group 6:" category: "User interface: Residents";   
    rgb color_7 <- rgb ("magenta") parameter: "Color of group 7:" category: "User interface: Residents";
    rgb color_8 <- rgb ("cyan") parameter: "Color of group 8:" category: "User interface: Residents";
    list colors <- [color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8] of: rgb;
    //landuse colors
    rgb residential_color <- rgb ("Yellow") parameter: "Color of Residential Areas:" category: "User interface: Landuse";
    rgb commercial_color <- rgb ("Red") parameter: "Color of Commercial Areas: " category: "User interface: Landuse";
    rgb greenspace_color <- rgb ("Green") parameter: "Color of Green Spaces:" category: "User interface: Landuse";
    rgb undeveloped_color <- rgb ("Grey") parameter: "Color of Undeveloped Space:" category: "User interface: Landuse";
 	rgb water_color <- rgb ("Blue") parameter: "Color of Water Space:" category: "User interface: Landuse";
 	rgb creative_color <- rgb ("Purple")parameter: "Color of Creative Space:" category: "User interface: Landuse";
    //Number of groups
    int number_of_groups <- 2 max: 8 parameter: "Number of groups:" category: "Resident Specifications";
   
  float mean_pop_count; 
  float high_dense_level;
  float n_number;
  float mean_income_start<-1000.0 parameter: "Mean Starting Income" category: "Resident Specifications";
  float stdev_income_start<-100.0 parameter: "STDEV of starting Income" category: "Resident Specifications";
  float percent_educated<-50.0 parameter: "Percent Educated" category: "Resident Specifications";//% of population with college education;
  float percent_educated_cr<-50.0 parameter: "Percent Creative of Educated" category: "Resident Specifications";//% of creative population with college education
  float indexofgini;
  float cr_space_percent;
  //percentage of people that die/are born every month
  float pop_growth_rate<-10.0 parameter: "Population Growth Rate" category: "Resident Specifications";
  //percentage of creative people that die/are born every month
  float brain_drain<-0.0 parameter: "Brain Drain" category: "Resident Specifications";
  int init_pop <- 250  parameter: "Initial Population" category: "Resident Specifications";
  int dimensions <- 25  parameter: "Grid Dimensions" category: "Resident Specifications";
  //average tolerance of members of city, (for now, average tolerance = tolerance of all members of city)
  int mean_tolerance <-60 parameter: "Mean Tolerance" category: "Resident Specifications";
  int rate_of_partnership <-60 parameter: "Rate of Partnership" category:"Resident Specifications";
  //distance of neighbors factored into tolerance for others
  int neighbours_distance <- 1 parameter: "Distance of perception:" category: "Resident Specifications";
  float neighborhood_size <- 0.0 parameter: "Neighborhood Size: " category: "Resident Specifications";
  
  int percent_water <- 20 parameter: "Landuse Percentage Water" category: "City Specifications";
  int percent_green_space <- 20 parameter: "Landuse Percentage Green Space" category: "City Specifications";
  int percent_commercial <- 20 parameter: "Landuse Percentage Commercial" category: "City Specifications";
  int percent_residential <- 20 parameter: "Landuse Percentage Residential" category: "City Specifications";
  int percent_undeveloped <- 20 parameter: "Landuse Percentage Undeveloped" category: "City Specifications";
  string landuse;
  string income_dist;
  
  //import land use values from csv file
 
  init {
    
    //ask patches  to compile a collection of residentials
    ask patches{
      do update_color;
      if (color_value = 3){
      	add patches(self) to: residentialspaces;
      }
    }
    //Action to initialize the people agents, also sets education, creativity, and color.
    create person number:init_pop{
      	if(flip(percent_educated/100)){
      		educated <- true;	
      	}
      	if(flip((percent_educated/100)*(percent_educated_cr/100))){
      		creative <- true;
      		income_start <- income_start*1.03;

      	}
      	color <- colors at (rnd(number_of_groups-1));
      }
    
    //ask persons to compile a list of creative people
    ask person{
      if (creative = true){
      	add person(self) to: cr_people;
      }
    }
    write cr_people;
      all_people <- person as list ;
	//create more people if population growth rate is positive

  }
  reflex addpeople{
    	population <- all_people count(true);
    	create person number:population*(pop_growth_rate/100){
      	if(flip(percent_educated/100)){
      		educated <- true;	
      	}
      	if(flip((percent_educated/100)*(percent_educated_cr/100))){
      		creative <- true;
      		income_start <- income_start*1.03;

      	}
      	color <- colors at (rnd(number_of_groups-1));
      }
    }
 reflex countcreative{
 	ask patches{
 	if(creative_space){
 		add patches(self) to: creative_spaces;
 		}
 	if(high_creative_space){
 		add patches(self) to: high_creative_spaces;
 		} 	
 	}
 }

  //other calculated variables
  float mean_income_all<- 0.0 update: sum(all_people collect each.income)/length(all_people);
  float median_income_all<-0.0 update: median(all_people collect each.income);
  float percent_poor<- 0.0 update: all_people count (each.income <= median_income_all*0.75)/length(all_people);
  float percent_middle <- 0.0 update: all_people count (each.income > median_income_all*0.75)/length(all_people);
  float percent_rich <- 0.0 update:  all_people count (each.income > median_income_all*4)/length(all_people);
  float mean_income_cr <- 0.0 update: sum(cr_people collect each.income)/length(cr_people);
  int cr_population<- length(cr_people) update: length(cr_people);
  int population <- length(all_people) update: length(all_people);
  int num_creative_spaces <- length(creative_spaces)update: length(creative_spaces);
  int num_high_creative_spaces <- length(high_creative_spaces)update: length(high_creative_spaces);
  int num_patches <- dimensions*dimensions;
}



species person skills: [moving]{
	rgb color;
	//list of people 
	list<person> my_neighbours <- self neighbors_at neighbours_distance;
	list<person> my_direct_neighbours <- self neighbors_at neighbours_distance;
	int similar_here -> {
		all_people count ((each.color =color) 
			and location.x <= each.location.x + neighborhood_size 
			and location.x >= each.location.x - neighborhood_size  
			and location.y <= each.location.y + neighborhood_size 
			and location.y >= each.location.y - neighborhood_size 
		)
		};
	//total number of neighboring agents`
	int total_here ->{
		all_people count (
			location.x <= each.location.x + neighborhood_size
			and location.x >= each.location.x - neighborhood_size  
			and location.y <= each.location.y + neighborhood_size 
			and location.y >= each.location.y - neighborhood_size 
		)
	} ;//total number of agents on the same patch
	int total;//total number of agents here and nearby
	bool creative;//whether or not agent is creative
	bool creative_h;//whether or not agent is highly creative
	bool creative_m;//whether or not agent is medium creative
	bool creative_l;//whether or not agent is low creative
	
	bool educated <- nil;// whether or not agent has a university degree
	bool partnered<-false;//If true, the person is paired with an investment or creative inspiration partner.
	person partner;
    bool partner_timeshare;//How long the person prefers to partner with investor/creative inspiration.
	bool content_w_neighbors <- true update: tolerance/100 > (similar_here / (total_here+1)) ;
	float income_start <- gauss(mean_income_start,stdev_income_start);//income assigned at model start - can be used to see how much money made since the beginning of the model
	//income of agent, based on gamma or bimodal distribution
	float income <- income_start;
	//income of agent, based on gamma or bimodal distribution
	float tolerance <- mean_tolerance;
	
	
	patches my_place;
	init {
        //The agent will be located on one of the free places
        my_place <- one_of(residentialspaces);   
        location <- point(my_place.location); 
    } 
	reflex monthly_actions{
		//kill off agents if pop_growth_rate is less than zero0
		 if(pop_growth_rate<0.0){
			if (flip((-pop_growth_rate)/12/100)) {
                do die;
                }
		 if(brain_drain<0.0){
			if (creative){
			if (flip((-pop_growth_rate)/12/100)) {
                do die;
        //checks to every month to see if the agent has been assigned a creative boolean value yet, agents that have been
            	}
  			}
 		}
 		
 	}
 	if(!content_w_neighbors){
			do migrate;
		}
	if(my_place.creative_space and creative){
		ask person at_distance(neighbours_distance){
			if(myself.partnered =false){
				if flip((rate_of_partnership*tolerance)/100){
					self.partner <- myself;
					if(flip(0.5)){
						my_place.entrepreneurship <- my_place.entrepreneurship + 1;
						}
					else{
						myself.creative <- true;
					}
					}
					
				}				
			}
		}
		
	}

		


	//set people as circles of their defined color
    aspect default {
        draw circle(0.5) color:color;
    }
    //migrate from current location to random other residential location
    action migrate{
		self.location <- point(one_of(residentialspaces).location);
	}
	
	
}


grid patches width: dimensions height: dimensions neighbors:8 use_regular_agents: false{

    rgb color;//color of grid patch
    int neighborhood;//neighborhood which grid patch belongs
    int occupancy_start;//occupancy of patch at the beginning of the simulation
    bool creative_space <- false;//whether or not patch is creative space
    bool high_creative_space <- false;
	int entrepreneurship <- 0;
    int num_content_cr;//number of content creative residents of patch
    int pop_count_cr_n;//new pop count used to decline in number of creatives visit
    int pop_count_cr_diff;//diff of count of creative pop to current count of creative pop if negative then gained value, otherwise decrease
    int pop_count_cr_minus;//factor to subtract for loss of creative value
    string landuse;//What purpose is this land used for?
    
    //population of grid path
    int patch_population<- 0 update: all_people count (each.location = location);    
	int pop_count_cr <- 0 update: all_people count (each.location = location and each.creative = true);
	list<patches> my_neighbours <- self neighbors_at neighbours_distance;
	int green_spaces_nearby <- 0 update: my_neighbours count (each.landuse = "green space");
	int high_creative_space_nearby <- 0 update: my_neighbours count (each.high_creative_space = true);
//	reflex update{
//		ask patches at_distance(10.0){
//                if(myself.landuse = "green space"){
//                  green_spaces_nearby <- green_spaces_nearby+ 1;
//                if(self.high_creative_space = true){
//                	high_creative_space_nearby <- 1;
//                }
//            }
//        }
//        
//        }
    //creative value of patch
    int creative_value <- 0 update: pop_count_cr*5 + green_spaces_nearby*25 + high_creative_space_nearby*25 + entrepreneurship*25;
    reflex update{
    	ask self{
    	if(creative_value >=50){
    		creative_space <- true;
    	}
    	if(creative_value >=100){
    		high_creative_space <- true;
    	}
    	if(high_creative_space = true){
            color <- creative_color;
            }
    	
     }
  }
  	int color_value <- rnd_choice([percent_water/100
  		,percent_commercial/100
  		,percent_green_space/100
  		,percent_residential/100
  		,percent_undeveloped/100]);
    //sets color based on landuse value
    action update_color {
        if (color_value = 0) {
            color <- water_color;
        }
        else if (color_value = 1) {
            color <- commercial_color;
        }
        else if (color_value = 2) {
            color <- greenspace_color;
        }
         else if (color_value = 3){
         	color <- residential_color;
           }        
	        else{
            color <- undeveloped_color;
        }
    }
    //ASSIGN creative VALUE FOR HIGH CREATIVE AREAS
    //Turtle Interaction with patches
    //add value - if a high-creative turtle lands on high creative patch it add value of 10 to patch, medium turtles add 5
    //change color - if creative value is 50 it changes to darker color, when creative-value >= 100 then color is black
    //spread creative patches - when a patch has creative value 100 or more, its neighbor4 patches change to landuse=7 and magenta
	//however won't change landuse and color of those that are landuse canton, transit, water
  }

experiment MyExperiment type: gui {
    output {
        display MyDisplay type: java2D {
            grid patches lines:#black;
            species person;
        }
        display chart_display{
            chart "Creative and Non-Creative Population over time" type: pie background: #lightgray axes: #white position: { 0, 0 } size: { 1.0, 0.5 } {
                data "Creative Population" value: cr_population color: #purple style: spline;
                data "Non-Creative Population" value: population-cr_population color: #red style: spline;
                data "Total Population" value: population color: #black style: spline;
            }

            chart "Percent Creative Space" type: series background: #lightgray axes: #white position: { 0, 0.5 } size: { 1.0, 0.5 }  x_range: 50{
                data "Percent Creative Space" color: rgb(85,26,139) value: (num_creative_spaces / num_patches) * 100 style: spline;
                data "Percent High Creative Space" color: #purple value: (num_high_creative_spaces / num_patches) * 100 style: spline;
            }
        	chart "Creative and Non-Creative Population over time" type: series{
        		
        	}
        }
    }
}

