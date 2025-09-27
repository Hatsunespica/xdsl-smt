//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  int _out1_s26 = 0;
  _out1_s26 = minAND(l1,  r1,  l2,  r2);
  _out1 = _out1_s26;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  int _out1_s30 = 0;
  _out1_s30 = maxAND(l1,  r1,  l2,  r2);
  _out1 = _out1_s30;
  return _out1;
}
