//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out0;
  bit[8] x_s24 = {0,0,0,0,0,0,0,0};
  x_s24 = intToBit(r1);
  bit[8] y_s28 = {0,0,0,0,0,0,0,0};
  y_s28 = intToBit(l1);
  bit[8] _out_s46 = {0,0,0,0,0,0,0,0};
  _out_s46 = arithRShift(y_s28,  l2);
  int _out0_s48 = 0;
  _out0_s48 = bitToInt(_out_s46);
  _out0 = _out0_s48;
  return _out0;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out0;
  bit[8] x_s24 = {0,0,0,0,0,0,0,0};
  x_s24 = intToBit(r1);
  bit[8] y_s28 = {0,0,0,0,0,0,0,0};
  y_s28 = intToBit(l1);
  bit[8] _out_s34 = {0,0,0,0,0,0,0,0};
  _out_s34 = bvrshiftN(x_s24,  l2);
  int _out0_s36 = 0;
  _out0_s36 = bitToInt(_out_s34);
  _out0 = _out0_s36;
  return _out0;
}
