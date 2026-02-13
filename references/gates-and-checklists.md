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

## Multi-Agent Anti-Patterns

- Parallelizing a single critical path with no true independence.
- Assigning the same file to multiple active owners.
- Running high-risk work without an independent reviewer.
- Continuing multi-agent mode after repeated merge/conflict churn.

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

## Principal Review Gate Checklist

- Principal reviewer is independent from executor for this mission.
- Review artifacts exist in both formats (`principal-review.md` and `principal-review.json`).
- Every finding has `id`, severity, remediation action, and status.
- Reviewer gate decision is explicit (`approved|changes_required|blocked`).
- Gate decision is captured in validation matrix.

## Review Resolution Checklist

- All findings from principal review are resolved (no `open` status).
- Each resolved finding has validation evidence.
- Re-review confirmation is captured after remediation.
- Mission remains blocked if any finding is unresolved.

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
- `principal_review_summary`
- `confidence`
- `open_risks`
