

function [pval, z] = utest (x, y)

 

  n_x  = length (x);
  n_y  = length (y);
  r    = ranksoctave ([(reshape (x, 1, n_x)), (reshape (y, 1, n_y))]);
  z    = (sum (r(1 : n_x)) - n_x * (n_x + n_y + 1) / 2) ...
           / sqrt (n_x * n_y * (n_x + n_y + 1) / 12);

  cdf  = stdnormal_cdf (z);


    pval = cdf;


  end
