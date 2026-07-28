# Makefile Provisioning Design Specification
**Date:** 2026-07-25
**Author:** Claude Code (Claude 3.5 Sonnet)
**Status:** Proposed for Review

## Goal
To centralize all necessary environment setup steps into a single, deterministic Makefile target (`make provision`). This ensures that any developer can initialize the entire local working environment with one command, and critically, the process must halt immediately if *any* required external script fails.

## Rationale
Currently, setup requires users to execute two distinct, non-related scripts:
1.  `profile_init.sh`: For core project setup.
2.  `homebrew.sh`: For optional dependency installation via Homebrew.

By formalizing these steps in a Makefile, we gain:
*   **Consistency:** Guarantees every user follows the exact same sequence of commands.
*   **Atomicity/Safety:** The nature of makefile dependencies allows us to enforce that failure at any step immediately halts all subsequent setup attempts.
*   **Discoverability:** A single `make provision` command serves as clear documentation for local setup.

## Implementation Details (Makefile Structure)

The root `Makefile` will contain the following structure:

### 1. Master Target: `provision`
This target orchestrates the entire process by requiring both the profile and brew steps to succeed sequentially.

```makefile
provision: profile brew
```

### 2. Prerequisites
These targets define the actual shell execution logic.

**Profile Setup (`profile`):**
*   Executes: `curl -sL https://raw.githubusercontent.com/peledies/profile/master/profile_init.sh | bash`
*   Purpose: Initializes core project environment variables and tools.

**Homebrew Setup (`brew`):**
*   Executes: `curl -sL https://raw.githubusercontent.com/peledies/profile/master/homebrew.sh | bash`
*   Purpose: Ensures required build dependencies are present via Homebrew.

### 3. Failure Handling (Critical Feature)
The default behavior of GNU Make when a command returns a non-zero exit code is to stop execution and report an error. This satisfies the requirement that the entire provisioning process must fail fast if any single component fails.

### 4. Optional Cleanup
A `clean` target is recommended for future expansion, allowing developers to remove temporary files or artifacts generated during setup without affecting source code.

## Review Checklist (For Implementation)
*   [ ] Create the `Makefile` in the root directory.
*   [ ] Populate the file with the structure above.
*   [ ] Test the target using `make provision`.
