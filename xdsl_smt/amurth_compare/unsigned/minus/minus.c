//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  int out_s40 = 0;
  out_s40 = max(l2,  l2);
  int out_s38 = 0;
  out_s38 = min(r1,  l2);
  int _out1_s36 = 0;
  _out1_s36 = modularMinus(out_s40,  out_s38);
  _out1 = _out1_s36;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  int _out1_s36 = 0;
  _out1_s36 = modularMinus(r1,  l2);
  int _out1_s36_0 = 0;
  _out1_s36_0 = modularMinus(r1,  r2);
  int out_s40 = 0;
  out_s40 = max(_out1_s36,  _out1_s36_0);
  _out1 = out_s40;
  return _out1;
}
