/**
* Name: creativecitygrid
* Author: Kenneth
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model creativecitygrid

global {
	//initalization of list of residential spaces for migration of people
	list<patches> residentialspaces <- [];
	//initialization of list of people in city
	list<person> all_people;
	//initialization of list of creative people in city
	list<person> cr_people;
	
//PARAMETERIZED INITIALIZATIONS
	//colors
    rgb color_1 <- rgb ("maroon") parameter: "Color of group 1:" category: "User interface";
    rgb color_2 <- rgb ("red") parameter: "Color of group 2:" category: "User interface";
    rgb color_3 <- rgb ("blue") parameter: "Color of group 3:" category: "User interface";
    rgb color_4 <- rgb ("orange") parameter: "Color of group 4:" category: "User interface";
    rgb color_5 <- rgb ("green") parameter: "Color of group 5:" category: "User interface";
    rgb color_6 <- rgb ("pink") parameter: "Color of group 6:" category: "User interface";   
    rgb color_7 <- rgb ("magenta") parameter: "Color of group 7:" category: "User interface";
    rgb color_8 <- rgb ("cyan") parameter: "Color of group 8:" category: "User interface";
    list colors <- [color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8] of: rgb;

 
    //Number of groups
    int number_of_groups <- 2 max: 8 parameter: "Number of groups:" category: "Resident Specifications";
   
  float mean_pop_count; 
  float high_dense_level;
  float n_number;
  float max_income_start<-1000.0 max: 100000.0 min: 0 parameter: "Maximum Starting Income" category: "Resident Specifications";
  float percent_educated<-50.0 max: 100 min: 0 parameter: "Percent Educated" category: "Resident Specifications";//% of population with college education;
  float percent_educated_cr<-50.0 max: 100.0 min: 0 parameter: "Percent Creative of Educated" category: "Resident Specifications";//% of creative population with college education
  float indexofgini;
  float cr_space_percent;
  //percentage of people that die/are born every month
  float pop_growth_rate<-0 max: 100 min: -100 parameter: "Population Growth Rate" category: "Resident Specifications";
  //percentage of creative people that die/are born every month
  float brain_drain<--30.0 max: 100 min: -100 parameter: "Population Growth Rate" category: "Resident Specifications";
  int init_pop <- 150 max: 100 min: 0 parameter: "Initial Population" category: "Resident Specifications";
  int dimensions <- 25 max: 100 min: 0 parameter: "Grid Dimensions" category: "Resident Specifications";
  //average tolerance of members of city, (for now, average tolerance = tolerance of all members of city)
  int mean_tolerance <- 10 parameter: "Mean Tolerance" category: "Resident Specifications";
  //distance of neighbors factored into tolerance for others
  int neighbours_distance <- 4 max: 10 min: 1 parameter: "Distance of perception:" category: "Resident Specifications";
  string landuse;
  string income_dist;
  //import land use values from csv file
  file my_csv_file <- csv_file("../includes/kendallsquarelayout11-4-16.csv",",");
  init {
    matrix data <- matrix(my_csv_file);
    ask patches{
      landuse <- (string(data[grid_x,grid_y])); 
    }
    //ask patches  to compile a collection of residentials
    ask patches{
      do update_color;
      if (landuse = "residential"){
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
  //other calculated variables
  float mean_income_all<- 0.0 update: sum(all_people collect each.income)/length(all_people);
  float median_income_all<-0.0 update: median(all_people collect each.income);
  float percent_poor<- 0.0 update: all_people count (each.income <= median_income_all*0.75)/length(all_people);
  float percent_middle <- 0.0 update: all_people count (each.income > median_income_all*0.75)/length(all_people);
  float percent_rich <- 0.0 update:  all_people count (each.income > median_income_all*4)/length(all_people);
  float mean_income_cr <- 0.0 update: sum(cr_people collect each.income)/length(cr_people);
}



species person skills: [moving]{
	rgb color;
	//list of people 
	list<person> my_neighbours <- self neighbors_at neighbours_distance;
	list<person> my_direct_neighbours <- self neighbors_at neighbours_distance;
	int similar_here -> {
		all_people count (((each.color =color) and location =each.location))
	};
	//total number of neighboring agents`
	int total_here ->{
		all_people count (each.location = location)
	} ;//total number of agents on the same patch
	int total;//total number of agents here and nearby
	bool creative;//whether or not agent is creative
	bool creative_h;//whether or not agent is highly creative
	bool creative_m;//whether or not agent is medium creative
	bool creative_l;//whether or not agent is low creative
	
	bool educated <- nil;// whether or not agent has a university degree
	bool partnered<-false;//If true, the person is paired with an investment or creative inspiration partner.
    bool partner_timeshare;//How long the person prefers to partner with investor/creative inspiration.
	bool content_w_neighbors -> {tolerance/100 > (similar_here / total_here)} ;
	float income_start <- gamma(rnd(1.00))*max_income_start/10;//income assigned at model start - can be used to see how much money made since the beginning of the model
	//income of agent, based on gamma or bimodal distribution
	float income <- income_start;
	//income of agent, based on gamma or bimodal distribution
	float tolerance <- mean_tolerance;
	patches my_place;
	init {
        //The agent will be located on one of the free places
        my_place <- one_of(residentialspaces);   
        location <- my_place.location; 
    } 
	reflex monthly_actions{
		//kill off agents if pop_growth_rate is less than zero
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
}

	//set people as circles of their defined color
    aspect default {
        draw circle(0.5) color:color;
    }
    //migrate from current location to random other residential location
    action migrate{
		self.location <- one_of(residentialspaces).location;
	}
}

grid patches width: dimensions height: dimensions neighbors:8 use_regular_agents: false frequency: 0{

    rgb color;//color of grid patch
    int neighborhood;//neighborhood which grid patch belongs
    int pop_count_cr; //creative population count
    int pop_count_cr_h; //highly creative population count
    int pop_count_cr_m; //medium creative population count
    int occupancy_start;//occupancy of patch at the beginning of the simulation
    bool creative_space;//whether or not patch is creative space
    bool creative_value;//creative value of patch
    int num_content_cr;//number of content creative residents of patch
    int pop_count_cr_n;//new pop count used to decline in number of creatives visit
    int pop_count_cr_diff;//diff of count of creative pop to current count of creative pop if negative then gained value, otherwise decrease
    int pop_count_cr_minus;//factor to subtract for loss of creative value
    string landuse;//What purpose is this land used for?
    
    //population of grid path
    int patch_population<- 0 update: all_people count (each.location = location);    
    reflex update{
    ask person at_distance(1){
       if(self overlaps myself){
          myself.patch_population  <- myself.patch_population + 1;
          }
       }
    
    }
    //sets color based on landuse value
    action update_color {
        if (landuse = "water") {
            color <- #blue;
        }
        else if (landuse = "commercial") {
            color <- #red;
        }
        else if (landuse = "green space") {
            color <- #green;
        }
         else if (landuse = "residential"){
            color <- #yellow;
        }
	        else{
            color <- #purple;
        }
    }
  }

experiment MyExperiment type: gui {
    output {
        display MyDisplay type: java2D {
            grid patches lines:#black;
            species person;
        }
    }
}

