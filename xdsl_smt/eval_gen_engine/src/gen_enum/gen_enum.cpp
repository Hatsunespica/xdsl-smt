#include <iostream>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

#include "../AbstVal.h"
#include "../jit.h"
#include "../utils.cpp"
#include "enum_domain.cpp"

template <AbstractDomain D>
void writeLat(const std::string &dirPath, const std::string &type,
              const std::vector<std::vector<std::vector<D>>> &lat) {
  for (const std::vector<std::vector<D>> &vecs : lat) {
    if (vecs.empty() || vecs[0].size() != 2)
      throw std::runtime_error("Expected samples of size 2 for gen enum");
    const std::string fname =
        makeVecFname(dirPath, type, vecs[0][0].bw(), vecs.size());
    write_vecs(fname, vecs, false);
  }
}

template <AbstractDomain D>
void handleDomain(Jit jit, const std::vector<unsigned int> &lbws,
                  // std::mt19937 &rng,
                  const std::string &dirPath) {
  EnumDomain<D> e(std::move(jit));

  const std::vector<std::vector<std::vector<D>>> lbwLat = e.genLows(lbws);

  writeLat(dirPath, "low", lbwLat);
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::vector<unsigned int> lbws = parseIntList(std::cin);
  std::vector<std::pair<unsigned int, unsigned int>> mbws =
      parsePairs(std::cin);
  std::vector<std::tuple<unsigned int, unsigned int, unsigned int>> hbws =
      parseTriples(std::cin);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  unsigned int seed = static_cast<unsigned int>(std::stoul(tmpStr));
  std::mt19937 rng(seed);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  if (domain == "KnownBits") {
    handleDomain<KnownBits>(std::move(jit), lbws, fname);
  } else if (domain == "UConstRange") {
    handleDomain<UConstRange>(std::move(jit), lbws, fname);
  } else if (domain == "SConstRange") {
    handleDomain<SConstRange>(std::move(jit), lbws, fname);
  } else if (domain == "IntegerModulo") {
    handleDomain<IntegerModulo<6>>(std::move(jit), lbws, fname);
  } else {
    std::cerr << "Unknown domain: " << domain << "\n";
    return 1;
  }

  return 0;
}
