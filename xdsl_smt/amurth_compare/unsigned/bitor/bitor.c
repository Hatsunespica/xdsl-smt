//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 )
{
  int _out0;
  int _out0_s22 = 0;
  _out0_s22 = minOr(l1,  r1,  l2,  r2);
  _out0 = _out0_s22;
  return _out0;
}
 int  absright_c ( int l1, int r1, int l2, int r2 )
{
  int _out0;
  int _out0_s26 = 0;
  _out0_s26 = maxOr(l1,  r1,  l2,  r2);
  _out0 = _out0_s26;
  return _out0;
}
