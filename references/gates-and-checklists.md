# Mission Ops Gates and Checklists

## Preflight Checklist

- Objective, scope, success criteria defined.
- Repository recon evidence captured.
- Baseline status documented.
- Task DAG dependency-valid.
- Every task has validation requirements.
- Every medium+ risk task has rollback notes.
- Execution mode selected (`single-agent`, `multi-agent-subagents`, or `multi-agent-team`) with rationale.

## Adaptive Mode Checklist

- Are there at least two independent task slices?
- Is shared file overlap low enough for safe parallelism?
- Do risk controls require independent/adversarial review?
- Is coordination overhead likely lower than expected parallel gain?
- Is fallback path to `single-agent` documented if coordination degrades?

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
