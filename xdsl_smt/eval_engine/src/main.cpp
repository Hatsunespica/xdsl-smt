#include <filesystem>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

#include "AbstVal.h"
#include "Eval.h"
#include "jit.h"
#include "utils.cpp"

template <AbstractDomain D>
const std::pair<std::vector<unsigned int>,
                std::vector<std::vector<std::tuple<D, D, D>>>>
getToEval(const std::string dirName) {
  std::vector<std::vector<std::tuple<D, D, D>>> v;
  std::vector<unsigned int> bws;

  for (const std::filesystem::directory_entry &entry :
       std::filesystem::directory_iterator(dirName)) {
    std::vector<std::string> split_fname = split_whitespace(entry.path());
    unsigned int elems = static_cast<unsigned int>(
        std::atol(split_fname[split_fname.size() - 1].data()));

    bws.push_back(static_cast<unsigned int>(
        std::atol(split_fname[split_fname.size() - 3].data())));

    v.push_back(read_vecs<D>(entry.path(), elems));
  }

  return {bws, v};
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  std::vector<std::string> synNames = split_whitespace(tmpStr);

  std::getline(std::cin, tmpStr);
  std::vector<std::string> bFnNames = split_whitespace(tmpStr);

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
