import os
import subprocess
from config_validation import load_config
import pathlib

# Configuration
FOLDERS_TO_SEARCH = pathlib.Path(__file__).parent / "../.github/workspace"
CONFIG_LOCATION = pathlib.Path(__file__).parent / "../config.yml"
BRANCH_PREFIX = "batch-"

config = load_config(CONFIG_LOCATION)
FILES_PER_BRANCH = config.get("batch-size", 50)


def find_yml_files(folder):
    print(f"Searching for yml files in {folder}")
    yml_files = []
    for path in folder.rglob("*.yml"):
        yml_files.append(str(path))
    print(f"Found {len(yml_files)} yml files")
    return yml_files


def create_branch(branch_name, files):
    print(f"Creating branch {branch_name} with {len(files)} files")
    os.chdir(FOLDERS_TO_SEARCH)
    print(f"Current working directory: {os.getcwd()}")
    subprocess.run(["git", "checkout", "-b", branch_name])
    for file in files:
        subprocess.run(["git", "add", file])
    subprocess.run(["git", "commit", "-m", f"Add {len(files)} yml files"])
    subprocess.run(["git", "push", "origin", branch_name])
    subprocess.run(["git", "checkout", "main"])  # Switch back to main branch


def main():
    yml_files = find_yml_files(FOLDERS_TO_SEARCH)
    for i in range(0, len(yml_files), FILES_PER_BRANCH):
        branch_name = f"{BRANCH_PREFIX}{i // FILES_PER_BRANCH + 1}"
        create_branch(branch_name, yml_files[i : i + FILES_PER_BRANCH])


if __name__ == "__main__":
    main()
