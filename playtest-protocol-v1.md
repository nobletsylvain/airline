# Playtest Protocol v1: First Real Playtest Session

**Version:** 1.0  
**Date:** January 2026  
**Prepared by:** Playtest Coordinator  
**Companion to:** decision-density-spec.md, difficulty-curve-spec.md, compromise-system-spec.md, gameplay-concerns.md

---

## Overview

This protocol defines the structure for the first real playtest session once a playable build is available. It focuses on validating the core hypotheses from our gameplay specs before investing in polish or additional content.

---

## Objectives

- [ ] Validate decision density targets (8-12/session Founder, 5-8 Manager)
- [ ] Identify dead spots where players have nothing meaningful to do
- [ ] Test obligation visibility and comprehension at creation time
- [ ] Observe first competitor encounter reactions
- [ ] Measure time-to-first-crisis and player recovery behavior
- [ ] Assess tutorial effectiveness ("flying in 90 seconds" goal)

---

## Player Criteria

- **Experience**: New to this game, but familiar with tycoon genre
- **Sample size**: 5-8 players minimum
- **Recruitment notes**: 
  - Mix of optimization-focused and narrative-focused players
  - At least 2 players who identify as "casual" gamers
  - Exclude aviation industry professionals (too much domain knowledge)

---

## Setup Instructions

1. **Game state**: Fresh start (no save), Year 2025, default difficulty
2. **Configuration**: 
   - Enable decision tracking telemetry
   - Enable "time between decisions" logging
   - Enable session recording (with consent)
3. **What to tell players**: 
   - "Play for 90 minutes naturally. We'll ask questions after."
   - "Think aloud when you're confused or uncertain."
   - Do NOT explain any mechanics — let tutorial work (or fail)
4. **What NOT to tell players**:
   - Do not explain obligation system in advance
   - Do not warn about competitor behavior
   - Do not hint at phase transitions

---

## Observation Checklist

During play, watch for:

### Tutorial & Onboarding
- [ ] Time from "New Game" to first flight launched
- [ ] Did player read or skip tutorial dialogs?
- [ ] First moment of visible confusion (what triggered it?)
- [ ] First time player says "I don't know what to do"

### Decision Density
- [ ] Longest period with no player input (seconds)
- [ ] What was player doing during idle periods? (watching? exploring? bored?)
- [ ] Did player seek out decisions or wait for them to surface?
- [ ] Any decisions that felt "trivial" (player clicked without reading)?

### Obligation System
- [ ] Did player read obligation creation dialog fully?
- [ ] Did player check Obligations Ledger proactively?
- [ ] First reaction to obligation call (surprise? understanding? frustration?)
- [ ] Did player remember obligation origin when called?

### Competition
- [ ] First reaction to competitor entering a route
- [ ] Did player understand their response options?
- [ ] Did player feel the competitive response was "fair"?

### Crisis & Difficulty
- [ ] Time to first "warning" state (cash, route, etc.)
- [ ] Player's emotional response to first crisis
- [ ] Did player attempt recovery or give up?
- [ ] Any "I should restart" comments?

### Engagement Signals
- [ ] Moments of visible excitement (leaning forward, verbal satisfaction)
- [ ] Moments of visible frustration (leaning back, sighing, clicking rapidly)
- [ ] When did player check the clock or ask "how much longer"?
- [ ] Any spontaneous "I want to keep playing" at end of session?

---

## Post-Session Questions

### Immediately After (within 2 minutes of stopping)

Capture fresh reactions before rationalization sets in:

1. "What was the most satisfying moment of your session?"
2. "What was the most frustrating moment?"
3. "Was there any point where you didn't know what to do next?"
4. "Did anything surprise you — good or bad?"

### After Short Break (5 minutes, allow reflection)

5. "On a scale of 1-5, how clear were your goals at any given time?"
6. "On a scale of 1-5, how meaningful did your decisions feel?"
7. "On a scale of 1-5, how fair did setbacks feel?"
8. "Tell me about the obligations system. What did you understand about it?"
9. "Tell me about the competitors. How did they affect your experience?"
10. "Would you play again tomorrow? Why or why not?"

