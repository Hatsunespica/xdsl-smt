//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  bit[8] zero = ((bit[8]){0});
  int _out1_s17 = 0;
  _out1_s17 = bitToInt(zero);
  bit[8] x_s21 = {0,0,0,0,0,0,0,0};
  x_s21 = intToBit(_out1_s17);
  bit[8] y_s25 = {0,0,0,0,0,0,0,0};
  y_s25 = intToBit(l1);
  bit[8] _out_s35 = {0,0,0,0,0,0,0,0};
  _out_s35 = bvlshiftN(y_s25,  l2);
  int _out1_s37 = 0;
  _out1_s37 = bitToInt(_out_s35);
  _out1 = _out1_s37;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  bit[8] zero = ((bit[8]){0});
  int _out1_s17 = 0;
  _out1_s17 = bitToInt(zero);
  bit[8] x_s21 = {0,0,0,0,0,0,0,0};
  x_s21 = intToBit(_out1_s17);
  bit[8] y_s25 = {0,0,0,0,0,0,0,0};
  y_s25 = intToBit(r1);
  bit[8] _out_s35 = {0,0,0,0,0,0,0,0};
  _out_s35 = bvlshiftN(y_s25,  l2);
  int _out1_s37 = 0;
  _out1_s37 = bitToInt(_out_s35);
  _out1 = _out1_s37;
  return _out1;
}
