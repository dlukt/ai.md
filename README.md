# ai.md

A collection of prompts

### Random info

#### opencode

How to run a command in opencode.
Run the `review-uncommited` command using the `minimax-coding-plan/MiniMax-M2.1` model
```
opencode run --command review-uncommited --model minimax-coding-plan/MiniMax-M2.1
```

Run the `review-uncommited` command using the `github-copilot/gpt-5.2-codex` model
```
opencode run --command review-uncommited --model github-copilot/gpt-5.2-codex
```

#### default coding loop

Create PRD.md, SPEC.md and PLAN.md
The PLAN.md should have Milestones and Tasks and TDD should be used.
Each Milestone and Task should have a [ ] and the plan should have a note about the need to [x] completed Milestones and Tasks.

1. Implement an unimplemented Milestone
2. run `opencode run --command review-uncommited --model github-copilot/gpt-5.2-codex` with a 1 hour timeout
3. if no issues are found continue. if issues are found, address the issues and goto 2. until no issues / the review passes
4. [x] completed tasks
5. create a git commit and push
6. goto 1.
