CLAUDE.md
Mission
Debug, fix, and improve fast. Minimize tokens, preserve behavior, verify changes.
Workflow
- Respond in Indonesian; keep it brief.
- Read DEVLOG.md first for current context, then inspect git status --short and only relevant code.
- Treat repository state, logs, and test results as evidence; chat history is optional context.
- For errors: trace the execution path, identify root cause, make the smallest complete fix, then verify it.
- For optimization: establish a real bottleneck before changing code. Avoid guesswork, unrelated refactors, and new dependencies.
- Search before opening files. Read targeted ranges; don't dump the repo, large files, or full logs.
- Verify commands and conventions from the repo; never invent them.
- If a fix fails, use new evidence and continue; don't repeat the same attempt.
- Ask only when blocked or when a choice could cause destructive or materially wrong behavior.
- Preserve user changes. Never reset, commit, push, or change branches.
- Never expose or hard-code secrets, tokens, session strings, or API keys.
- Keep tests safe: avoid real account actions, spam, production side effects, and unnecessary costly calls.
Token budget
- Prefer one focused investigation and one concise batch of relevant checks over many narrated commands.
- Run commands compactly; show only summaries, failures, and relevant log excerpts.
- Redirect long output to a log file; inspect tail or targeted rg matches, not the full log.
- Don't reread unchanged files or repeat context recorded in DEVLOG.md.
- Don't create docs/reports beyond requested files and DEVLOG.md.
- Update DEVLOG.md at meaningful checkpoints and before ending a long session. Record only facts needed to resume.
- Final response: root cause, change, verification, next step/blocker—in a few lines.
Long-running tests
- Before a long test, record the exact command, log path, start time, and stop condition in DEVLOG.md.
- Prefer existing test scripts and file-based logs. Avoid frequent polling; check at meaningful intervals or when failure/finish is expected.
- Never claim a background or overnight test passed unless completion and result were verified.
- At checkpoint, record process/session status if available, last useful log line, result so far, and next check.