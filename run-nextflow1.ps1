# Ensure we're using POSIX-style paths for Docker (convert C:\ to /c/)
$pwdPosix = (Get-Location).Path -replace '\\','/' -replace '^([A-Za-z]):','/$1'

# Step 1: Build the Docker image
docker build --platform linux/amd64 -t nextflow-conda .

# Step 2: Run the workflow using the built image
docker run --rm -it `
  --platform linux/amd64 `
  -v "/tmp:/tmp" `
  -v "${pwdPosix}:${pwdPosix}" `
  -w "${pwdPosix}" `
  -v "//var/run/docker.sock:/var/run/docker.sock" `
  nextflow-conda nextflow run main.nf
