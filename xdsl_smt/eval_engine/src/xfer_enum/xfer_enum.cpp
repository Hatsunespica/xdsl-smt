#include <iostream>
#include <random>
#include <string>
#include <vector>

#include "../AbstVal.h"
#include "../jit.h"
#include "../utils.cpp"
#include "enum_domain.cpp"

template <AbstractDomain D>
void writeLat(const std::string &dirPath, const std::string &type,
              const std::vector<std::vector<std::tuple<D, D, D>>> &lat) {
  for (const std::vector<std::tuple<D, D, D>> &vecs : lat) {
    const std::string fname =
        makeVecFname(dirPath, type, std::get<0>(vecs[0]).bw(), vecs.size());
    write_vecs(fname, vecs, false);
  }
}

template <AbstractDomain D>
void handleDomain(
    Jit jit, const std::vector<unsigned int> &lbws,
    const std::vector<std::pair<unsigned int, unsigned int>> &mbws,
    const std::vector<std::pair<unsigned int, unsigned int>> &hbws,
    std::mt19937 &rng, const std::string &dirPath) {
  EnumDomain<D> e(std::move(jit));

  const std::vector<std::vector<std::tuple<D, D, D>>> lbwLat = e.genLows(lbws);
  const std::vector<std::vector<std::tuple<D, D, D>>> mbwLat =
      e.genMids(mbws, rng);
  const std::vector<std::vector<std::tuple<D, D, D>>> hbwLat =
      e.genHighs(hbws, rng);

  writeLat(dirPath, "low", lbwLat);
  writeLat(dirPath, "med", mbwLat);
  writeLat(dirPath, "high", hbwLat);
}

int main() {
  std::string fname;
  std::getline(std::cin, fname);

  std::string domain;
  std::getline(std::cin, domain);

  std::vector<unsigned int> lbws = parseIntList(std::cin);
  std::vector<std::pair<unsigned int, unsigned int>> mbws =
      parsePairs(std::cin);
  std::vector<std::pair<unsigned int, unsigned int>> hbws =
      parsePairs(std::cin);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  unsigned int seed = static_cast<unsigned int>(std::stoul(tmpStr));
  std::mt19937 rng(seed);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  if (domain == "KnownBits") {
    handleDomain<KnownBits>(std::move(jit), lbws, mbws, hbws, rng, fname);
  } else if (domain == "UConstRange") {
    handleDomain<UConstRange>(std::move(jit), lbws, mbws, hbws, rng, fname);
  } else if (domain == "SConstRange") {
    handleDomain<SConstRange>(std::move(jit), lbws, mbws, hbws, rng, fname);
  } else if (domain == "IntegerModulo") {
    handleDomain<IntegerModulo<6>>(std::move(jit), lbws, mbws, hbws, rng,
                                   fname);
  } else {
    std::cerr << "Unknown domain: " << domain << "\n";
    return 1;
  }

  return 0;
}
