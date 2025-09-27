//#include "/root/amurth/aux_function/aux_function.c"
 int  absleft_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  int _out_s291 = 0;
  if((((l1 < 0) && (r1 < 0)) && (l2 < 0)) && (r2 < 0))
  {
    int _out1_s149 = 0;
  _out1_s149 = minOr(l1,  r1,  l2,  r2);
    _out_s291 = _out1_s149;
  }
  else
  {
    if((((l1 < 0) && (r1 < 0)) && (l2 < 0)) && (!(r2 < 0)))
    {
      _out_s291 = l1;
    }
    else
    {
      if((((l1 < 0) && (r1 < 0)) && (!(l2 < 0))) && (!(r2 < 0)))
      {
        int _out1_s149_0 = 0;
  _out1_s149_0 = minOr(l1,  r1,  l2,  r2);
        _out_s291 = _out1_s149_0;
      }
      else
      {
        if((((l1 < 0) && (!(r1 < 0))) && (l2 < 0)) && (r2 < 0))
        {
          _out_s291 = l2;
        }
        else
        {
          if((((l1 < 0) && (!(r1 < 0))) && (l2 < 0)) && (!(r2 < 0)))
          {
            int _out1_s153 = 0;
  _out1_s153 = smin(l1,  l2);
            _out_s291 = _out1_s153;
          }
          else
          {
            if((((l1 < 0) && (!(r1 < 0))) && (!(l2 < 0))) && (!(r2 < 0)))
            {
              int _out1_s157 = 0;
  _out1_s157 = minOr(l1,  -1,  l2,  r2);
              _out_s291 = _out1_s157;
            }
            else
            {
              if((((!(l1 < 0)) && (!(r1 < 0))) && (l2 < 0)) && (r2 < 0))
              {
                int _out1_s149_1 = 0;
  _out1_s149_1 = minOr(l1,  r1,  l2,  r2);
                _out_s291 = _out1_s149_1;
              }
              else
              {
                if((((!(l1 < 0)) && (!(r1 < 0))) && (l2 < 0)) && (!(r2 < 0)))
                {
                  int _out1_s161 = 0;
  _out1_s161 = minOr(l1,  r1,  l2,  -1);
                  _out_s291 = _out1_s161;
                }
                else
                {
                  if((((!(l1 < 0)) && (!(r1 < 0))) && (!(l2 < 0))) && (!(r2 < 0)))
                  {
                    int _out1_s149_2 = 0;
  _out1_s149_2 = minOr(l1,  r1,  l2,  r2);
                    _out_s291 = _out1_s149_2;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  _out1 = _out_s291;
  return _out1;
}
 int  absright_c ( int l1, int r1, int l2, int r2 )
{
  int _out1;
  int _out_s129 = 0;
  if((((l1 < 0) && (r1 < 0)) && (l2 < 0)) && (r2 < 0))
  {
    int _out1_s151 = 0;
  _out1_s151 = maxOr(l1,  r1,  l2,  r2);
    _out_s129 = _out1_s151;
  }
  else
  {
    if((((l1 < 0) && (r1 < 0)) && (l2 < 0)) && (!(r2 < 0)))
    {
      _out_s129 = -1;
    }
    else
    {
      if((((l1 < 0) && (r1 < 0)) && (!(l2 < 0))) && (!(r2 < 0)))
      {
        int _out1_s151_0 = 0;
  _out1_s151_0 = maxOr(l1,  r1,  l2,  r2);
        _out_s129 = _out1_s151_0;
      }
      else
      {
        if((((l1 < 0) && (!(r1 < 0))) && (l2 < 0)) && (r2 < 0))
        {
          _out_s129 = -1;
        }
        else
        {
          if((((l1 < 0) && (!(r1 < 0))) && (l2 < 0)) && (!(r2 < 0)))
          {
            int _out1_s163 = 0;
  _out1_s163 = maxOr(l1,  r1,  0,  r2);
            _out_s129 = _out1_s163;
          }
          else
          {
            if((((l1 < 0) && (!(r1 < 0))) && (!(l2 < 0))) && (!(r2 < 0)))
            {
              int _out1_s163_0 = 0;
  _out1_s163_0 = maxOr(l1,  r1,  0,  r2);
              _out_s129 = _out1_s163_0;
            }
            else
            {
              if((((!(l1 < 0)) && (!(r1 < 0))) && (l2 < 0)) && (r2 < 0))
              {
                int _out1_s151_1 = 0;
  _out1_s151_1 = maxOr(l1,  r1,  l2,  r2);
                _out_s129 = _out1_s151_1;
              }
              else
              {
                if((((!(l1 < 0)) && (!(r1 < 0))) && (l2 < 0)) && (!(r2 < 0)))
                {
                  int _out1_s159 = 0;
  _out1_s159 = maxOr(0,  r1,  l2,  r2);
                  _out_s129 = _out1_s159;
                }
                else
                {
                  if((((!(l1 < 0)) && (!(r1 < 0))) && (!(l2 < 0))) && (!(r2 < 0)))
                  {
                    int _out1_s151_2 = 0;
  _out1_s151_2 = maxOr(l1,  r1,  l2,  r2);
                    _out_s129 = _out1_s151_2;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  _out1 = _out_s129;
  return _out1;
}
