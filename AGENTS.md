# AGENTS.md

## Objective

Build AirWaveLab according to `PRD.md`, prioritizing a reliable, measurable MVP before advanced features.

## Working Rules

- Use MATLAB as the primary implementation language.
- Keep each pipeline stage modular with explicit inputs, outputs, and configuration.
- Use fixed random seeds for experiments and tests.
- Implement core concepts directly; use toolbox functions as references or optional accelerators.
- Do not begin stretch work until all MVP success metrics pass.
- Do not claim 5G NR compliance unless verified against the standard/toolbox.
- Keep generated data and large media out of version control.

## Required Validation

- Test exact round trip with channel impairments disabled.
- Test CRC and channel-code error behavior.
- Compare simulated BER with theory where available.
- Run the end-to-end demo after meaningful pipeline changes.

## Documentation Discipline

- Update `CURRENT_STATUS.md` after meaningful progress.
- Record scope, architecture, dependency, or metric changes in `DECISIONS.md`.
- Keep documentation concise and consistent with `PRD.md`.

