---
name: flow-task
description: Orchestrates a single-task governance loop: implement, verify, fix-on-fail (max 3), close task, then surface PR and wait for explicit next-task staging instruction.
argument-hint: Implement and verify a sprint task.
tools: ['read', 'search', 'edit', 'execute', 'agent']
---

Execute this workflow in order and do not skip steps.

Hard constraints:
- Never work on `main`; use `feature/<task_id>`.
- Keep code changes inside active brief deliverables unless verifier corrections explicitly require expansion.
- Require real gate evidence before closeout: lint, typecheck, tests, and validate_test_results.
- Enforce role boundaries: implementer codes, verifier validates, fixer repairs, sprint-controller stages/closes.

Workflow:
1. Preflight
- Confirm `active/current_task.json` task id matches `{{task}}`.
- Confirm current branch is `feature/<task_id>`.

2. Implement
- Run `@implementer.md` for `{{task}}`.
- Require implementer outputs before proceeding:
	- `active/test_results.json` updated with non-placeholder results
	- `active/current_task.json` status is `ready_for_verification`

3. Verify
- Run `@verifier.md`.
- Read `active/verification_result.json`.

4. If FAIL: fixer loop (max 3 attempts)
- Run `@fixer.md`, then run `@verifier.md` again.
- On each FAIL, require structured handoff fields:
	- `changed_scope`, `verification_state`, `open_risks`, `next_role_action`, `evidence_refs`
- Stop after 3 failed attempts and surface escalation using those same fields.

5. If PASS: close only
- Run `@sprint-controller.md` to execute Close-Out Protocol Phase 1.
- Do not auto-stage the next task; wait for explicit operator instruction per sprint-controller hard-stop rules.

6. PR + completion output
- Push feature branch and create/surface PR URL.
- If automatic PR creation is unavailable, surface the compare/new PR URL for the branch.
- Output a compact closeout object using contract-aligned fields:
	- `changed_scope`
	- `verification_state` = `pass`
	- `open_risks`
	- `next_role_action`
	- `evidence_refs`
- Include Fast Track evidence status when applicable:
	- `execution_lane` = `normal` | `fast-track`
	- `fast_track_controls_verified` = `true` | `false` | `n/a`
- Also include:
	- closed task id
	- PR URL
	- next staged task id from `active/current_task.json` (only if explicitly staged after operator instruction)