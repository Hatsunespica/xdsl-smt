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
#include <set>
#include <stdexcept>
#include <string>
#include <sys/mman.h>
#include <unistd.h>
#include <unordered_set>
#include <vector>

#include "AbstVal.h"

template <typename D>
using LLVMXferFn = std::function<const D(const D &, const D &)>;

template <AbstractDomain D, typename LLVM_D>
using XferWrap = const std::function<std::optional<D>(
    const D &, const D &, const LLVMXferFn<LLVM_D> &)>;

template <typename D>
using XferFn = std::function<const D(const D &, const D &)>;

// Hash function for std::vector<D>
template <AbstractDomain D> struct VectorHash {
  std::size_t operator()(const std::vector<D> &vec) const {
    std::size_t seed = vec.size();
    for (const auto &elem : vec) {
      seed ^= std::hash<D>{}(elem) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    }
    return seed;
  }
};

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

const std::vector<std::vector<std::string>>
parseStrTupleList(std::istream &in) {
  std::vector<std::vector<std::string>> result;
  std::string line;
  std::getline(in, line);

  // Regex to match tuples like ('string1', 'string2', 'string3')
  std::regex tuple_regex(R"(\(([^)]*)\))");
  std::smatch tuple_match;

  std::string::const_iterator searchStart(line.cbegin());
  while (
      std::regex_search(searchStart, line.cend(), tuple_match, tuple_regex)) {
    std::string tuple_content = tuple_match[1].str();
    std::vector<std::string> tuple_strings;

    // Extract individual strings from the tuple content
    std::regex string_regex(R"('([^']*)')");
    std::smatch string_match;

    std::string::const_iterator tupleStart(tuple_content.cbegin());
    while (std::regex_search(tupleStart, tuple_content.cend(), string_match,
                             string_regex)) {
      tuple_strings.push_back(string_match[1].str());
      tupleStart = string_match.suffix().first;
    }

    if (!tuple_strings.empty()) {
      result.push_back(tuple_strings);
    }

    searchStart = tuple_match.suffix().first;
  }

  return result;
}

template <AbstractDomain D>
unsigned int
getBw(const std::unordered_set<std::vector<D>, VectorHash<D>> &validSet) {
  return validSet.begin()->at(0).bw();
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

const std::vector<std::tuple<unsigned int, unsigned int, unsigned int>>
parseTriples(std::istream &in) {
  std::vector<std::tuple<unsigned int, unsigned int, unsigned int>> result;
  std::string line;
  std::getline(in, line);

  std::regex triple_regex(R"(\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\))");
  std::smatch match;

  std::string::const_iterator searchStart(line.cbegin());
  while (std::regex_search(searchStart, line.cend(), match, triple_regex)) {
    unsigned int first = static_cast<unsigned int>(std::stoul(match[1].str()));
    unsigned int second = static_cast<unsigned int>(std::stoul(match[2].str()));
    unsigned int third = static_cast<unsigned int>(std::stoul(match[3].str()));
    result.emplace_back(first, second, third);
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
void write_vecs(const std::string &fname, const std::vector<std::vector<D>> &x,
                bool append) {
  // Calculate total size dynamically based on actual vector sizes
  size_t data_size = 0;
  for (const auto &vec : x) {
    data_size += vec.size() * D::N * (sizeof(unsigned) + sizeof(unsigned long));
  }

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
  for (const auto &vec : x) {
    for (const auto &element : vec) {
      element.serialize(ptr, offset);
    }
  }

  munmap(ptr, data_size);
  close(fd);
}

template <AbstractDomain D>
std::vector<std::vector<D>> read_vecs(const std::string &fname,
                                      unsigned int num_elements,
                                      unsigned int elements_per_vector) {
  const size_t total_size = num_elements * elements_per_vector * D::N *
                            (sizeof(unsigned) + sizeof(unsigned long));

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

  std::vector<std::vector<D>> vecs;
  vecs.reserve(num_elements);

  unsigned int offset = 0;
  for (unsigned int i = 0; i < num_elements; ++i) {
    std::vector<D> vec;
    vec.reserve(elements_per_vector);
    for (unsigned int j = 0; j < elements_per_vector; ++j) {
      vec.push_back(D::deserialize(ptr, offset));
    }
    vecs.push_back(std::move(vec));
  }

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
using ValidSet = std::unordered_set<std::vector<D>, VectorHash<D>>;

template <AbstractDomain D> using ValidSets = std::vector<ValidSet<D>>;

template <AbstractDomain D>
const std::tuple<ValidSets<D>, ValidSets<D>, ValidSets<D>>
getValidSet(const std::string dirName, unsigned int elements_per_vector) {
  ValidSets<D> lowVecs;
  ValidSets<D> medVecs;
  ValidSets<D> highVecs;

  for (const std::filesystem::directory_entry &entry :
       std::filesystem::directory_iterator(dirName)) {
    SampleTypes sample = parseSamples(entry);
    auto readResult =
        read_vecs<D>(entry.path(), sample.numSamples, elements_per_vector);
    std::unordered_set<std::vector<D>, VectorHash<D>> resultSet(
        readResult.begin(), readResult.end());

    if (sample.enumType == EnumType::High) {
      highVecs.push_back(std::move(resultSet));
    } else if (sample.enumType == EnumType::Med) {
      medVecs.push_back(std::move(resultSet));
    } else {
      lowVecs.push_back(std::move(resultSet));
    }
  }

  return {lowVecs, medVecs, highVecs};
}

#endif
