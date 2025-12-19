#!/usr/bin/env bash

# rsync_with_progress.sh
# Script to rsync files in current directory first, then iterate through folders
# showing their sizes before syncing each one

set -e  # Exit on any error

# Cleanup function for SSH master connections
cleanup_ssh_master() {
    if [ "$USE_MASTER_CONNECTION" = true ] && [ -n "$SSH_MASTER_SOCKET" ] && [ -S "$SSH_MASTER_SOCKET" ]; then
        echo -e "\n${YELLOW}Cleaning up SSH master connection...${NC}"
        ssh -o "ControlPath=$SSH_MASTER_SOCKET" -O exit "$REMOTE_HOST" 2>/dev/null || true
    fi
}

# Set up trap to cleanup on script exit
trap cleanup_ssh_master EXIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [options] <source_directory> <destination>"
    echo ""
    echo "Options:"
    echo "  --dry-run           Show what would be transferred without actually doing it"
    echo "  --ssh-key PATH      Use specific SSH key for authentication"
    echo "  --ssh-opts OPTS     Additional SSH options (e.g., '-p 2222')"
    echo "  --master-connection Use SSH master connection for password-less subsequent connections"
    echo ""
    echo "Examples:"
    echo "  $0 /source/path user@remote:/destination/path"
    echo "  $0 /source/path /local/destination/path"
    echo "  $0 --dry-run /source/path /local/destination/path"
    echo "  $0 --ssh-key ~/.ssh/id_rsa /source/path user@remote:/destination/path"
    echo "  $0 --master-connection /source/path user@remote:/destination/path"
    echo ""
    echo "SSH Authentication Tips:"
    echo "  - Set up SSH key authentication: ssh-copy-id user@remote"
    echo "  - Use SSH config file for host-specific settings"
    echo "  - Use --master-connection to reuse SSH connections"
    echo ""
    echo "This script will:"
    echo "  1. First rsync only files in the source directory (no subdirs)"
    echo "  2. Then iterate through each subdirectory, show its size, and rsync it"
    exit 1
}

# Initialize variables
DRY_RUN=false
SSH_KEY=""
SSH_OPTS=""
USE_MASTER_CONNECTION=false
SSH_MASTER_SOCKET=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --ssh-key)
            SSH_KEY="$2"
            shift 2
            ;;
        --ssh-opts)
            SSH_OPTS="$2"
            shift 2
            ;;
        --master-connection)
            USE_MASTER_CONNECTION=true
            shift
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
        *)
            break
            ;;
    esac
done

# Check remaining arguments
if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Incorrect number of arguments${NC}"
    usage
fi

SOURCE_DIR="$1"
DESTINATION="$2"

# Validate source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory '$SOURCE_DIR' does not exist${NC}"
    exit 1
fi

# Convert to absolute path
SOURCE_DIR=$(cd "$SOURCE_DIR" && pwd)

# Function to check if destination is remote
is_remote_destination() {
    [[ "$DESTINATION" == *":"* ]]
}

# Function to extract hostname from remote destination
get_remote_host() {
    echo "$DESTINATION" | cut -d':' -f1
}

# Function to sanitize directory names by replacing spaces with dashes and removing special characters
sanitize_dirname() {
    echo "$1" | sed 's/ /-/g' | sed 's/[^a-zA-Z0-9._-]//g' | sed 's/--*/-/g' | sed 's/^-\|-$//g'
}

