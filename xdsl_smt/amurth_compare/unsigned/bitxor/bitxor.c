//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  int _out1_s51 = 0;
  _out1_s51 = bvNot(r2);
  int _out1_s53 = 0;
  _out1_s53 = bvNot(l2);
  int _out1_s55 = 0;
  _out1_s55 = minAND(l1,  r1,  _out1_s51,  _out1_s53);
  int _out1_s57 = 0;
  _out1_s57 = bvNot(r1);
  int _out1_s59 = 0;
  _out1_s59 = bvNot(l1);
  int _out1_s61 = 0;
  _out1_s61 = minAND(_out1_s57,  _out1_s59,  l2,  r2);
  int _out1_s97 = 0;
  _out1_s97 = maxOr(0,  _out1_s55,  0,  _out1_s61);
  _out1 = _out1_s97;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  int _out1_s69 = 0;
  _out1_s69 = bvNot(r1);
  int _out1_s71 = 0;
  _out1_s71 = bvNot(l1);
  int _out1_s73 = 0;
  _out1_s73 = minOr(_out1_s69,  _out1_s71,  l2,  r2);
  int _out1_s75 = 0;
  _out1_s75 = bvNot(r2);
  int _out1_s77 = 0;
  _out1_s77 = bvNot(l2);
  int _out1_s79 = 0;
  _out1_s79 = maxAND(l1,  r1,  _out1_s75,  _out1_s77);
  int _out1_s97 = 0;
  _out1_s97 = maxOr(0,  _out1_s73,  0,  _out1_s79);
  int _out1_s81 = 0;
  _out1_s81 = bvNot(r1);
  int _out1_s83 = 0;
  _out1_s83 = bvNot(l1);
  int _out1_s85 = 0;
  _out1_s85 = maxAND(_out1_s81,  _out1_s83,  l2,  r2);
  int _out1_s75_0 = 0;
  _out1_s75_0 = bvNot(r2);
  int _out1_s77_0 = 0;
  _out1_s77_0 = bvNot(l2);
  int _out1_s79_0 = 0;
  _out1_s79_0 = maxAND(l1,  r1,  _out1_s75_0,  _out1_s77_0);
  int _out1_s97_0 = 0;
  _out1_s97_0 = maxOr(0,  _out1_s85,  0,  _out1_s79_0);
  int _out1_s101 = 0;
  _out1_s101 = maxAND(0,  _out1_s97,  0,  _out1_s97_0);
  _out1 = _out1_s101;
  return _out1;
}
