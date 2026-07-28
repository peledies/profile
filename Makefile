
# Core project build and setup Makefile

.PHONY: provision profile brew clean test install

# ==================================================
# PROVISIONING TARGETS
# Automatically sets up the entire local environment.
# Runs core profile setup, then runs homebrew dependencies.
# The process stops immediately if any step fails.
# ==================================================

provision: profile brew

profile:
	@echo "--- Step 1/2: Initializing Core Project Profile ---"
	@curl -sL https://raw.githubusercontent.com/peledies/profile/master/profile_init.sh | bash

brew:
	@echo "--- Step 2/2: Installing Homebrew Dependencies via Profile Scheme ---"
	@curl -sL https://raw.githubusercontent.com/peledies/profile/master/homebrew.sh | bash


# ==================================================
# UTILITY & MAINTENANCE TARGETS
# ==================================================

clean:
	@echo "--- Cleaning up temporary setup artifacts ---"
	# TODO: Implement actual cleanup steps here (e.g., rm -rf .cache/temp)
	@echo "Cleanup complete. Remember to review and fill in specific commands."


# Optional remaining default targets (can be customized)
test:
	@echo "Running tests..."
	# Add your test command here, e.g., npm run test or pytest

install:
	@echo "Installing local dependencies/assets..."
	# Example: npm install --prefix ./dist
