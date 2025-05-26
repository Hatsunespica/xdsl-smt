#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

#include "../AbstVal.h"
#include "../Eval.h"
#include "../jit.h"
#include "../utils.cpp"

const std::vector<std::string> getFiles(const std::string dirName) {
  std::vector<std::string> fnames;

  for (const std::filesystem::directory_entry &entry :
       std::filesystem::directory_iterator(dirName)) {
    std::vector<std::string> split_fname = split_whitespace(entry.path());
    if (std::atol(split_fname[split_fname.size() - 3].data()) > 4)
      fnames.push_back(entry.path());
  }

  if (fnames.size() == 0) {
    std::cerr << "No data sets with bitwidth > 4 were found.\n";
    exit(1);
  }

  return fnames;
}

template <typename D>
void handleDomain(const Eval<D> &e, const std::string &dirPath,
                  unsigned int samples, unsigned int seed) {
  std::vector<std::string> fnames = getFiles(dirPath);
  unsigned int samples_per = samples / fnames.size();
  std::mt19937 rng(seed);

  for (const std::string &fname : fnames) {
    std::vector<std::string> split_fname = split_whitespace(fname);
    unsigned int old_size = static_cast<unsigned int>(
        std::atol(split_fname[split_fname.size() - 1].data()));
    unsigned int new_size = old_size + samples_per;
    unsigned int bw = static_cast<unsigned int>(
        std::atol(split_fname[split_fname.size() - 3].data()));

    write_vecs(fname, e.rejectSample(bw, samples_per, rng), true);
    std::rename(fname.c_str(), makeVecFname(dirPath, bw, new_size).c_str());
  }
}

int main() {
  std::string dirPath;
  std::getline(std::cin, dirPath);

  std::string domain;
  std::getline(std::cin, domain);

  std::string tmpStr;
  std::getline(std::cin, tmpStr);
  unsigned int samples = static_cast<unsigned int>(std::stoul(tmpStr));

  std::getline(std::cin, tmpStr);
  unsigned int seed = static_cast<unsigned int>(std::stoul(tmpStr));

  std::getline(std::cin, tmpStr);
  std::vector<std::string> bFnNames = split_whitespace(tmpStr);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});
  Jit jit(fnSrcCode);

  if (domain == "KnownBits") {
    Eval<KnownBits> e(std::move(jit), {}, bFnNames);
    handleDomain(e, dirPath, samples, seed);
  } else if (domain == "ConstantRange") {
    Eval<ConstantRange> e(std::move(jit), {}, bFnNames);
    handleDomain(e, dirPath, samples, seed);
  } else if (domain == "IntegerModulo") {
    Eval<IntegerModulo<6>> e(std::move(jit), {}, bFnNames);
    handleDomain(e, dirPath, samples, seed);
  } else
    std::cerr << "Unknown domain: " << domain << "\n";

  return 0;
}
