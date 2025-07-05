Sample nextflow workflow that uses:
i) a process with a conda environment config
ii) a process with a Docker container config

To run locally:
```
nextflow run main.nf
```

To run nextflow in docker, we mount the host docker socket to allow spawing siblings. Call `./run.sh` to execute, which includes build and launch commands.
