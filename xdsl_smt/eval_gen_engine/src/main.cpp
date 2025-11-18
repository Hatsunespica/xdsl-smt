#include <iostream>
#include <iterator>
#include <optional>
#include <string>
#include <vector>

#include "AbstVal.h"
#include "Eval.h"
#include "Results.h"
#include "jit.h"
#include "utils.cpp"

template <typename D>
void handleDomain(const std::string &dataDir,
                  const std::vector<std::vector<std::string>> &synNames,
                  const std::string &srcCode) {
  Jit jit(srcCode);
  auto [low, med, high] = getValidSet<D>(dataDir, 2);

  Eval<D> e(std::move(jit), synNames);
  for (const Results &x : e.eval(high))
    x.print(std::cout);
  for (const Results &x : e.eval(med))
    x.print(std::cout);
  for (const Results &x : e.eval(low))
    x.print(std::cout);
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::vector<std::vector<std::string>> synNames = parseStrTupleList(std::cin);
  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  if (domain == "KnownBits") {
    handleDomain<KnownBits>(fname, synNames, fnSrcCode);
  }
  // else if (domain == "UConstRange") {
  //   handleDomain<UConstRange>(fname, synNames,
  //                                                  fnSrcCode);
  // } else if (domain == "SConstRange") {
  //   handleDomain<SConstRange>(fname, synNames,
  //                                                  fnSrcCode);
  // } else if (domain == "IntegerModulo") {
  //   handleDomain<IntegerModulo<6>>(
  //       fname, synNames, fnSrcCode);
  // } else {
  //   std::cerr << "Unknown domain: " << domain << "\n";
  //   exit(1);
  // }

  return 0;
}
