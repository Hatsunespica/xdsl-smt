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

  Result(bool s, unsigned long p, bool e, bool solved, unsigned long sd)
      : sound(s), distance(p), exact(e), soundDistance(sd) {
    unsolvedExact = !solved ? e : 0;
  }

  Result &operator+=(const Result &rhs) {
    sound += rhs.sound;
    distance += rhs.distance;
    exact += rhs.exact;
    unsolvedExact += rhs.unsolvedExact;
    soundDistance += rhs.soundDistance;

    return *this;
  }

  friend class Results;

private:
  unsigned long sound;
  unsigned long distance;
  unsigned long exact;
  unsigned long unsolvedExact;
  unsigned long soundDistance;
};

class Results {
private:
  unsigned int bw = {};
  std::vector<Result> r;
  unsigned int cases = {};
  unsigned int unsolvedCases = {};
  unsigned int baseDistance = {};

public:
  Results(unsigned int numFns, unsigned int bw_) : bw(bw_) {
    r = std::vector<Result>(numFns);
  }

  void printMember(std::ostream &os, std::string_view name,
                   const std::function<unsigned int(const Result &x)> &getter,
                   const std::optional<double> &maxDist) const {
    os << std::left << std::setw(20) << name;
    os << "[";
    for (auto it = r.begin(); it != r.end(); ++it) {
      os << std::right << std::setw(8);
      if (maxDist)
        os << getter(*it) / maxDist.value();
      else
        os << getter(*it);
      if (std::next(it) != r.end())
        os << ", ";
      else
        os << "]\n";
    }
  }

  void print(std::ostream &os,
             const std::function<double(unsigned int)> &maxDist) const {
    os << std::left << std::setw(20) << "bw:" << bw << "\n";
    os << std::left << std::setw(20) << "num cases:" << cases << "\n";
    os << std::left << std::setw(20) << "num unsolved:" << unsolvedCases
       << "\n";
    os << std::left << std::setw(20)
       << "base distance:" << baseDistance / maxDist(bw) << "\n";
    printMember(
        os, "num sound:", [](const Result &x) { return x.sound; },
        std::nullopt);
    printMember(
        os, "distance:", [](const Result &x) { return x.distance; },
        maxDist(bw));
    printMember(
        os, "num exact:", [](const Result &x) { return x.exact; },
        std::nullopt);
    printMember(
        os,
        "num unsolved exact:", [](const Result &x) { return x.unsolvedExact; },
        std::nullopt);
    printMember(
        os, "sound distance:", [](const Result &x) { return x.soundDistance; },
        maxDist(bw));
    os << "---\n";
  }

  void incResult(const Result &newR, unsigned int i) { r[i] += newR; }

  void incCases(bool solved, unsigned long dis) {
    cases += 1;
    unsolvedCases += !solved ? 1 : 0;
    baseDistance += dis;
  }
};

#endif
