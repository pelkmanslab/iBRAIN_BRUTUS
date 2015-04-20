// A C++ implementation of running variance/standard deviation (Welford 1962)
// This follows http://www.johndcook.com/standard_deviation.html
// By brendan o'connor, anyall.org
// See main() on bottom for how to use
//     % g++ running_stat.cc               ## after editing in the main()
//     % ./a.out
//     added 0  now mean=0.00 var=0.00 std=0.00
//     added 1  now mean=0.50 var=0.25 std=0.50
//     added 2  now mean=1.00 var=0.67 std=0.82
//     added 3  now mean=1.50 var=1.25 std=1.12
//     added 4  now mean=2.00 var=2.00 std=1.41
//     added 5  now mean=2.50 var=2.92 std=1.71
//     added 6  now mean=3.00 var=4.00 std=2.00
//     added 7  now mean=3.50 var=5.25 std=2.29
//     added 8  now mean=4.00 var=6.67 std=2.58
//     added 9  now mean=4.50 var=8.25 std=2.87

#include <math.h>
#include <stdio.h>
#include <iostream>

#include "running_stat.h"

using namespace std;

#if 0
int main()
{
  RunningStat rs;
  rs.add(1);
  rs.add(1);
  rs.add(2);
  rs.add(0);
  rs.add(0);
  rs.add(0);
  cout << rs << endl;
  RunningStat rs2;
  rs2.add(0);
  rs2.add(0);
  rs2.add(0);
  rs2.add(1,2);
  rs2.add(2);
  cout << rs2 << endl;
  RunningStat rs3;
  rs3.add(1,2);
  rs3.add(2);
  rs3.add(0,3);
  cout << rs3 << endl;
}
#endif

int main() 
{
  RunningStat rs;

  for (int i=0; i < 10; i++) {
    rs.add(i);
    printf("added %-2d now mean=%.2f var=%.2f sd=%.2f\n", i,rs.mean(),rs.var(),rs.sd());
  }
  cout << endl;


  double x[10] = {0,1,2,3,4,5,6,7,8,9};
  cout << running_var(x,10) << endl;
  cout << running_var_double(x,10) << endl;


  float x2[10] = {0,1,2,3,4,5,6,7,8,9};
  cout << running_var(x2,10) << endl;


  int x3[10] = {0,1,2,3,4,5,6,7,8,9};
  cout << running_var(x3,10) << endl;

  return 0;
}