# Set up SSH configuration for remote destinations
SSH_COMMAND=""
if is_remote_destination; then
    REMOTE_HOST=$(get_remote_host)

    # Build SSH command
    SSH_CMD_PARTS=()

    # Add SSH key if specified
    if [ -n "$SSH_KEY" ]; then
        if [ ! -f "$SSH_KEY" ]; then
            echo -e "${RED}Error: SSH key file '$SSH_KEY' not found${NC}"
            exit 1
        fi
        SSH_CMD_PARTS+=("-i" "$SSH_KEY")
    fi

    # Add custom SSH options
    if [ -n "$SSH_OPTS" ]; then
        SSH_CMD_PARTS+=($SSH_OPTS)
    fi

    # Set up master connection if requested
    if [ "$USE_MASTER_CONNECTION" = true ]; then
        SSH_MASTER_SOCKET="/tmp/ssh-master-$REMOTE_HOST-$$"
        SSH_CMD_PARTS+=("-o" "ControlMaster=auto")
        SSH_CMD_PARTS+=("-o" "ControlPath=$SSH_MASTER_SOCKET")
        SSH_CMD_PARTS+=("-o" "ControlPersist=600")

        # Test connection and establish master
        echo -e "${BLUE}Setting up SSH master connection to $REMOTE_HOST...${NC}"
        if ssh "${SSH_CMD_PARTS[@]}" "$REMOTE_HOST" "exit" 2>/dev/null; then
            echo -e "${GREEN}✓ SSH master connection established${NC}"
        else
            echo -e "${YELLOW}⚠ Could not establish master connection, will use regular SSH${NC}"
        fi
    fi

    # Build the SSH command string for rsync
    if [ ${#SSH_CMD_PARTS[@]} -gt 0 ]; then
        # Join array elements with spaces, properly quoted
        SSH_COMMAND=$(printf "'%s' " "${SSH_CMD_PARTS[@]}")
        SSH_COMMAND="ssh ${SSH_COMMAND% }"  # Remove trailing space
    fi
fi

# Set up rsync options
RSYNC_OPTS="-avh --progress --stats"

# Add SSH command to rsync if we have one
if [ -n "$SSH_COMMAND" ]; then
    RSYNC_OPTS="$RSYNC_OPTS -e \"$SSH_COMMAND\""
fi

if [ "$DRY_RUN" = true ]; then
    RSYNC_OPTS="$RSYNC_OPTS --dry-run"
fi

echo -e "${BLUE}Starting rsync process...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will actually be transferred${NC}"
fi

# Display connection info
echo -e "Source: ${YELLOW}$SOURCE_DIR${NC}"
echo -e "Destination: ${YELLOW}$DESTINATION${NC}"
if is_remote_destination; then
    if [ -n "$SSH_KEY" ]; then
        echo -e "SSH Key: ${YELLOW}$SSH_KEY${NC}"
    fi
    if [ "$USE_MASTER_CONNECTION" = true ]; then
        echo -e "SSH Master: ${YELLOW}Enabled (reusing connections)${NC}"
    fi
    if [ -n "$SSH_OPTS" ]; then
        echo -e "SSH Options: ${YELLOW}$SSH_OPTS${NC}"
    fi
fi
echo ""

# Step 1: Rsync only files in the current working directory (no subdirectories)
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}Step 1: Checking files in root directory (excluding subdirectories)...${NC}"
else
    echo -e "${GREEN}Step 1: Syncing files in root directory (excluding subdirectories)...${NC}"
fi
echo "----------------------------------------"

# Use --exclude to skip directories and system directories, only sync files
# Use rsync directly without eval to better handle spaces
if [ -n "$SSH_COMMAND" ]; then
    rsync -avh --progress --stats --exclude='*/' --exclude='@eaDir' --exclude='#recycle' \
          $([ "$DRY_RUN" = true ] && echo "--dry-run") \
          -e "$SSH_COMMAND" \
          "$SOURCE_DIR/" "$DESTINATION/"
else
    rsync -avh --progress --stats --exclude='*/' --exclude='@eaDir' --exclude='#recycle' \
          $([ "$DRY_RUN" = true ] && echo "--dry-run") \
          "$SOURCE_DIR/" "$DESTINATION/"
fi

echo ""
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}✓ Root directory files checked${NC}"
else
    echo -e "${GREEN}✓ Root directory files synced${NC}"
fi
echo ""

# Step 2: Iterate through each subdirectory
echo -e "${GREEN}Step 2: Processing subdirectories...${NC}"
echo "========================================"

cd "$SOURCE_DIR"

# Find all directories in the current path (not recursive)
# Exclude system directories like @eaDir (Synology) and #recycle (various NAS systems)
# Check if there are any directories first
total_dirs=$(find . -maxdepth 1 -type d ! -name '.' ! -name '@eaDir' ! -name '#recycle' | wc -l | tr -d ' ')

if [ "$total_dirs" -eq 0 ]; then
    echo -e "${YELLOW}No subdirectories found (excluding system directories).${NC}"
    exit 0
fi

current_dir=1

