include "globals.mzn";

var 2..4: c1;
var 1..4: c2;
var 1..6: c3;
var 1..7: c4;
var 3..7: c5;
var 3..8: c6;
var 4..9: c7;
var 6..10: c8;
var 7..10: c9;
var 8..9: c10;
array [1..10] of var int: cities = [c1, c2, c3,c4,c5,c6,c7,c8,c9,c10];


%array [1..10] of var int: prices = [10,10,8,12,13,9,10,11,12,8];


%constraint c1 == 1 /\ c10 = 1;
constraint c2!=2 /\ 
c3!=3 /\ c3!=4 /\ 
c4!=4 /\ c4!=3 /\ 
c5!=5 /\ c5!=6 /\ 
c6!=5 /\ c6!=6 /\ c6!=7 /\ 
c7!=6 /\ c7!=7 /\ 
c8!=8 /\ 
c9!=9;

constraint subcircuit(cities); 



solve minimize sum(cities);
output[show(cities)];