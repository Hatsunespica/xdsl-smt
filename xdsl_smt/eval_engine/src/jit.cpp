#include <iostream>
#include <memory>
#include <string>

#include <clang/Basic/Diagnostic.h>
#include <clang/Basic/FileManager.h>
#include <clang/Basic/SourceManager.h>
#include <clang/CodeGen/CodeGenAction.h>
#include <clang/Driver/Options.h>
#include <clang/Frontend/ASTUnit.h>
#include <clang/Frontend/CompilerInstance.h>
#include <clang/Frontend/CompilerInvocation.h>
#include <clang/Frontend/TextDiagnosticPrinter.h>

#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/raw_ostream.h>

std::unique_ptr<llvm::Module>
generateLLVMIRFromCode(const std::string &sourceCode) {
  llvm::LLVMContext llvmContext;
  clang::CompilerInstance clangInstance;

  clangInstance.createDiagnostics();
  clang::DiagnosticsEngine &diagEngine = clangInstance.getDiagnostics();
  clang::DiagnosticOptions diagnosticOptions;
  clang::TextDiagnosticPrinter *diagnosticPrinter =
      new clang::TextDiagnosticPrinter(llvm::errs(), &diagnosticOptions);
  diagEngine.setClient(diagnosticPrinter, false);

  clangInstance.createFileManager();
  clangInstance.createSourceManager(clangInstance.getFileManager());

  llvm::MemoryBufferRef sourceBuffer(llvm::StringRef(sourceCode), "<memory>");
  clangInstance.getSourceManager().setMainFileID(
      clangInstance.getSourceManager().createFileID(sourceBuffer,
                                                    clang::SrcMgr::C_User));

  std::shared_ptr<clang::CompilerInvocation> invocation =
      std::make_shared<clang::CompilerInvocation>();
  if (!clang::CompilerInvocation::CreateFromArgs(
          *invocation, {"-v", "-emit-llvm", "-O2", "-x", "c++"}, diagEngine)) {
    llvm::errs() << "Failed to create a compiler invocation.\n";
    return nullptr;
  }

  clangInstance.setInvocation(invocation);
  std::unique_ptr<clang::CodeGenAction> codeGenAction(
      new clang::EmitLLVMAction());

  std::cerr << "here\n";

  if (!clangInstance.ExecuteAction(*codeGenAction)) {
    llvm::errs() << "Failed to generate LLVM IR.\n";
    return nullptr;
  }

  std::cerr << "not here\n";

  return codeGenAction->takeModule();
}

int main() {
  std::string sourceCode = R"cpp(
    int f() {
        return 42;
    }
    )cpp";

  std::unique_ptr<llvm::Module> llvmIRModule =
      generateLLVMIRFromCode(sourceCode);

  if (llvmIRModule) {
    llvm::outs() << "LLVM IR (internal representation):\n";
    llvmIRModule->print(llvm::outs(), nullptr);
  } else {
    llvm::errs() << "Error: Failed to generate LLVM IR.\n";
  }

  return 0;
}