# Process directories with null delimiter to handle spaces
# Exclude @eaDir and #recycle directories
find . -maxdepth 1 -type d ! -name '.' ! -name '@eaDir' ! -name '#recycle' -print0 | sort -z | while IFS= read -r -d '' dir; do
    # Remove the ./ prefix
    clean_dir=$(echo "$dir" | sed 's|^\./||')

    echo ""
    echo -e "${BLUE}[$current_dir/$total_dirs] Processing directory: ${YELLOW}\"$clean_dir\"${NC}"
    echo "----------------------------------------"

    # Show directory size using du
    echo -n "Directory size: "
    du_output=$(du -sh "$clean_dir" 2>/dev/null || echo "0B	$clean_dir")
    size=$(echo "$du_output" | cut -f1)
    echo -e "${YELLOW}$size${NC}"

    # Count files in directory (recursive)
    file_count=$(find "$clean_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo -e "File count: ${YELLOW}$file_count${NC}"

    # Rsync this directory
    if [ "$DRY_RUN" = true ]; then
        echo "Checking what would be transferred..."
    else
        echo "Syncing..."
    fi

    # Build source and destination paths
    # Use original directory name for source, sanitized name for destination
    source_path="$SOURCE_DIR/$clean_dir/"
    sanitized_dir=$(sanitize_dirname "$clean_dir")

    # Handle destination path construction for remote vs local
    if is_remote_destination; then
        # For remote destinations, we need to handle the host:path format carefully
        remote_host=$(echo "$DESTINATION" | cut -d':' -f1)
        remote_base_path=$(echo "$DESTINATION" | cut -d':' -f2-)
        dest_path="$remote_host:$remote_base_path/$sanitized_dir/"
    else
        dest_path="$DESTINATION/$sanitized_dir/"
    fi

    # Show what we're doing if names are different
    if [ "$clean_dir" != "$sanitized_dir" ]; then
        echo -e "${YELLOW}Note: Renaming \"$clean_dir\" → \"$sanitized_dir\" (spaces → dashes)${NC}"
    fi
    echo -e "Source path: ${YELLOW}$source_path${NC}"
    echo -e "Destination path: ${YELLOW}$dest_path${NC}"

    # Use rsync directly without eval to better handle spaces
    if [ -n "$SSH_COMMAND" ]; then
        rsync -avh --progress --stats --exclude='@eaDir' --exclude='#recycle' \
              $([ "$DRY_RUN" = true ] && echo "--dry-run") \
              -e "$SSH_COMMAND" \
              "$source_path" "$dest_path"
    else
        rsync -avh --progress --stats --exclude='@eaDir' --exclude='#recycle' \
              $([ "$DRY_RUN" = true ] && echo "--dry-run") \
              "$source_path" "$dest_path"
    fi

    if [ "$DRY_RUN" = true ]; then
        if [ "$clean_dir" != "$sanitized_dir" ]; then
            echo -e "${GREEN}✓ \"$clean_dir\" → \"$sanitized_dir\" checked${NC}"
        else
            echo -e "${GREEN}✓ \"$clean_dir\" checked${NC}"
        fi
    else
        if [ "$clean_dir" != "$sanitized_dir" ]; then
            echo -e "${GREEN}✓ \"$clean_dir\" → \"$sanitized_dir\" synced${NC}"
        else
            echo -e "${GREEN}✓ \"$clean_dir\" synced${NC}"
        fi
    fi

    ((current_dir++))
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}🎉 All directories checked successfully!${NC}"
    echo -e "${YELLOW}📝 This was a dry run - no files were actually transferred${NC}"
else
    echo -e "${GREEN}🎉 All directories processed successfully!${NC}"
fi

# Final summary
echo ""
echo -e "${BLUE}Final Summary:${NC}"
echo "============="
if [ "$DRY_RUN" = true ]; then
    echo -e "Mode: ${YELLOW}DRY RUN${NC} (no files transferred)"
else
    echo -e "Mode: ${YELLOW}LIVE SYNC${NC} (files transferred)"
fi
total_size=$(du -sh "$SOURCE_DIR" | cut -f1)
echo -e "Total source size: ${YELLOW}$total_size${NC}"
echo -e "Source: ${YELLOW}$SOURCE_DIR${NC}"
echo -e "Destination: ${YELLOW}$DESTINATION${NC}"
echo -e "Directories processed: ${YELLOW}$total_dirs${NC}"

# Cleanup SSH master connection if it was used
if [ "$USE_MASTER_CONNECTION" = true ] && [ -n "$SSH_MASTER_SOCKET" ]; then
    if [ -S "$SSH_MASTER_SOCKET" ]; then
        echo ""
        echo -e "${BLUE}Cleaning up SSH master connection...${NC}"
        ssh -o "ControlPath=$SSH_MASTER_SOCKET" -O exit "$REMOTE_HOST" 2>/dev/null
        echo -e "${GREEN}✓ SSH master connection closed${NC}"
    fi
fi