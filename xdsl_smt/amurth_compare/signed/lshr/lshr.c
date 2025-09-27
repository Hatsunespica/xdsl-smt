//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  bit[8] zero = ((bit[8]){0});
  int _out1_s23 = 0;
  _out1_s23 = bitToInt(zero);
  bit[8] x_s27 = {0,0,0,0,0,0,0,0};
  x_s27 = intToBit(_out1_s23);
  bit[8] y_s31 = {0,0,0,0,0,0,0,0};
  y_s31 = intToBit(l1);
  bit[8] _out_s45 = {0,0,0,0,0,0,0,0};
  _out_s45 = bvrshiftN(y_s31,  l2);
  int _out1_s47 = 0;
  _out1_s47 = bitToInt(_out_s45);
  _out1 = _out1_s47;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  bit[8] x_s27 = {0,0,0,0,0,0,0,0};
  x_s27 = intToBit(l1);
  bit[8] y_s31 = {0,0,0,0,0,0,0,0};
  y_s31 = intToBit(r1);
  bit[8] _out_s45 = {0,0,0,0,0,0,0,0};
  _out_s45 = bvrshiftN(y_s31,  l2);
  int _out1_s47 = 0;
  _out1_s47 = bitToInt(_out_s45);
  _out1 = _out1_s47;
  return _out1;
}
