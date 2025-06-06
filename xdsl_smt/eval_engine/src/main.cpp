#include <iostream>
#include <iterator>
#include <string>
#include <vector>

#include "AbstVal.h"
#include "Eval.h"
#include "jit.h"
#include "utils.cpp"

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::vector<std::string> synNames = getSplitLine(std::cin);
  std::vector<std::string> bFnNames = getSplitLine(std::cin);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  std::pair<std::vector<unsigned int>, std::vector<Results>> r;
  if (domain == "KnownBits") {
    auto [bws, toEval] = getToEval<KnownBits>(fname);
    r = {bws, Eval<KnownBits>(std::move(jit), synNames, bFnNames).eval(toEval)};
  } else if (domain == "UConstRange") {
    auto [bws, toEval] = getToEval<UConstRange>(fname);
    r = {bws,
         Eval<UConstRange>(std::move(jit), synNames, bFnNames).eval(toEval)};
  } else if (domain == "SConstRange") {
    auto [bws, toEval] = getToEval<SConstRange>(fname);
    r = {bws,
         Eval<SConstRange>(std::move(jit), synNames, bFnNames).eval(toEval)};
  } else if (domain == "IntegerModulo") {
    auto [bws, toEval] = getToEval<IntegerModulo<6>>(fname);
    r = {bws, Eval<IntegerModulo<6>>(std::move(jit), synNames, bFnNames)
                  .eval(toEval)};
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  for (unsigned int i = 0; i < r.first.size(); ++i) {
    std::cout << "bw: " << r.first[i] << "\n";
    r.second[i].print();
    std::cout << "---\n";
  }

  return 0;
}
