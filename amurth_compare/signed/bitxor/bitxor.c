//#include "/root/amurth/aux_function/aux_function.c"
void bitWiseTemplateWrapped_c (int a, int b, int c, int d, int bnd, ref int[2] result)
{
  int[4] s1_s34 = {0,0,0,0};
  s1_s34 = intervalSSplit(a,  b);
  int[4] s2_s36 = {0,0,0,0};
  s2_s36 = intervalSSplit(c,  d);
  result = {s1_s34[0],s1_s34[1]};
  for(int i = 0; i < 2; i = i + 1)
  {
    for(int j = 0; j < 2; j = j + 1)
    {
      int a_0 = s1_s34[i * 2];
      int b_0 = s1_s34[(i * 2) + 1];
      int c_0 = s2_s36[j * 2];
      int d_0 = s2_s36[(j * 2) + 1];
      int _out1_s86 = 0;
  _out1_s86 = bvNot(b_0);
      int _out1_s88 = 0;
  _out1_s88 = bvNot(a_0);
      int _out1_s90 = 0;
  _out1_s90 = minAND(_out1_s86,  _out1_s88,  c_0,  d_0);
      int _out1_s92 = 0;
  _out1_s92 = bvNot(d_0);
      int _out1_s94 = 0;
  _out1_s94 = bvNot(c_0);
      int _out1_s96 = 0;
  _out1_s96 = minAND(a_0,  b_0,  _out1_s92,  _out1_s94);
      int _out1_s108 = 0;
  _out1_s108 = maxOr(0,  _out1_s90,  0,  _out1_s96);
      int a_1 = s1_s34[i * 2];
      int b_1 = s1_s34[(i * 2) + 1];
      int c_1 = s2_s36[j * 2];
      int d_1 = s2_s36[(j * 2) + 1];
      int _out1_s80 = 0;
  _out1_s80 = bvNot(b_1);
      int _out1_s82 = 0;
  _out1_s82 = bvNot(a_1);
      int _out1_s84 = 0;
  _out1_s84 = maxAND(_out1_s80,  _out1_s82,  c_1,  d_1);
      int _out1_s74 = 0;
  _out1_s74 = bvNot(d_1);
      int _out1_s76 = 0;
  _out1_s76 = bvNot(c_1);
      int _out1_s78 = 0;
  _out1_s78 = maxAND(a_1,  b_1,  _out1_s74,  _out1_s76);
      int _out1_s108_0 = 0;
  _out1_s108_0 = maxOr(0,  _out1_s84,  0,  _out1_s78);
      Join(_out1_s108, _out1_s108_0, result[0], result[1], result);
    }
  }
}
 int  absleft_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  int[2] _out = {0,0};
  bitWiseTemplateWrapped_c(l1, r1, l2, r2, 2, _out);
  _out1 = _out[0];
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 ) 
{
  int _out1;
  int[2] _out = {0,0};
  bitWiseTemplateWrapped_c(l1, r1, l2, r2, 2, _out);
  _out1 = _out[1];
  return _out1;
}
