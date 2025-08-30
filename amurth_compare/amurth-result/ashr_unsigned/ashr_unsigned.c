//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  bit[8] x_s29 = {0,0,0,0,0,0,0,0};
  x_s29 = intToBit(r1);
  bit[8] y_s33 = {0,0,0,0,0,0,0,0};
  y_s33 = intToBit(l1);
  bit[8] _out_s51 = {0,0,0,0,0,0,0,0};
  _out_s51 = arithRShift(y_s33,  l2);
  int _out1_s53 = 0;
  _out1_s53 = bitToInt(_out_s51);
  _out1 = _out1_s53;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  bit[8] x_s29 = {0,0,0,0,0,0,0,0};
  x_s29 = intToBit(r1);
  bit[8] y_s33 = {0,0,0,0,0,0,0,0};
  y_s33 = intToBit(r1);
  bit[8] _out_s51 = {0,0,0,0,0,0,0,0};
  _out_s51 = arithRShift(y_s33,  l2);
  int _out1_s53 = 0;
  _out1_s53 = bitToInt(_out_s51);
  _out1 = _out1_s53;
  return _out1;
}
