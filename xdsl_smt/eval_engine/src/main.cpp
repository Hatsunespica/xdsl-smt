#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <functional>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "APInt.cpp"
#include "AbstVal.cpp"
#include "Results.cpp"
#include "jit.cpp"

typedef std::function<Ret(A::APInt *, A::APInt *)> XferAddr;
typedef std::function<A::APInt(A::APInt, A::APInt)> ConcOpAddr;
typedef KnownBits<4> Domain;

std::vector<Domain> synth_function_wrapper(const Domain &lhs, const Domain &rhs,
                                           const std::vector<XferAddr> &fs) {
  std::vector<Domain> r;
  A::APInt lhs_a[2] = {lhs.v[0], lhs.v[1]};
  A::APInt rhs_a[2] = {rhs.v[0], rhs.v[1]};
  std::transform(fs.begin(), fs.end(), std::back_inserter(r),
                 [&lhs_a, &rhs_a](const XferAddr &f) {
                   const Ret res = f(lhs_a, rhs_a);
                   return Domain({res.a, res.b});
                 });
  return r;
}

std::vector<Domain> ref_function_wrapper(const Domain &lhs, const Domain &rhs,
                                         const std::vector<XferAddr> &fs) {
  std::vector<Domain> r;
  A::APInt lhs_a[2] = {lhs.v[0], lhs.v[1]};
  A::APInt rhs_a[2] = {rhs.v[0], rhs.v[1]};
  std::transform(fs.begin(), fs.end(), std::back_inserter(r),
                 [&lhs_a, &rhs_a](const XferAddr &f) {
                   const Ret res = f(lhs_a, rhs_a);
                   return Domain({res.a, res.b});
                 });
  return r;
}

template <typename Domain>
const Domain toBestAbst(const Domain &lhs, const Domain &rhs,
                        const ConcOpAddr &concOp) {
  const unsigned char bitwidth = lhs.getBitWidth();
  std::vector<Domain> crtVals;
  const std::vector<unsigned int> rhss = rhs.toConcrete();

  for (unsigned int lhs_v : lhs.toConcrete()) {
    for (unsigned int rhs_v : rhss) {
      // TODO need to include op constraint too
      // if (op_constraint(lhs_op_con, rhs_op_con)) {
      if (true) {
        crtVals.push_back(Domain::fromConcrete(
            concOp(A::APInt(bitwidth, lhs_v), A::APInt(bitwidth, rhs_v))));
      }
    }
  }

  return Domain::joinAll(crtVals);
}

template <typename Domain>
const Results eval(const std::vector<XferAddr> &xferFns,
                   const std::vector<XferAddr> &baseFns,
                   const ConcOpAddr &concOp) {
  Results r{static_cast<unsigned int>(xferFns.size())};
  const std::vector<Domain> fullLattice = Domain::enumVals();

  for (Domain lhs : fullLattice) {
    for (Domain rhs : fullLattice) {
      Domain best_abstract_res = toBestAbst(lhs, rhs, concOp);
      // we skip a (lhs, rhs) if there are no concrete values that satisfy
      // op_constraint
      if (best_abstract_res.isBottom())
        continue;
      std::vector<Domain> synth_kbs(synth_function_wrapper(lhs, rhs, xferFns));
      std::vector<Domain> ref_kbs(ref_function_wrapper(lhs, rhs, baseFns));
      Domain cur_kb = Domain::meetAll(ref_kbs);
      bool solved = cur_kb == best_abstract_res;
      for (unsigned int i = 0; i < synth_kbs.size(); ++i) {
        Domain synth_after_meet = cur_kb.meet(synth_kbs[i]);
        bool sound = synth_after_meet.isSuperset(best_abstract_res);
        bool exact = synth_after_meet == best_abstract_res;
        unsigned int dis = synth_after_meet.distance(best_abstract_res);

        r.incResult(Result(sound, dis, exact, solved), i);
      }

      r.incCases(solved);
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
  // TODO include op_constraints
  // TODO add domain and bitwidth as options
  // TODO APInt namespacing is weird rn
  // TODO split stuff into seperate .h and .cpp
  // TODO eval_engine.py
  // TODO print_cpp function in python
  // TODO make sure I'm producing a -O3 build
  // TODO clean up how I'm including APInt.cpp and the Ret struct in the JIT
  std::string synthFnNameLine;
  std::getline(std::cin, synthFnNameLine);
  std::vector<std::string> synthFnNames = split_whitespace(synthFnNameLine);

  std::string baseFnNameLine;
  std::getline(std::cin, baseFnNameLine);
  std::vector<std::string> baseFnNames = split_whitespace(baseFnNameLine);

  std::string fnSrcCode(std::istreambuf_iterator<char>(std::cin), {});

  std::unique_ptr<llvm::orc::LLJIT> jit = getJit(fnSrcCode);

  std::vector<XferAddr> xferFns(synthFnNames.size());
  std::transform(synthFnNames.begin(), synthFnNames.end(), xferFns.begin(),
                 [&jit](const std::string &x) {
                   return llvm::cantFail(jit->lookup(x))
                       .toPtr<Ret(A::APInt *, A::APInt *)>();
                 });

  std::vector<XferAddr> baseFns(baseFnNames.size());
  std::transform(baseFnNames.begin(), baseFnNames.end(), baseFns.begin(),
                 [&jit](const std::string &x) {
                   return llvm::cantFail(jit->lookup(x))
                       .toPtr<Ret(A::APInt *, A::APInt *)>();
                 });

  ConcOpAddr concOpAddr = llvm::cantFail(jit->lookup("concrete_op"))
                              .toPtr<A::APInt(A::APInt, A::APInt)>();

  eval<Domain>(xferFns, baseFns, concOpAddr).print();

  return 0;
}
