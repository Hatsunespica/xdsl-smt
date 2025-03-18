#include <algorithm>
#include <functional>
#include <iostream>
#include <optional>
#include <string>
#include <vector>

#include "APInt.cpp"
#include "AbstVal.cpp"
#include "Results.cpp"
#include "jit.cpp"

typedef std::function<A::APInt(A::APInt, A::APInt)> ConcOpFn;
typedef std::function<bool(A::APInt, A::APInt)> OpConstraintFn;

template <typename Domain>
std::vector<Domain>
synth_function_wrapper(const Domain &lhs, const Domain &rhs,
                       const std::vector<typename Domain::XferFn> &fs) {
  std::vector<Domain> r;
  std::transform(fs.begin(), fs.end(), std::back_inserter(r),
                 [&lhs, &rhs](const typename Domain::XferFn &f) {
                   const Vec res = f(lhs.v, rhs.v);
                   return Domain(res);
                 });
  return r;
}

template <typename Domain>
std::vector<Domain>
ref_function_wrapper(const Domain &lhs, const Domain &rhs,
                     const std::vector<typename Domain::XferFn> &fs) {
  std::vector<Domain> r;
  std::transform(fs.begin(), fs.end(), std::back_inserter(r),
                 [&lhs, &rhs](const typename Domain::XferFn &f) {
                   const Vec res = f(lhs.v, rhs.v);
                   return Domain(res);
                 });
  return r;
}

template <typename Domain>
const Domain toBestAbst(const Domain &lhs, const Domain &rhs,
                        const ConcOpFn &concOp,
                        const std::optional<OpConstraintFn> &opConstraintFn) {
  std::vector<Domain> crtVals;
  const std::vector<unsigned int> rhss = rhs.toConcrete();

  for (unsigned int lhs_v : lhs.toConcrete()) {
    for (unsigned int rhs_v : rhss) {
      if (!opConstraintFn || opConstraintFn.value()(A::APInt(lhs.bw, lhs_v),
                                                    A::APInt(lhs.bw, rhs_v)))
        crtVals.push_back(Domain::fromConcrete(
            concOp(A::APInt(lhs.bw, lhs_v), A::APInt(rhs.bw, rhs_v))));
    }
  }

  return Domain::joinAll(crtVals, lhs.bw);
}

template <typename Domain>
const Results eval(const std::vector<llvm::orc::ExecutorAddr> &xferFnAddrs,
                   const std::vector<llvm::orc::ExecutorAddr> &baseFnAddrs,
                   const ConcOpFn &concOp,
                   const std::optional<OpConstraintFn> &opConstraintFn,
                   unsigned int bw) {
  Results r{static_cast<unsigned int>(xferFnAddrs.size())};
  const std::vector<Domain> fullLattice = Domain::enumVals(bw);

  std::vector<typename Domain::XferFn> xferFns(xferFnAddrs.size());
  std::transform(xferFnAddrs.begin(), xferFnAddrs.end(), xferFns.begin(),
                 [](const llvm::orc::ExecutorAddr &x) {
                   return x.toPtr<typename Domain::XferFn>();
                 });

  std::vector<typename Domain::XferFn> baseFns(baseFnAddrs.size());
  std::transform(baseFnAddrs.begin(), baseFnAddrs.end(), baseFns.begin(),
                 [](const llvm::orc::ExecutorAddr &x) {
                   return x.toPtr<typename Domain::XferFn>();
                 });

  xferFnAddrs[0].toPtr<void *(void *, void *)>();

  for (Domain lhs : fullLattice) {
    for (Domain rhs : fullLattice) {
      Domain best_abstract_res = toBestAbst(lhs, rhs, concOp, opConstraintFn);
      // we skip a (lhs, rhs) if there are no concrete values that satisfy
      // op_constraint
      if (best_abstract_res.isBottom())
        continue;

      std::vector<Domain> synth_kbs(
          synth_function_wrapper<Domain>(lhs, rhs, xferFns));
      std::vector<Domain> ref_kbs(ref_function_wrapper(lhs, rhs, baseFns));
      Domain cur_kb = Domain::meetAll(ref_kbs, bw);
      bool solved = cur_kb == best_abstract_res;
      for (unsigned int i = 0; i < synth_kbs.size(); ++i) {
        Domain synth_after_meet = cur_kb.meet(synth_kbs[i]);
        bool sound = synth_after_meet.isSuperset(best_abstract_res);
        bool exact = synth_after_meet == best_abstract_res;
        unsigned int dis = synth_after_meet.distance(best_abstract_res);

        r.incResult(Result(sound, dis, exact, solved), i);
      }

      r.incCases(solved, cur_kb.distance(best_abstract_res));
    }
  }

  return r;
}

std::vector<std::string> split_whitespace(const std::string &input) {
  std::vector<std::string> result;
  std::istringstream iss(input);
  std::string word;
  while (iss >> word) {
    result.push_back(word);
  }
  return result;
}

int main() {
  // TODO APInt namespacing is weird rn
  // TODO split stuff into seperate .h and .cpp

  std::string tmpStr;
  std::string domain;
  std::getline(std::cin, domain);

  std::getline(std::cin, tmpStr);
  unsigned int bw = static_cast<unsigned int>(std::stoul(tmpStr));
  std::getline(std::cin, tmpStr);
  std::vector<std::string> synthFnNames = split_whitespace(tmpStr);
  std::getline(std::cin, tmpStr);
  std::vector<std::string> baseFnNames = split_whitespace(tmpStr);
  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  std::unique_ptr<llvm::orc::LLJIT> jit = getJit(fnSrcCode);

  std::vector<llvm::orc::ExecutorAddr> xferFns(synthFnNames.size());
  std::transform(
      synthFnNames.begin(), synthFnNames.end(), xferFns.begin(),
      [&jit](const std::string &x) { return llvm::cantFail(jit->lookup(x)); });

  std::vector<llvm::orc::ExecutorAddr> baseFns(baseFnNames.size());
  std::transform(
      baseFnNames.begin(), baseFnNames.end(), baseFns.begin(),
      [&jit](const std::string &x) { return llvm::cantFail(jit->lookup(x)); });

  ConcOpFn concOpAddr = llvm::cantFail(jit->lookup("concrete_op"))
                            .toPtr<A::APInt(A::APInt, A::APInt)>();

  llvm::Expected<llvm::orc::ExecutorAddr> mOpCons =
      jit->lookup("op_constraint");

  std::optional<OpConstraintFn> opConstraint =
      mOpCons.takeError()
          ? std::nullopt
          : std::optional(mOpCons.get().toPtr<bool(A::APInt, A::APInt)>());

  if (domain == "KnownBits")
    eval<KnownBits>(xferFns, baseFns, concOpAddr, opConstraint, bw).print();
  else if (domain == "ConstantRange")
    eval<ConstantRange>(xferFns, baseFns, concOpAddr, opConstraint, bw).print();
  else
    std::cerr << "Unknown domain: " << domain << "\n";

  return 0;
}
