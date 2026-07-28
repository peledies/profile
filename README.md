# Quick Setup Guide

The recommended way to initialize your local environment is by running the full provisioning target in the Makefile. This ensures all steps are run in the correct, safe order and handles failure detection.

\`\`\`bash
make provision
\`\`\`

---

### Manual Setup (Alternate Method)

If you prefer running setup scripts directly:

#### Core Profile Initialization
Run this command for core project setup variables: 
```bash
curl -sL https://raw.githubusercontent.com/peledies/profile/master/profile_init.sh | bash
```

#### Homebrew Dependencies
Run this command if you only need dependency installation via Homebrew:
```bash
curl -sL https://raw.githubusercontent.com/peledies/profile/master/homebrew.sh | bash
```