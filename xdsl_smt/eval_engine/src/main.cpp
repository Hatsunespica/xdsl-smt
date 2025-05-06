#include <iostream>
#include <iterator>
#include <string>
#include <vector>

#include "AbstVal.h"
#include "Eval.h"
#include "jit.h"

std::vector<std::string> split_whitespace(const std::string &input) {
  std::vector<std::string> result;
  std::istringstream iss(input);
  std::string word;
  while (iss >> word) {
    result.push_back(word);
  }
  return result;
}

int main() {
  std::string tmpStr;
  std::string domain;
  std::getline(std::cin, domain);

  std::getline(std::cin, tmpStr);
  unsigned int bw = static_cast<unsigned int>(std::stoul(tmpStr));
  std::getline(std::cin, tmpStr);
  std::vector<std::string> synNames = split_whitespace(tmpStr);
  std::getline(std::cin, tmpStr);
  std::vector<std::string> bFnNames = split_whitespace(tmpStr);
  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  std::unique_ptr<llvm::orc::LLJIT> jit = getJit(fnSrcCode);

  std::vector<Results> r;
  if (domain == "KnownBits")
    r = Eval<KnownBits>(std::move(jit), synNames, bFnNames, bw).eval();
  else if (domain == "ConstantRange")
    r = Eval<ConstantRange>(std::move(jit), synNames, bFnNames, bw).eval();
  else if (domain == "IntegerModulo")
    r = Eval<IntegerModulo<6>>(std::move(jit), synNames, bFnNames, bw).eval();
  else
    std::cerr << "Unknown domain: " << domain << "\n";

  for (unsigned int i = 0; i < r.size(); ++i) {
    std::cout << "bw: " << i + 1 << "\n";
    r[i].print();
    std::cout << "---\n";
  }

  return 0;
}
