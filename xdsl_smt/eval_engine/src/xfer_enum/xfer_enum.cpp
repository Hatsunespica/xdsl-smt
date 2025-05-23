#include <iostream>
#include <string>
#include <vector>

#include "../AbstVal.h"
#include "../Eval.h"
#include "../jit.h"
#include "../utils.cpp"

template <typename D>
void handleDomain(Jit jit, unsigned int ubw, unsigned int lbw,
                  std::optional<std::pair<unsigned int, unsigned int>> samples,
                  const std::string dirPath) {
  EnumXfer<D> e(std::move(jit), lbw, ubw);
  std::vector<std::vector<std::tuple<D, D, D>>> r =
      samples ? e.genAllBwsRand(samples->first, samples->second)
              : e.genAllBws();
  for (const std::vector<std::tuple<D, D, D>> &vecs : r) {
    const std::string fname =
        makeVecFname(dirPath, std::get<0>(vecs[0]).bw(), vecs.size());
    write_vecs(fname, vecs, false);
  }
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  unsigned int ubw = static_cast<unsigned int>(std::stoul(tmpStr));

  std::getline(std::cin, tmpStr);
  unsigned int lbw = static_cast<unsigned int>(std::stoul(tmpStr));

  std::getline(std::cin, tmpStr);
  std::vector<std::string> tmpVec = split_whitespace(tmpStr);
  std::optional<std::pair<unsigned int, unsigned int>> samples = std::nullopt;
  if (tmpVec.size() != 0)
    samples = {static_cast<unsigned int>(std::stoul(tmpVec[0])),
               static_cast<unsigned int>(std::stoul(tmpVec[1]))};

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  if (domain == "KnownBits") {
    handleDomain<KnownBits>(std::move(jit), ubw, lbw, samples, fname);
  } else if (domain == "ConstantRange") {
    handleDomain<ConstantRange>(std::move(jit), ubw, lbw, samples, fname);
  } else if (domain == "IntegerModulo") {
    handleDomain<IntegerModulo<6>>(std::move(jit), ubw, lbw, samples, fname);
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  return 0;
}
