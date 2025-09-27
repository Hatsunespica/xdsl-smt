//#include "/root/amurth/aux_function/aux_function.c"
void bitWiseTemplateWrapped_c (int a, int b, int c, int d, int bnd, ref int[2] result)
{
  int[4] s1_s26 = {0,0,0,0};
  s1_s26 = intervalSSplit(a,  b);
  int[4] s2_s28 = {0,0,0,0};
  s2_s28 = intervalSSplit(c,  d);
  result = {s1_s26[0],s1_s26[1]};
  for(int i = 0; i < 2; i = i + 1)
  {
    for(int j = 0; j < 2; j = j + 1)
    {
      int a_0 = s1_s26[i * 2];
      int b_0 = s1_s26[(i * 2) + 1];
      int c_0 = s2_s28[j * 2];
      int d_0 = s2_s28[(j * 2) + 1];
      int _out1_s40 = 0;
  _out1_s40 = minAND(a_0,  b_0,  c_0,  d_0);
      int a_1 = s1_s26[i * 2];
      int b_1 = s1_s26[(i * 2) + 1];
      int c_1 = s2_s28[j * 2];
      int d_1 = s2_s28[(j * 2) + 1];
      int _out1_s44 = 0;
  _out1_s44 = maxAND(a_1,  b_1,  c_1,  d_1);
      Join(_out1_s40, _out1_s44, result[0], result[1], result);
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
