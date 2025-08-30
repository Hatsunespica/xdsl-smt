//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  int out_s98 = 0;
  out_s98 = min(l2 * l1,  r1 * r2);
  int out_s98_0 = 0;
  out_s98_0 = min(l2 * r1,  r2 * l1);
  int out_s98_1 = 0;
  out_s98_1 = min(out_s98,  out_s98_0);
  _out1 = out_s98_1;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  int out_s100 = 0;
  out_s100 = max(r2 * r1,  l2 * l1);
  int out_s100_0 = 0;
  out_s100_0 = max(l2,  l1);
  int out_s98 = 0;
  out_s98 = min(r2,  r1);
  int out_s100_1 = 0;
  out_s100_1 = max(out_s100,  out_s100_0 * out_s98);
  _out1 = out_s100_1;
  return _out1;
}
