include "globals.mzn";

int: available_time = 40;
int: nbrOfTasks = 9;
int: nbrOfProcessors = 6;

set of int: TASKS = 1..nbrOfTasks;
set of int: PROCS = 1..nbrOfProcessors;
set of int: TIMESTAMPS = 0..available_time;

var TIMESTAMPS: cp;
var TIMESTAMPS: end;

array[TASKS] of var TIMESTAMPS: start;
array[TASKS] of var PROCS: r;
array[TASKS] of var TASKS: d;
array[TASKS] of int: ones = [1, 1, 1, 1, 1, 1, 1, 1, 1];


% durations constraintr,
% constraint r[4] != 3;
% constraint r[8] != 1;

% constraint element(r[1], [2,  3,   1], d[1]); 
% constraint element(r[2], [2,  1,   1], d[2]);
% constraint element(r[3], [1,  1,   2], d[3]);
% constraint element(r[4], [1,  3,   0], d[4]);
% constraint element(r[5], [1,  1,   3], d[5]);
% %constraint element(r[5], [5,  4,   3], d[5]);
% constraint element(r[6], [1,  2,   1], d[6]);
% constraint element(r[7], [3,  1,   4], d[7]);
% constraint element(r[8], [0,  2,   1], d[8]);
% constraint element(r[9], [1,  1,   3], d[9]);

constraint element(r[1], [2, 2, 3, 3, 1, 1], d[1]); 
constraint element(r[2], [2, 2, 1, 1, 1, 1], d[2]);
constraint element(r[3], [1, 1, 1, 1, 2, 2], d[3]);
constraint element(r[4], [1, 1, 3, 3, 0, 0], d[4]);
constraint element(r[5], [1, 1, 1, 1, 3, 3], d[5]);
constraint element(r[6], [1, 1, 2, 2, 1, 1], d[6]);
constraint element(r[7], [3, 3, 1, 1, 4, 4], d[7]);
constraint element(r[8], [0, 0, 2, 2, 1, 1], d[8]);
constraint element(r[9], [1, 1, 1, 1, 3, 3], d[9]);

constraint r[4] != 5 /\ r[4] != 6;
constraint r[8] != 1 /\ r[8] != 2;


% start time constraints
constraint start[1] + d[1] <= start[4];
constraint start[2] + d[2] <= start[5];
constraint start[3] + d[3] <= start[6];
constraint start[4] + d[4] <= start[7];
constraint start[5] + d[5] <= start[8] /\ start[4] + d[4] <= start[8];
constraint start[6] + d[6] <= start[9] /\ start[5] + d[5] <= start[9];

constraint forall(t in TASKS)(
  start[t] + d[t] <= end
);

% processor select
constraint cumulative(r, ones, d, cp);

constraint forall (i in 1..9, j in 1..9) (
  j == i \/ r[i] != r[j] \/ start[i] + d[i] <= start[j] \/ start[j] + d[j] <= start[i]
);

% data-links
array [TASKS] of var 0..2: transfers;
%constraint sum(transfers) >= 0;
constraint transfers[1] == 0;
constraint transfers[2] == 0;
constraint transfers[3] == 0;
constraint 
(r[1]==r[4] \/ transfers[4] == 1) /\
(r[2]==r[5] \/ transfers[5] == 1) /\
(r[3]==r[6] \/ transfers[6] == 1) /\
(r[4]==r[7] \/ transfers[7] == 1) /\



((r[4]==r[8] /\ r[5]==r[8]) \/ transfers[8] > 0) /\
((r[4]==r[8] /\ r[5]==r[8]) \/ (r[4]!=r[8] /\ r[5]==r[8]) \/ (r[4]==r[8] /\ r[5]!=r[8]) \/ transfers[8] > 1) /\

((r[5]==r[9] /\ r[6]==r[9]) \/ transfers[9] > 0) /\
((r[5]==r[9] /\ r[6]==r[9]) \/ (r[5]==r[9] /\ r[6]!=r[9]) \/ (r[5]!=r[9] /\ r[6]==r[9]) \/ transfers[9] > 1);


% cost computation
%array[PROCS] of int: proc_costs = [4, 5, 3];
array[PROCS] of int: proc_costs = [4, 4, 5, 5, 3, 3];

array[PROCS] of var int: c;
constraint forall(p in PROCS)(
  (member(r, p) /\ c[p] == proc_costs[p]) \/ (member(r, p) == false /\ c[p] == 0)
);

var int: cost;
constraint sum(c) == cost;


var int: total_time;
var int: total_cost;

constraint total_time == end + sum(transfers);
constraint total_cost == cost + sum(transfers);

constraint total_cost <= 5;


solve minimize(total_time);

output[
   "total time:   ", show(total_time)
  ,"\ntask:        [1, 2, 3, 4, 5, 6, 7, 8, 9]"
  ,"\nused proc(r) ", show(r)
  ,"\ndurations:   ", show(d)
  ,"\nstart t:     ", show(start)
  ,"\ntransfers:   ", show(transfers)
  ,"\nc:           ", show(c)
  ,"\ncost:         ", show(total_cost)
];