### Deep Dive (if time permits)

11. "What did you think about [specific decision they made]?"
12. "Did you feel in control of your airline?"
13. "What would you change about the first hour?"

---

## Red Flags to Watch For

### Critical (session-ending concerns)
- Player explicitly says "this is boring" during play
- Player restarts within first 30 minutes
- Player experiences bankruptcy without understanding why
- Player says "I don't understand" more than 3 times in first hour

### Major (design concerns)
- Idle periods >5 minutes in Founder phase
- Player skips obligation dialog without reading
- Player says "that's not fair" about competitor or obligation
- Player disengages (checks phone, looks around) during gameplay

### Minor (polish concerns)
- Player takes >10 seconds to find a specific UI element
- Player misinterprets a number or statistic
- Player expresses minor confusion that resolves itself

---

## Success Criteria

### The playtest is successful if:
- 80%+ of players reach profitability within first hour
- Average idle time <3 minutes during Founder phase
- 60%+ of players express interest in continuing after 90 minutes
- 70%+ of players can explain the obligation system accurately afterward
- No player experiences bankruptcy without at least 2 warning dialogs

### The playtest indicates need for revision if:
- >30% of players express significant frustration before hour 1
- Average idle time >5 minutes in any phase
- <50% of players want to continue after 90 minutes
- >40% of players misunderstand obligations when called
- Any player feels a failure was "unfair" or "random"

---

## Metrics to Collect (Telemetry)

| Metric | Source | Analysis Purpose |
|--------|--------|------------------|
| Decisions per minute | Game log | Validate density targets |
| Longest idle period | Game log | Identify dead spots |
| Decision response time | Game log | Assess complexity |
| Dialog dismiss speed | Game log | Check if players read text |
| Route profitability variance | Game log | Assess learning curve |
| Obligation creation → call time | Game log | Validate frequency |
| Player-initiated vs surfaced decisions | Game log | Assess agency |

---

## Debrief Template

After all sessions, compile results using this template:

```markdown
## Playtest Debrief: Session [Date]

### Participants
- Player count: X
- Session length: 90 min each
- Build version: [version]

### Quantitative Summary
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Time to first flight | <90 sec | [avg] | ✅/⚠️/❌ |
| Decisions/session (Founder) | 8-12 | [avg] | ✅/⚠️/❌ |
| Max idle time | <2 min | [max] | ✅/⚠️/❌ |
| Obligation comprehension | >70% | [%] | ✅/⚠️/❌ |
| "Would play again" | >60% | [%] | ✅/⚠️/❌ |

### Key Observations
1. [Most significant finding]
2. [Second most significant]
3. [Third]

### Spec Validation
| Spec Section | Status | Notes |
|--------------|--------|-------|
| decision-density §3.1 | [validated/needs work] | [notes] |
| difficulty-curve §6.1 | [validated/needs work] | [notes] |
| compromise-system §2 | [validated/needs work] | [notes] |

### Recommended Changes
1. [Highest priority change]
2. [Second priority]
3. [Third priority]

### Open Questions for Design
- [Question that emerged from playtesting]
- [Another question]
```

---

## Pre-Playtest Checklist

Before running the session:

- [ ] Build is stable (no known crashes)
- [ ] Telemetry is enabled and logging correctly
- [ ] Screen recording software tested
- [ ] Consent forms prepared
- [ ] Quiet room with no interruptions
- [ ] Backup save available if needed
- [ ] Observer has printed copy of this protocol
- [ ] Post-session questions printed (don't read from screen)
- [ ] Snacks/water for players (90 min is long)
- [ ] Thank-you compensation ready (if applicable)

---

## Notes for Observer

- **Stay quiet** during play. Don't help unless player is genuinely stuck (5+ min with no progress)
- **Take notes** on paper, not keyboard (typing is distracting)
- **Timestamp** key moments for video review
- **Don't react** to player mistakes — we want natural behavior
- **Don't answer** mechanical questions during play — "What do you think it means?" is a valid response

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | January 2026 | Initial protocol based on spec review |
