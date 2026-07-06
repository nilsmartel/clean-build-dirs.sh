# Clean Build dirs

Script to help reclaim disc space by removing all `node_modules` and `target` directories,
which are cache directories of `npm` (javascript ecosystem) and `cargo` (rust ecosystem) respectively.

This tool offers dry run capabilities, which are enabled by default.
Pass the `--force`, otherwise this tool will just present to you how much disk space can be reclaimed by executing it.
