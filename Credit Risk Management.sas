libname disk "/home/u59060687/my_shared_file_links/kevin_7140/Data";

*calculate realized LGD;
*step 1: merge facility and client(borrower) data;
proc sort data=disk.facility out=facility;
  by id;
run;

proc sort data=disk.client out=client;
  by id;
run;

*inner join client and facility dataset;
data client_facility;
  merge client(in=a) facility(in=b);
  by id;
  if a=1 and b=1;
run;


*Step 2: merge client_facility and transaction data, select post-default transactions only;
*in this step we can also set up the discount rate and calculate the discounted cash flow amount;
proc sort data=client_facility;
  by fid;
run;
proc sort data=disk.transaction out=transaction;
  by fid;
run;

*left join client_facility;
data lgd;
  merge client_facility(in=a) transaction(in=b);
  by fid;
  if a = 1;
  trans_date_num = input(trans_date,date9.);
  if trans_date_num >= df_date or trans_date_num = .;
run;


*calculate LGD for each facility;
*outstanding trans_amt trans_date_num df_date 10%;
*exclude outstanding = 0;
*first.by last.by;

data lgd_realized;
  set lgd;
  by fid;
  where outstanding ne 0;
  discounted_trans_amt = 
	trans_amt/(1+0.1)**((trans_date_num-df_date)/365);
  if first.fid then sum = 0;
  sum + discounted_trans_amt;
  if last.fid then output;
run;

data lgd_realized2;
  set lgd_realized;
  lgd = (outstanding - sum)/outstanding;
run;
