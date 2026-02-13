---
name: mission-ops
description: "Execute software missions end-to-end with an integrated deep planning and execution workflow: repository reconnaissance, baseline validation, task DAG planning, gated implementation, continuous verification, rollback readiness, and final evidence reporting. Trigger when users ask to plan and execute thoroughly, reduce execution errors, avoid missing details, run production-safe changes, or request strict validation gates."
---

# Mission Ops

Run a deterministic plan-and-execute workflow with explicit quality gates.

## Mission Contract

Always run both planning and execution in one skill flow unless blocked by critical unknowns.

Operating roles (lightweight):

- `coordinator`: maintains mission objective, task state, and gate decisions.
- `executor`: implements assigned change slices.
- `reviewer` (required for tier 1+): independently challenges assumptions and verifies risky outputs.
- `principal_reviewer` (required for all tiers): performs independent post-verification review as a hard gate.

Inputs:

- Required: `objective`
- Optional: `scope`, `risk_tolerance` (`low|medium|high`), `mode` (`deep|standard`), `time_budget`, `must_not_break`

Defaults:

- `scope`: full repository
- `risk_tolerance`: `low`
- `mode`: `deep`

## Phase 0: Intake and Normalization

- Rewrite user request into one explicit mission objective.
- Define measurable success criteria.
- Resolve scope path/module/service.
- Extract explicit constraints and non-goals.
- If critical ambiguity remains, ask focused questions before modifying code.

Exit criteria:

- Objective, scope, and success criteria are explicit.

## Phase 1: Deep Reconnaissance

Capture current state before planning any edits.

Required recon evidence:

