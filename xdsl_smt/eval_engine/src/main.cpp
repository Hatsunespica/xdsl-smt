#include <filesystem>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

#include "AbstVal.h"
#include "Eval.h"
#include "jit.h"
#include "utils.cpp"

template <typename D>
const std::vector<std::vector<std::tuple<D, D, D>>>
getToEval(const std::string dirName) {
  std::vector<std::vector<std::tuple<D, D, D>>> v;

  for (const std::filesystem::directory_entry &entry :
       std::filesystem::directory_iterator(dirName)) {
    std::vector<std::string> a = split_whitespace(entry.path());
    std::cout << "opening: " << entry.path() << "\n";
    std::cout << "num elems: " << std::atol(a[a.size() - 1].data()) << "\n";
    unsigned int elems =
        static_cast<unsigned int>(std::atol(a[a.size() - 1].data()));
    v.push_back(read_vecs<D>(entry.path(), elems));
  }

  return v;
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
  std::unique_ptr<llvm::orc::LLJIT> jit = getJit(fnSrcCode);

  std::vector<Results> r;
  if (domain == "KnownBits") {
    const std::vector<std::vector<std::tuple<KnownBits, KnownBits, KnownBits>>>
        toEval = getToEval<KnownBits>(fname);
    Eval<KnownBits> e(std::move(jit), synNames, bFnNames, toEval);
    r = e.eval();
  } else if (domain == "ConstantRange") {
    const std::vector<
        std::vector<std::tuple<ConstantRange, ConstantRange, ConstantRange>>>
        toEval = getToEval<ConstantRange>(fname);
    Eval<ConstantRange> e(std::move(jit), synNames, bFnNames, toEval);
    r = e.eval();
  } else if (domain == "IntegerModulo") {
    const std::vector<std::vector<
        std::tuple<IntegerModulo<6>, IntegerModulo<6>, IntegerModulo<6>>>>
        toEval = getToEval<IntegerModulo<6>>(fname);
    Eval<IntegerModulo<6>> e(std::move(jit), synNames, bFnNames, toEval);
    r = e.eval();
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  for (unsigned int i = 0; i < r.size(); ++i) {
    r[i].print();
    std::cout << "---\n";
  }

  return 0;
}
