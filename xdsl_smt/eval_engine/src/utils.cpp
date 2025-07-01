#ifndef Utils_H
#define Utils_H

#include <algorithm>
#include <fcntl.h>
#include <filesystem>
#include <functional>
#include <iostream>
#include <istream>
#include <optional>
#include <regex>
#include <stdexcept>
#include <string>
#include <sys/mman.h>
#include <unistd.h>
#include <vector>

#include "AbstVal.h"

template <typename D>
using LLVMXferFn = std::function<const D(const D &, const D &)>;

template <AbstractDomain D, typename LLVM_D>
using XferWrap = const std::function<const D(const D &, const D &,
                                             const LLVMXferFn<LLVM_D> &)>;

template <typename D>
using XferFn = std::function<const D(const D &, const D &)>;

template <typename D>
const std::optional<XferFn<D>>
makeTest(const std::vector<std::tuple<std::string, std::optional<XferFn<D>>>>
             &llvmTests,
         const std::string &opName) {

  const auto &[_, llvmOp] = *std::ranges::find_if(
      llvmTests.begin(), llvmTests.end(),
      [&](const auto &x) { return std::get<0>(x) == opName; });

  return llvmOp;
}

const std::vector<std::string> parseStrList(std::istream &in) {
  std::vector<std::string> result;
  std::string line;
  std::getline(in, line);

  std::regex string_regex(R"('([^']*)')");
  std::smatch match;

  std::string::const_iterator searchStart(line.cbegin());
  while (std::regex_search(searchStart, line.cend(), match, string_regex)) {
    result.push_back(match[1].str());
    searchStart = match.suffix().first;
  }

  return result;
}

template <AbstractDomain D>
unsigned int getBw(const std::vector<std::tuple<D, D, D>> &toEval) {
  return std::get<0>(toEval[0]).bw();
}

const std::vector<unsigned int> parseIntList(std::istream &in) {
  std::vector<unsigned int> result;
  std::string line;
  std::getline(in, line);

  std::regex number_regex(R"(\d+)");
  std::smatch match;

  std::string::const_iterator searchStart(line.cbegin());
  while (std::regex_search(searchStart, line.cend(), match, number_regex)) {
    unsigned int number = static_cast<unsigned int>(std::stoul(match[0].str()));
    result.push_back(number);
    searchStart = match.suffix().first;
  }

  return result;
}

const std::vector<std::pair<unsigned int, unsigned int>>
parsePairs(std::istream &in) {
  std::vector<std::pair<unsigned int, unsigned int>> result;
  std::string line;
  std::getline(in, line);

  std::regex pair_regex(R"(\(\s*(\d+)\s*,\s*(\d+)\s*\))");
  std::smatch match;

  std::string::const_iterator searchStart(line.cbegin());
  while (std::regex_search(searchStart, line.cend(), match, pair_regex)) {
    unsigned int first = static_cast<unsigned int>(std::stoul(match[1].str()));
    unsigned int second = static_cast<unsigned int>(std::stoul(match[2].str()));
    result.emplace_back(first, second);
    searchStart = match.suffix().first;
  }

  return result;
}

const std::string makeVecFname(const std::string &dirPath,
                               const std::string &type, unsigned int bw,
                               unsigned long samples) {
  return dirPath + type + "_bw_" + std::to_string(bw) + "_samples_" +
         std::to_string(samples) + ".bin";
}

