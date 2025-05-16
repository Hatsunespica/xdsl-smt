#include <iostream>
#include <string>
#include <vector>

#include "../AbstVal.h"
#include "../Eval.h"
#include "../jit.h"
#include "../utils.cpp"

template <typename D>
void handleDomain(std::unique_ptr<llvm::orc::LLJIT> jit, unsigned int bw,
                  std::optional<std::pair<unsigned int, unsigned int>> samples,
                  const std::string dirPath) {
  EnumXfer<D> e(std::move(jit), bw);

  if (samples) {
    const std::vector<std::tuple<D, D, D>> data =
        e.genRand(samples->first, samples->second);
    const std::string fname = dirPath + "bw " + std::to_string(bw) +
                              " samples " + std::to_string(data.size());
    write_vecs(fname, data);
  } else {
    std::vector<std::vector<std::tuple<D, D, D>>> r = e.genAllBws();
    for (unsigned int i = 0; i < r.size(); ++i) {
      const std::string fname = dirPath + "bw " + std::to_string(i + 1) +
                                " samples " + std::to_string(r[i].size());
      write_vecs(fname, r[i]);
    }
  }
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  unsigned int bw = static_cast<unsigned int>(std::stoul(tmpStr));

  std::getline(std::cin, tmpStr);
  std::vector<std::string> tmpVec = split_whitespace(tmpStr);
  std::optional<std::pair<unsigned int, unsigned int>> samples = std::nullopt;
  if (tmpVec.size() != 0)
    samples = {static_cast<unsigned int>(std::stoul(tmpVec[0])),
               static_cast<unsigned int>(std::stoul(tmpVec[1]))};

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  std::unique_ptr<llvm::orc::LLJIT> jit = getJit(fnSrcCode);

  if (domain == "KnownBits") {
    handleDomain<KnownBits>(std::move(jit), bw, samples, fname);
  } else if (domain == "ConstantRange") {
    handleDomain<ConstantRange>(std::move(jit), bw, samples, fname);
  } else if (domain == "IntegerModulo") {
    handleDomain<IntegerModulo<6>>(std::move(jit), bw, samples, fname);
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  return 0;
}
