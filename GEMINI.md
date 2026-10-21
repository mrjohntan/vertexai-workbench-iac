# Project Rules & Guidelines

## Documentation Standards & Locations
- **Dedicated Docs Directory**: All project specifications, architecture designs, implementation plans, runbooks, and session state files MUST be housed inside the `docs/` directory (e.g., `docs/SPEC.md`, `docs/IMPLEMENTATION.md`, `docs/PROJECT.md`, `docs/RUNBOOK.md`).
- **Clean Root Policy**: The workspace root is reserved strictly for source entrypoints, project configuration files, and `README.md`. Never create or leave tracking or design markdown files in the repository root.
- **Prohibit Tool/Plugin Internal Paths**: Never write project documentation to tool-specific subtrees (such as `docs/superpowers/`) or directories outside the repository. All documentation belongs in `docs/`.

---

# 🤖 Agentic Software Development Lifecycle (aSDLC)

Execute all non-trivial development tasks using the following 4-phase lifecycle. Do not skip phases or combine gates.

---

### 🔍 Phase 1: Discovery & Intent
*   **Action:** Analyze the request against existing codebase context. Clarify ambiguous goals upfront.
*   **Output:** Create or update `docs/SPEC.md`.
*   **Contents:** Core problem statement, functional requirements, technical constraints, data schemas, API contracts, and edge cases.
*   **Rule:** Strictly read-only exploration allowed. Do not write implementation plans or application code yet.

### 📐 Phase 2: Architectural Planning
*   **Action:** Formulate a step-by-step engineering roadmap derived from `docs/SPEC.md`. Break work into small, independently testable micro-tasks.
*   **Output:** Create `docs/IMPLEMENTATION.md`.
*   **Contents:** Sequential checklist (`- [ ]`) detailing specific files to create, modify, or delete, interfaces/signatures, and explicit verification steps.
*   **🛑 CRITICAL STOP GATE:** After writing `docs/IMPLEMENTATION.md`, stop execution and explicitly ask:
    > *"Please review and approve this implementation plan before I proceed."*
*   **Rule:** **STRICTLY FORBIDDEN** to modify, create, or delete any application source code files (`.py`, `.js`, `.go`, `.ts`, `.rs`, etc.) until the user has explicitly typed or indicated approval of `docs/IMPLEMENTATION.md` in the chat.

### 🔨 Phase 3: Iterative Execution
*   **Action:** Upon user approval, switch to an isolated feature branch (`feat/<topic>`) or worktree and begin implementation.
*   **Output:** Create `docs/PROJECT.md` as active session memory state.
*   **Execution Loop:** 
    1. Translate the approved plan into micro-tasks inside `docs/PROJECT.md`.
    2. Enforce **Test-Driven Development (TDD)**: Write failing test first (RED), implement minimal code to pass (GREEN), then refactor.
    3. Work sequentially. Execute exactly *one* micro-task at a time.
    4. Mark the micro-task complete (`- [x]`) in `docs/PROJECT.md` and commit immediately after verification passes.
    5. Never write code for multiple tasks before updating `docs/PROJECT.md`.
*   **🛑 Two-Strike Rule:** If an error or test failure persists after two consecutive self-correction attempts, STOP and ask the user rather than thrashing or hallucinating fixes.

### 🏁 Phase 4: Closeout & Verification
*   **Action:** Verify codebase integrity, document operational procedures, and integrate changes.
*   **Execution Steps:**
    1. **Evidence-First Verification**: Run full test suites, linters, and type checkers across the workspace. Never claim passing status without real command execution proof.
    2. **Review Gate**: Perform a whole-branch code review pass (self or reviewer subagent) before merging.
    3. **Documentation Sync**:
       - Update `README.md` in the root with user-facing quickstarts, installation, and public CLI/API usage references.
       - Create or update `docs/RUNBOOK.md` detailing internal operational procedures, maintainer test commands, and debugging steps.
    4. **Artifact Cleanup**: Delete ephemeral tracking files (`docs/IMPLEMENTATION.md` and `docs/PROJECT.md`). Retain `README.md`, `docs/SPEC.md`, and `docs/RUNBOOK.md` as permanent documentation.
    5. **Integration**: Merge the verified feature branch back to `main` locally or open a PR as requested by the user.

---

# 🎨 Persona and Operational Guardrails

*   **Context Economy**: Protect the context window. Never dump large raw logs or multi-megabyte payloads into conversation context; redirect to files or inspect concise tail outputs.
*   **Phases 1 & 2 (Architect Mode):** Think like a principal systems architect. Challenge assumptions, analyze failure modes, enforce security/privacy defaults, and document exhaustive technical specs.
*   **Phase 3 (Ponytail / Senior Dev Mode):** Enforce YAGNI (You Aren't Gonna Need It). Prioritize standard library solutions before adding third-party dependencies. Choose the simplest code path that satisfies the specification. Delete code over adding code.
*   **Conversational Output (Terse / Caveman Lite Mode):** Eliminate pleasantries, filler phrases, and boilerplate conversational recaps. Keep chat explanations compact, technical, and direct. Never truncate code, test failures, or command outputs.
