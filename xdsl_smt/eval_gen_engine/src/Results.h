#ifndef Results_H
#define Results_H

#include <functional>
#include <iomanip>
#include <iostream>
#include <optional>
#include <string_view>
#include <vector>

class Result {
public:
  Result() = default;

  Result(unsigned long v, unsigned long iv) : valid(v), invalid(iv) {}

  Result &operator+=(const Result &rhs) {
    valid += rhs.valid;
    invalid += rhs.invalid;
    return *this;
  }

  friend class Results;

private:
  unsigned long valid;
  unsigned long invalid;
};

class Results {
private:
  unsigned int bw = {};
  std::vector<Result> r;
  unsigned int cases = {};

public:
  Results(unsigned int numFns, unsigned int bw_) : bw(bw_) {
    r = std::vector<Result>(numFns);
  }

  void printMember(
      std::ostream &os, std::string_view name,
      const std::function<unsigned int(const Result &x)> &getter) const {
    os << std::left << std::setw(20) << name;
    os << "[";
    for (auto it = r.begin(); it != r.end(); ++it) {
      os << std::right << std::setw(8) << getter(*it);
      if (std::next(it) != r.end())
        os << ", ";
    }
    os << "]\n";
  }

  void print(std::ostream &os) const {
    os << std::left << std::setw(20) << "bw:" << bw << "\n";
    os << std::left << std::setw(20) << "num cases:" << cases << "\n";
    printMember(os, "num valid:", [](const Result &x) { return x.valid; });
    printMember(os, "num invalid:", [](const Result &x) { return x.invalid; });
    os << "---\n";
  }

  void incResult(const Result &newR, unsigned int i) { r[i] += newR; }
  void incCases() { cases += 1; }
};

#endif
