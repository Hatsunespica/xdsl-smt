#ifndef Results_H
#define Results_H

#include <functional>
#include <iostream>
#include <string_view>
#include <vector>

class Result {
public:
  Result() = default;

  Result(bool s, unsigned long p, bool e, bool solved, unsigned long sd)
      : sound(s), precise(p), exact(e), soundDistance(sd) {
    unsolvedExact = !solved ? e : 0;
  }

  Result &operator+=(const Result &rhs) {
    sound += rhs.sound;
    precise += rhs.precise;
    exact += rhs.exact;
    unsolvedExact += rhs.unsolvedExact;
    soundDistance += rhs.soundDistance;

    return *this;
  }

  friend class Results;

private:
  unsigned long sound;
  unsigned long precise;
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
  unsigned int basePrecise = {};

public:
  Results(unsigned int numFns, unsigned int bw_) : bw(bw_) {
    r = std::vector<Result>(numFns);
  }

  void printMember(
      std::ostream &os, std::string_view name,
      const std::function<unsigned int(const Result &x)> &getter) const {
    os << name << ":\n[";
    for (auto it = r.begin(); it != r.end(); ++it) {
      os << getter(*it);
      if (std::next(it) != r.end())
        os << ", ";
      else
        os << "]\n";
    }
  }

  friend std::ostream &operator<<(std::ostream &os, const Results &a) {
    os << "bw: " << a.bw << "\n";
    a.printMember(os, "sound", [](const Result &x) { return x.sound; });
    a.printMember(os, "precise", [](const Result &x) { return x.precise; });
    a.printMember(os, "exact", [](const Result &x) { return x.exact; });
    a.printMember(os, "num_cases", [&a](const Result &x) {
      (void)x;
      return a.cases;
    });
    a.printMember(os, "unsolved_exact",
                  [](const Result &x) { return x.unsolvedExact; });
    a.printMember(os, "unsolved_num_cases", [&a](const Result &x) {
      (void)x;
      return a.unsolvedCases;
    });
    a.printMember(os, "base_precise", [&a](const Result &x) {
      (void)x;
      return a.basePrecise;
    });
    a.printMember(os, "sound_distance",
                  [](const Result &x) { return x.soundDistance; });
    os << "---\n";

    return os;
  }

  void incResult(const Result &newR, unsigned int i) { r[i] += newR; }

  void incCases(bool solved, unsigned long dis) {
    cases += 1;
    unsolvedCases += !solved ? 1 : 0;
    basePrecise += dis;
  }
};

#endif
