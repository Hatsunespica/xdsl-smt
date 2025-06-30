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
    unsolvedSound = !solved ? s : 0;
    unsolvedPrecise = !solved ? p : 0;
    unsolvedExact = !solved ? e : 0;
  }

  Result &operator+=(const Result &rhs) {
    sound += rhs.sound;
    precise += rhs.precise;
    exact += rhs.exact;
    unsolvedSound += rhs.unsolvedSound;
    unsolvedPrecise += rhs.unsolvedPrecise;
    unsolvedExact += rhs.unsolvedExact;
    soundDistance += rhs.soundDistance;

    return *this;
  }

  friend class Results;

private:
  unsigned long sound;
  unsigned long precise;
  unsigned long exact;
  unsigned long unsolvedSound;
  unsigned long unsolvedPrecise;
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
    a.printMember(os, "unsolved_sound",
                  [](const Result &x) { return x.unsolvedSound; });
    a.printMember(os, "unsolved_precise",
                  [](const Result &x) { return x.unsolvedPrecise; });
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

class HighBwRes {
  unsigned int bw;

public:
  unsigned int numSamples;
  unsigned long sumOfRef;
  std::vector<unsigned long> synthScoreSum;
  std::vector<unsigned long> meetScoreSum;
  std::vector<unsigned long> numBottoms;

  HighBwRes(unsigned long numFns, unsigned int bw_)
      : bw(bw_), numSamples(0), sumOfRef(0) {
    synthScoreSum = std::vector<unsigned long>(numFns);
    meetScoreSum = std::vector<unsigned long>(numFns);
    numBottoms = std::vector<unsigned long>(numFns);
  }

  HighBwRes &operator+=(const HighBwRes &rhs) {
    numSamples += rhs.numSamples;
    sumOfRef += rhs.sumOfRef;
    for (unsigned int i = 0; i < synthScoreSum.size(); ++i) {
      synthScoreSum[i] += rhs.synthScoreSum[i];
      meetScoreSum[i] += rhs.meetScoreSum[i];
      numBottoms[i] += rhs.numBottoms[i];
    }

    return *this;
  }

  friend std::ostream &operator<<(std::ostream &os, const HighBwRes &x) {
    os << "bw: " << x.bw << "\n";
    os << "ref score: " << x.sumOfRef << "\n";
    os << "num samples: " << x.numSamples << "\n";
    os << "synth score sums:\n[";
    for (auto it = x.synthScoreSum.begin(); it != x.synthScoreSum.end(); ++it) {
      os << *it;
      if (std::next(it) != x.synthScoreSum.end())
        os << ", ";
      else
        os << "]\n";
    }

    os << "meet score sums:\n[";
    for (auto it = x.meetScoreSum.begin(); it != x.meetScoreSum.end(); ++it) {
      os << *it;
      if (std::next(it) != x.meetScoreSum.end())
        os << ", ";
      else
        os << "]\n";
    }

    os << "number of synth bottoms:\n[";
    for (auto it = x.numBottoms.begin(); it != x.numBottoms.end(); ++it) {
      os << *it;
      if (std::next(it) != x.numBottoms.end())
        os << ", ";
      else
        os << "]\n";
    }
    os << "---\n";

    return os;
  }
};

#endif
