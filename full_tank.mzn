include "globals.mzn";

int: tank_cap = 15;

%Defines the cities
var {2,3,4}: c1;
var {2,1,3,4}: c2;
var {3,1,2,5,6}: c3;
var {4,1,2,5,6,7}: c4;
var {5,3,4,7}: c5;
var {6,3,4,8}: c6;
var {7,4,5,8,9}: c7;
var {8,6,7,9,10}: c8;
var {9,7,8,10}: c9;
var {1}: c10;
array [1..10] of var int: cities = [c1,c2,c3,c4,c5,c6,c7,c8,c9,c10];

array [1..length(cities)] of var int: fuel_prices = [10,10,8,12,13,9,10,11,12,8];
array [1..length(cities)] of var 0..tank_cap: fuel_in_tank;
array [1..length(cities)] of var 0..tank_cap: fuel_bought;

array [1..length(cities)] of var int: costs;

% distances
array[1..length(cities), 1..length(cities)] of int: dist = [|  
 0, 10, 11,  6,  0,  0,  0,  0,  0,  0, | 
10,  0,  5,  8,  0,  0,  0,  0,  0,  0, | 
11,  5,  0,  0,  3,  5,  0,  0,  0,  0, |
 6,  8,  0,  0,  2,  6,  7,  0,  0,  0, | 
 0,  0,  3,  2,  0,  0, 12,  0,  0,  0, | 
 0,  0,  5,  6,  0,  0,  0, 14,  0,  0, | 
 0,  0,  0,  7, 12,  0,  0,  5,  3,  0, |
 0,  0,  0,  0,  0, 14,  5,  0,  1,  9, | 
 0,  0,  0,  0,  0,  0,  3,  1,  0,  2, | 
 0,  0,  0,  0,  0,  0,  0,  9,  2,  0  |];


constraint subcircuit(cities); 

% Start with no fuel
constraint fuel_bought[1] = fuel_in_tank[1];

constraint
  forall(i in 1..length(cities)) (
    fuel_in_tank[cities[i]] = fuel_in_tank[i]+fuel_bought[cities[i]]-dist[i,cities[i]] /\  
    fuel_in_tank[i] >= dist[i,cities[i]] /\ %Must have enough fuel for travel

    costs[i] = fuel_bought[i]*fuel_prices[i]);
     

solve minimize sum(costs);

output["Tank capacity: \t\t\t", show(tank_cap),
"\nPath from each city: \t\t", show(cities), 
"\nFuel in tank in each city: \t", show(fuel_in_tank), 
"\nFuel bought in each city: \t\t", show(fuel_bought), 
"\nCost in each city: \t\t", show(costs), 
"\nTotal cost: \t\t\t", show(sum(costs))];