#include <iostream>
#include <iterator>
#include <optional>
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
  std::vector<std::string> tmpVec = split_whitespace(tmpStr);
  std::optional<std::pair<unsigned int, unsigned int>> samples = std::nullopt;
  if (tmpVec.size() != 0)
    samples = {static_cast<unsigned int>(std::stoul(tmpVec[0])),
               static_cast<unsigned int>(std::stoul(tmpVec[1]))};
  std::getline(std::cin, tmpStr);
  std::vector<std::string> synNames = split_whitespace(tmpStr);
  std::getline(std::cin, tmpStr);
  std::vector<std::string> bFnNames = split_whitespace(tmpStr);
  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  std::unique_ptr<llvm::orc::LLJIT> jit = getJit(fnSrcCode);

  std::vector<Results> r;
  if (domain == "KnownBits") {
    Eval<KnownBits> e(std::move(jit), synNames, bFnNames, bw);
    if (samples)
      r = {e.evalSamples(samples.value().first, samples.value().second)};
    else
      r = e.eval();
  } else if (domain == "ConstantRange") {
    Eval<ConstantRange> e(std::move(jit), synNames, bFnNames, bw);
    if (samples)
      r = {e.evalSamples(samples.value().first, samples.value().second)};
    else
      r = e.eval();
  } else if (domain == "IntegerModulo") {
    Eval<IntegerModulo<6>> e(std::move(jit), synNames, bFnNames, bw);
    if (samples)
      r = {e.evalSamples(samples.value().first, samples.value().second)};
    else
      r = e.eval();
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  if (samples) {
    std::cout << "bw: " << bw << "\n";
    r[0].print();
    std::cout << "---\n";
  } else {
    for (unsigned int i = 0; i < r.size(); ++i) {
      std::cout << "bw: " << i + 1 << "\n";
      r[i].print();
      std::cout << "---\n";
    }
  }

  return 0;
}
