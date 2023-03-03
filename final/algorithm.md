# Algorithm and steps
0. Set up 2 stacks, 2 data types, unsigned value and operator
1. Determine the mode. If mode 0 goes to 2, mode 1 to 3, mode 2 to 4, mode 3 to 5
2. Note prefix can actually be implemented in terms of postfix. So you actually only needs to implement the postfix one, prefix is
simply postfix with reversed sequence.