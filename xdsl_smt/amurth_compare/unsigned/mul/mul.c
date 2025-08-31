//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out0;
  int _out0_s91 = 0;
  _out0_s91 = modularMul(l2,  l1);
  _out0 = _out0_s91;
  return _out0;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out0;
  int _out0_s103 = 0;
  _out0_s103 = overflow(r1,  r2);
  if(_out0_s103 == 1)
  {
    _out0 = 15;
  return _out0;
  }
  else
  {
    int out_s95 = 0;
  out_s95 = max(l2,  r1);
    int _out0_s91 = 0;
  _out0_s91 = modularMul(r2,  r1);
    int out_s95_0 = 0;
  out_s95_0 = max(r2,  l1);
    int out_s93 = 0;
  out_s93 = min(_out0_s91,  out_s95_0);
    int _out0_s91_0 = 0;
  _out0_s91_0 = modularMul(out_s95,  out_s93);
    _out0 = _out0_s91_0;
  return _out0;
  }
}
