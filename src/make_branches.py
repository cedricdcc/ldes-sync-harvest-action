import os
import subprocess
from config_validation import load_config
import pathlib

# Configuration
FOLDERS_TO_SEARCH = os.getcwd()
CONFIG_LOCATION = pathlib.Path(__file__).parent / "../config.yml"
BRANCH_PREFIX = "batch-"

config = load_config(CONFIG_LOCATION)
print(f"Loaded config: {config}")
FILES_PER_BRANCH = config.get("batch-size", 50)


def find_yml_files(folder):
    print(f"Searching for yml files in {folder}")
    yml_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".yml"):
                yml_files.append(os.path.join(root, file))
    print(f"Found {len(yml_files)} yml files")
    return yml_files


def create_branch(branch_name, files):
    subprocess.run(["git", "checkout", "-b", branch_name])
    for file in files:
        subprocess.run(["git", "add", file])
    subprocess.run(["git", "commit", "-m", f"Add {len(files)} yml files"])
    subprocess.run(["git", "push", "origin", branch_name])


def main():
    yml_files = find_yml_files(FOLDERS_TO_SEARCH)
    for i in range(0, len(yml_files), FILES_PER_BRANCH):
        branch_name = f"{BRANCH_PREFIX}{i // FILES_PER_BRANCH + 1}"
        create_branch(branch_name, yml_files[i : i + FILES_PER_BRANCH])


if __name__ == "__main__":
    main()
