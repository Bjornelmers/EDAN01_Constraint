include "globals.mzn";

bool: optimize_for_time;
int: available_time;
int: available_cost;
int: nbr_of_tasks = 9;
int: nbr_of_processors = 6;

array[PROCS] of int: processor_cost = [4, 4, 5, 5, 2, 2];

array[TASKS, PROCS] of int: exec_times = [|
  2, 2, 3, 3, 1, 1,|
  2, 2, 1, 1, 1, 1,|
  1, 1, 1, 1, 2, 2,|
  1, 1, 3, 3, 0, 0,|
  1, 1, 1, 1, 3, 3,|
  1, 1, 2, 2, 1, 1,|
  3, 3, 1, 1, 4, 4,|
  0, 0, 2, 2, 1, 1,|
  1, 1, 1, 1, 3, 3,|];

array[TASKS] of set of int: dependencies = [
  {},
  {},
  {},
  {1},
  {2},
  {3},
  {4},
  {4,5},
  {5,6}
];

set of int: TASKS      = 1..nbr_of_tasks;
set of int: PROCS      = 1..nbr_of_processors;
set of int: TIMESTAMPS = 0..available_time;
set of int: COSTS      = 0..available_cost;

var TIMESTAMPS:                              end_time;
var COSTS:                                   total_cost;
var 0..sum(processor_cost):                  total_processor_cost;

array[TASKS] of var TIMESTAMPS:              start;
array[TASKS] of var PROCS:                   r;
array[TASKS] of var 1..max(exec_times):      dur; % takes care of zeros in exec_times

array[PROCS] of var 0..max(processor_cost):  cost_of_using_processor;

array[TASKS, TASKS] of var 0..1:             tt; % time transfers
array[PROCS, PROCS] of var 0..1:             dt; % data transfers




% durations constraints,
constraint forall(t in TASKS)(
  element(r[t], [exec_times[t, p] | p in PROCS], dur[t])
);

% processor select
constraint cumulative(r, [1 | t in TASKS], dur, end_time);

% no overlaps
constraint forall (i in TASKS, j in TASKS) (
  j == i \/ 
  r[i] != r[j] \/ 
  start[i] + dur[i] <= start[j] \/ 
  start[j] + dur[j] <= start[i]
);

% data transfers matrices
constraint forall(t in TASKS, d in dependencies[t])(
  (r[d] == r[t]) \/ (tt[d, t] == 1 /\ dt[r[d], r[t]] == 1)
);

% time constraints
constraint forall(t in TASKS, d in dependencies[t])(
  start[d] + dur[d] + tt[d, t]  <= start[t] /\
  start[t] + dur[t] <= end_time
);

% cost constraints
constraint forall(p in PROCS)(
  (member(r, p) == true  /\ cost_of_using_processor[p] == processor_cost[p]) \/ 
  (member(r, p) == false /\ cost_of_using_processor[p] == 0)
);

constraint total_processor_cost == sum(cost_of_using_processor);
constraint total_cost == total_processor_cost + sum(dt);


% solve
var int: total;
constraint total = if (optimize_for_time) then end_time else total_cost endif;
solve minimize(total);

% output
output[
   "total time:   ", show(end_time)
  ,"\ntask:        [1, 2, 3, 4, 5, 6, 7, 8, 9]"
  ,"\nused proc(r) ", show(r)
  ,"\ndurations:   ", show(dur)
  ,"\nstart t:     ", show(start)
  ,"\ncost:        ", show(total_cost)
];