- Repository root, branch, HEAD, and `git status --short` summary.
- Top-level structure and likely entrypoints.
- Stack and manifests (`go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `build.gradle*`, `WORKSPACE*`, `MODULE.bazel`).
- Existing test/lint/build/run commands from Makefiles, taskfiles, scripts, README, and CI workflows.
- Existing tests by type and quality signals (skips/flaky/weak assertions when detectable).
- Critical invariants and regression boundaries inferred from docs/tests/code.

Rules:

- Do not rely on prompt-only assumptions when code exists.
- If multiple repos or target modules are plausible, ask for disambiguation.

Exit criteria:

- Recon evidence is sufficient to build a grounded plan.

## Phase 2: Baseline Validation

Run baseline checks from discovered canonical commands.

- Prefer fast smoke checks first.
- Capture baseline pass/fail state.
- If baseline is red, enter degraded mode:
  - Continue mission with isolated validation where possible.
  - Explicitly report pre-existing failures.

Exit criteria:

- Baseline state documented and accounted for in plan.

## Phase 3: Execution Plan Synthesis

Create a task dependency graph (DAG) with risk and verification.

For each task define:

- `task_id`
- `goal`
- `owner`
- `dependencies`
- `file_ownership`
- `risk_tier` (0-3)
- `primary_risk`
- `mitigation`
- `rollback`
- `validation_required`

Planning requirements:

- Prefer minimal critical path.
- Avoid splitting the same file across multiple owners.
- Ensure all high-risk tasks include explicit rollback and detection signals.

Exit criteria:

- DAG is dependency-valid and each task has verification and rollback.

## Phase 4: Preflight Gate

Validate plan before edits.

Checklist:

- Commands/tools referenced by plan actually exist.
- Files/paths in plan exist or are intentionally created.
- No circular dependency in task ordering.
- Success metrics and stop criteria are measurable.
- Validation matrix covers each task.

If preflight fails, fix plan first and re-run preflight.

Exit criteria:

- Preflight passes.

## Phase 4.5: Adaptive Execution Mode Selection

Select execution mode after preflight and before edits.

Modes:

- `single-agent`: one executor handles all tasks sequentially.
- `multi-agent-subagents`: parallel independent tasks that converge through one coordinator.
- `multi-agent-team`: parallel interdependent tasks with explicit cross-task coordination.

Decision signals:

- Prefer `single-agent` when work is mostly sequential, tightly coupled, or concentrated in the same files.
- Prefer `multi-agent-subagents` when at least two independent task slices exist with low file overlap.
- Prefer `multi-agent-team` when tasks are parallel but interdependent, or when risk tier is medium/high and independent verification is required.
- For small scope with high coordination overhead, downgrade to `single-agent`.

Required guardrails for multi-agent modes:

- Strict file ownership per task to minimize conflicts.
- One shared source of truth for task states and dependencies.
- Mandatory conflict check before final gate.
- Mandatory independent review evidence for tier 1+ tasks.
- Automatic fallback to `single-agent` if coordination overhead exceeds throughput gains.

Mode re-evaluation:

- Re-evaluate at each checkpoint.
- Downgrade or upgrade mode when blockers, conflict rates, or dependency drift change.

## Phase 5: Controlled Execution

Execute in small, verifiable batches.

Quarterdeck rhythm:

- Run checkpoints at a fixed cadence (typically every 15-30 minutes).
- At each checkpoint: update task states, evaluate blockers, re-check execution mode fit, and decide one concrete next action.
- If progress drifts from mission metric, explicitly choose: continue, narrow scope, rollback batch, or stop.

Batch protocol:

1. Apply minimal change set.
2. Run targeted validations for affected area.
3. Record evidence.
4. Mark task state (`pending|in_progress|completed`).

Failure protocol:

- Attempt bounded repair.
- If unresolved, rollback batch and escalate.
- Do not continue with unresolved high-risk failures.

Rules:

- No task is complete without evidence.
- Keep one active task per owner unless explicit multitask need is justified.
- Avoid splitting the same file across multiple active owners.
- If conflict churn rises or dependency coupling increases, collapse to `single-agent` mode.

Exit criteria:

- Planned tasks completed or blocked with explicit reason.

## Phase 6: Final Verification Gate

Run final validation according to risk and scope:

- smoke checks
- targeted regression pack
- broader suite for medium/high risk missions

Confirm:

- mission success criteria satisfied
- must-not-break invariants preserved
- no unresolved high-risk unknowns

Exit criteria:

- Final gate result documented.

## Phase 7: Principal Engineer Review Gate

Run an independent review after Phase 6 and before closeout.

Review requirements:

- Reviewer must be independent from the executor for the reviewed change set.
- Review must cover objective fulfillment, risk controls, rollback readiness, and validation sufficiency.
- Every finding must include a unique ID, severity, actionable remediation, and status.

Hard gate policy:

- Mission cannot proceed past this phase until review is completed and recorded.
- Gate is `pass` only when reviewer decision is `approved`.

Artifacts:

- `<base>/principal-review.md`
- `<base>/principal-review.json`

Exit criteria:

- Principal review completed with explicit decision (`approved|changes_required|blocked`).
- Review artifacts written in both markdown and JSON.
- Gate result documented in validation matrix.

## Phase 8: Review Comment Resolution

Resolve all principal review comments before closeout.

Resolution requirements:

- All comments from `principal-review.json` must be moved to `resolved`.
- Each resolution must include validation evidence.
- Re-review is required after remediation to confirm closure.

Failure protocol:

- If any review finding cannot be resolved, mission status is `blocked`.
- Do not proceed to closeout with unresolved review findings.

Exit criteria:

- Zero open findings remain.
- Reviewer re-verification complete.
- Gate result documented in validation matrix.

## Phase 9: Evidence and Closeout

Generate mission artifacts in selected cache base directory:

Cache base selection order:

- `.codex/`
- `.claude/`
- `.cursor/`
- `.agent-cache/`

Write:

- `<base>/mission-plan.md`
- `<base>/validation-matrix.json`
- `<base>/run-log.md`
- `<base>/final-report.md`
- `<base>/principal-review.md`
- `<base>/principal-review.json`

Use templates from:

- `references/mission-plan-template.md`
- `references/final-report-template.md`
- `references/validation-matrix-template.json`
- `references/principal-review-template.md`
- `references/principal-review-template.json`

## Required Output Contract (Chat)

Return:

- `Action`: plan+execute completed or blocked
- `Scope`: repo and mission scope
- `Execution mode`: `single-agent|multi-agent-subagents|multi-agent-team`
- `Result`: objective status and key changes
- `Validation`: checks run and outcomes
- `Principal review`: decision and reviewer signoff status
- `Review resolution`: resolved/open findings summary
- `Confidence`: `High|Medium|Low`
- `Open risks`: remaining risks/unknowns
- `Next step`: immediate recommendation

## Risk Tiers and Controls

- Tier 0: low blast radius, easy rollback
- Tier 1: user-visible behavior changes
- Tier 2: security/privacy/data/financial risk
- Tier 3: irreversible or highly sensitive operations

Mandatory controls:

- All tiers: principal review hard gate + complete comment resolution before closeout
- Tier 1+: independent review signal + negative/failure-path validation
- Tier 2+: adversarial check + go/no-go checkpoint + staged rollout when possible
- Tier 3: explicit human confirmation before irreversible actions

## Guardrails

- Never use destructive operations without explicit user confirmation.
- Never claim verification evidence that was not run or observed.
- Never skip regression checks for touched critical paths.
- Mark unknowns explicitly instead of guessing.
- Stop early when control requirements cannot be met safely.
- Never close mission while any principal review finding is unresolved.

## Mission Quality Checklist

Before marking the mission complete, verify all conditions:

- Recon evidence captured and reflected in plan assumptions.
- Every completed task has command/output evidence in run log.
- Every medium+ risk task has explicit rollback notes.
- Validation matrix entries exist for each task and each gate.
- Principal review artifacts exist and include explicit reviewer decision.
- All principal review findings are resolved with evidence.
- Final report includes objective status, residual risks, and next actions.
- No unchecked high-risk unknowns remain.

If any item fails, mission status must remain `blocked` or `partial`, never `complete`.

## Stop and Escalation Matrix

- Stop immediately when:
  - irreversible action is required without explicit user confirmation
  - destructive command is requested without approval
  - risk tier controls cannot be satisfied
- Escalate with one recommendation when:
  - baseline is red and root cause is ambiguous
  - required tools/commands are unavailable
  - scope ambiguity affects safety or correctness

## Efficiency Rules

- Use fast checks per batch, broader checks at milestones.
- Prefer targeted tests based on changed files and dependency impact.
- Reuse cached mission intelligence when HEAD and key manifests are unchanged.
- Keep coordination concise and decision-focused.
