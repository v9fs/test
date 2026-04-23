# v9fs test harness

This repository contains **test code and scripts** for exercising the Linux **9p (v9fs)** filesystem.

The kernel source under test lives in the upstream repository:

- `https://github.com/v9fs/linux`

## What lives here

- **CI workflows**: automation to build/run tests against a chosen kernel revision
- **Test code**: focused repros and regression tests for v9fs behavior
- **Scripts**: helpers to run locally and/or in CI

## How we work in this repo

- **Development branch**: all active work happens on `rework`
- **Change log**: keep `CHANGES.md` updated for every change set
- **Work tracking**: keep `TODO.md` updated as items are added/removed

## Quick start

This repo intentionally does *not* vendor the kernel source. Most workflows/scripts will:

1. Fetch `github.com/v9fs/linux` (or a fork/branch you specify)
2. Build the kernel (or use a provided artifact)
3. Run the tests in this repository against that kernel

If you tell me how you typically run tests here (CI only vs local/QEMU/VM), I can document the exact command sequence in this section.
