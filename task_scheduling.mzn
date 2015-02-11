include "globals.mzn";

int: nbrOfTasks = 9;
int: nbrOfProcessors = 6;

array [1..nbrOfTasks] of var 1..nbrOfProcessors: t; %t[i] is the processor assign to task i

array[1..nbrOfProcessors, 1..nbrOfTasks] of int: times = [|  
2, 2, 1,  1,  1, 1,  3,  0,  1, | 
2, 2, 1,  1,  1, 1,  3,  0,  1, | 
3, 1, 1,  3,  1, 2,  1,  2,  1, | 
3, 1, 1,  3,  1, 2,  1,  2,  1, | 
1, 1, 2,  0,  3, 1,  4,  1,  3, |
1, 1, 2,  0,  3, 1,  4,  1,  3  |];

%array [1..nbrOfTasks] of var 1..4: execTimes; %The bound 1..4 falsifies zero times
%constraint forall (i in 1..nbrOfTasks)(
%  execTimes[i] = times[t[i],i]
%);
constraint t[4] != 5 /\ t[4] != 6 /\
           t[8] != 1 /\ t[8] != 2;


% Simultaneous execution
array [1..nbrOfProcessors] of var 1..36: allotedTime;
constraint forall (i in 1..nbrOfProcessors)(
  allotedTime[i] = sum(j in 1..nbrOfTasks)(if t[j] == i then times[t[j], j] else 0 endif)
);


% Task dependencies
% t[4] = p1 krävs att t[1] = p1
% t[4] =1 kräver att t[1]=1 eller så blir allotedTime[1]=allotedTime[1]+1
%var 0..36: bonustime;
array [1..nbrOfTasks] of var 0..2: transfers;
constraint sum(transfers) > 0;
constraint transfers[1] == 0;
constraint transfers[2] == 0;
constraint transfers[3] == 0;
constraint transfers[8] >= 1;
constraint transfers[9] >= 1;
constraint 
(t[1]==t[4] \/ transfers[4] == 1) /\
(t[2]==t[5] \/ transfers[5] == 1) /\
(t[3]==t[6] \/ transfers[6] == 1) /\
(t[4]==t[7] \/ transfers[7] == 1) /\
((t[4]==t[8] \/ t[5]==t[8]) \/ transfers[8] == 2) /\
((t[5]==t[9] \/ t[6]==t[9]) \/ transfers[9] == 2);


% Cost problem



var 1..36: maxTime;
constraint maximum(maxTime, allotedTime);

solve minimize maxTime+sum(transfers);
output["Time: ", show(maxTime+sum(transfers)),
"\nTasks: ", show(t),
"\nTransfers: ", show(transfers)];