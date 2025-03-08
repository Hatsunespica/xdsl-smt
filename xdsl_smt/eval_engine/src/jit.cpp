#include <clang/Basic/Diagnostic.h>
#include <clang/CodeGen/CodeGenAction.h>
#include <clang/Frontend/CompilerInstance.h>
#include <clang/Frontend/TextDiagnosticPrinter.h>
#include <clang/Lex/PreprocessorOptions.h>

#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/TargetSelect.h>

// largely adopted from
// https://blog.memzero.de/llvm-orc-jit/
class Compiler {
private:
  std::unique_ptr<clang::TextDiagnosticPrinter> dp;
  std::unique_ptr<clang::DiagnosticsEngine> de;

  struct CompileResult {
    std::unique_ptr<llvm::LLVMContext> c;
    std::unique_ptr<llvm::Module> m;
  };

public:
  Compiler() {
    llvm::IntrusiveRefCntPtr<clang::DiagnosticOptions> opts;
    dp = std::make_unique<clang::TextDiagnosticPrinter>(llvm::errs(),
                                                        opts.get());
    de = std::make_unique<clang::DiagnosticsEngine>(nullptr, std::move(opts),
                                                    dp.get(), false);
  }

  CompileResult compile(const std::string &code) {
    clang::CompilerInstance clang;
    clang::CompilerInvocation::CreateFromArgs(clang.getInvocation(),
                                              {"<memory>"}, *de);

    clang.createDiagnostics(dp.get(), false);
    clang.getPreprocessorOpts().addRemappedFile(
        "<memory>", llvm::MemoryBuffer::getMemBuffer(code).release());

    clang.getCodeGenOpts().setInlining(
        clang::CodeGenOptions::OnlyAlwaysInlining);

    clang::EmitLLVMOnlyAction action;
    clang.ExecuteAction(action);

    return CompileResult{
        std::unique_ptr<llvm::LLVMContext>(action.takeLLVMContext()),
        action.takeModule()};
  }
};

int main() {
  llvm::InitializeNativeTarget();
  llvm::InitializeNativeTargetAsmParser();
  llvm::InitializeNativeTargetAsmPrinter();

  std::string sourceCode = R"cpp(
    int f() {
        return 42;
    }
    )cpp";

  auto [context, module] = Compiler().compile(sourceCode);
  llvm::orc::ThreadSafeModule mod =
      llvm::orc::ThreadSafeModule(std::move(module), std::move(context));

  auto jit = llvm::cantFail(llvm::orc::LLJITBuilder().create());
  llvm::cantFail(jit->addIRModule(std::move(mod)));

  auto Add1Addr = llvm::cantFail(jit->lookup("f"));
  int (*Add1)() = Add1Addr.toPtr<int()>();

  int Result = Add1();

  llvm::outs() << "result: " << Result << "\n";

  return 0;
}
