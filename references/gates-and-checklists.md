# Mission Ops Gates and Checklists

## Preflight Checklist

- Objective, scope, success criteria defined.
- Repository recon evidence captured.
- Baseline status documented.
- Task DAG dependency-valid.
- Every task has validation requirements.
- Every medium+ risk task has rollback notes.

## Per-Batch Checklist

- Change set matches planned task scope.
- Targeted validation command(s) executed.
- Evidence captured in run log.
- Rollback path still valid.

## Final Gate Checklist

- Success criteria satisfied.
- Must-not-break invariants preserved.
- Regression pack executed.
- Open risks documented with owner and next action.

## Suggested JSON schema for validation-matrix.json

Top-level keys:

- `repo_root`
- `branch`
- `head_commit`
- `generated_at`
- `mission_objective`
- `scope`
- `tasks`
- `checks`
- `gate_results`
- `confidence`
- `open_risks`