template <AbstractDomain D>
void write_vecs(const std::string &fname,
                const std::vector<std::tuple<D, D, D>> &x, bool append) {
  const size_t data_size =
      x.size() * D::N * (sizeof(unsigned) + sizeof(unsigned long)) * 3;

  int fd = open(fname.c_str(), O_RDWR | O_CREAT, 0666);
  if (fd == -1) {
    std::cerr << "open\n";
    exit(1);
  }

  off_t offset_position = 0;

  if (append) {
    offset_position = lseek(fd, 0, SEEK_END);
    if (offset_position == -1) {
      std::cerr << "lseek\n";
      close(fd);
      exit(1);
    }
  }

  if (ftruncate(fd, offset_position + static_cast<off_t>(data_size)) == -1) {
    std::cerr << "ftruncate\n";
    close(fd);
    exit(1);
  }

  // Align offset to page boundary
  long page_size = sysconf(_SC_PAGE_SIZE);
  off_t aligned_offset = offset_position & ~(page_size - 1);
  off_t delta = offset_position - aligned_offset;
  size_t map_size = data_size + static_cast<size_t>(delta);

  unsigned char *map_base = static_cast<unsigned char *>(
      mmap(nullptr, map_size, PROT_WRITE, MAP_SHARED, fd, aligned_offset));
  if (map_base == MAP_FAILED) {
    std::cerr << "mmap\n";
    close(fd);
    exit(1);
  }

  unsigned char *ptr = map_base + delta;
  unsigned int offset = 0;
  for (auto &[x0, x1, x2] : x) {
    x0.serialize(ptr, offset);
    x1.serialize(ptr, offset);
    x2.serialize(ptr, offset);
  }

  munmap(ptr, data_size);
  close(fd);
}

template <AbstractDomain D>
std::vector<std::tuple<D, D, D>> read_vecs(const std::string &fname,
                                           unsigned int num_elemnts) {
  const size_t total_size =
      num_elemnts * D::N * (sizeof(unsigned) + sizeof(unsigned long)) * 3;

  int fd = open(fname.c_str(), O_RDONLY);
  if (fd == -1) {
    std::cerr << "open\n";
    exit(1);
  }

  unsigned char *ptr = static_cast<unsigned char *>(
      mmap(nullptr, total_size, PROT_READ, MAP_SHARED, fd, 0));
  if (ptr == MAP_FAILED) {
    std::cerr << "mmap\n";
    close(fd);
    exit(1);
  }

  std::vector<std::tuple<D, D, D>> vecs;
  vecs.reserve(num_elemnts);

  unsigned int offset = 0;
  for (unsigned int x = 0; x < num_elemnts; ++x)
    vecs.push_back({D::deserialize(ptr, offset), D::deserialize(ptr, offset),
                    D::deserialize(ptr, offset)});

  munmap(ptr, total_size);
  close(fd);

  return vecs;
}

enum class EnumType { Low, Med, High };

struct SampleTypes {
  EnumType enumType;
  unsigned int bw;
  unsigned int numSamples;
};

SampleTypes parseSamples(const std::filesystem::directory_entry &entry) {
  std::string filename = entry.path().filename().string();

  std::regex pattern(R"((low|med|high)_bw_(\d+)_samples_(\d+)\.bin)");
  std::smatch match;

  if (!std::regex_match(filename, match, pattern)) {
    throw std::invalid_argument("Filename format is invalid: " + filename);
  }

  EnumType enumType;
  std::string enumTypeStr = match[1].str();
  if (enumTypeStr == "low") {
    enumType = EnumType::Low;
  } else if (enumTypeStr == "med") {
    enumType = EnumType::Med;
  } else if (enumTypeStr == "high") {
    enumType = EnumType::High;
  } else {
    throw std::invalid_argument("Unknown enumeration type: " + enumTypeStr);
  }

  unsigned int bw = static_cast<unsigned int>(std::stoul(match[2].str()));
  unsigned int numSamples =
      static_cast<unsigned int>(std::stoul(match[3].str()));

  return SampleTypes{enumType, bw, numSamples};
}

template <AbstractDomain D>
using ToEval = std::vector<std::vector<std::tuple<D, D, D>>>;

template <AbstractDomain D>
const std::tuple<ToEval<D>, ToEval<D>, ToEval<D>>
getToEval(const std::string dirName) {
  ToEval<D> lowVecs;
  ToEval<D> medVecs;
  ToEval<D> highVecs;

  for (const std::filesystem::directory_entry &entry :
       std::filesystem::directory_iterator(dirName)) {
    SampleTypes sample = parseSamples(entry);
    if (sample.enumType == EnumType::High) {
      highVecs.push_back(read_vecs<D>(entry.path(), sample.numSamples));
    } else if (sample.enumType == EnumType::Med) {
      medVecs.push_back(read_vecs<D>(entry.path(), sample.numSamples));
    } else {
      lowVecs.push_back(read_vecs<D>(entry.path(), sample.numSamples));
    }
  }

  return {lowVecs, medVecs, highVecs};
}

#endif
