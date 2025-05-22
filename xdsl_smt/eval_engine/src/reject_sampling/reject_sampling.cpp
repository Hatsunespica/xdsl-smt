#include <iostream>
#include <string>
#include <vector>

#include "../AbstVal.h"
#include "../Eval.h"
#include "../jit.h"
#include "../utils.cpp"

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  std::vector<std::string> bFnNames = split_whitespace(tmpStr);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  if (domain == "KnownBits") {
    Eval<KnownBits> e(std::move(jit), {}, bFnNames);
    // auto a = e.rejectSample(unsigned int bw, unsigned int samples,
    // std::mt19937 &rng);
  } else if (domain == "ConstantRange") {
  } else if (domain == "IntegerModulo") {
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  return 0;
}
