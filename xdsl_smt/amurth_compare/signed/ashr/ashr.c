//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  bit[8] zero = ((bit[8]){0});
  int _out1_s21 = 0;
  _out1_s21 = bitToInt(zero);
  bit[8] x_s25 = {0,0,0,0,0,0,0,0};
  x_s25 = intToBit(_out1_s21);
  bit[8] y_s29 = {0,0,0,0,0,0,0,0};
  y_s29 = intToBit(l1);
  bit[8] _out_s47 = {0,0,0,0,0,0,0,0};
  _out_s47 = arithRShift(y_s29,  l2);
  int _out1_s49 = 0;
  _out1_s49 = bitToIntS(_out_s47);
  _out1 = _out1_s49;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  bit[8] zero = ((bit[8]){0});
  int _out1_s21 = 0;
  _out1_s21 = bitToInt(zero);
  bit[8] x_s25 = {0,0,0,0,0,0,0,0};
  x_s25 = intToBit(_out1_s21);
  bit[8] y_s29 = {0,0,0,0,0,0,0,0};
  y_s29 = intToBit(r1);
  bit[8] _out_s47 = {0,0,0,0,0,0,0,0};
  _out_s47 = arithRShift(y_s29,  l2);
  int _out1_s49 = 0;
  _out1_s49 = bitToIntS(_out_s47);
  _out1 = _out1_s49;
  return _out1;
}
