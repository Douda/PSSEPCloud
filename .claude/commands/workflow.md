# /workflow - Complete CLAUDE Agent Sequence

Execute the full CLAUDE agent workflow in sequential order for comprehensive problem solving and implementation.

## Usage
`/workflow "problem description"`

This command will automatically execute all 5 CLAUDE agents in the correct sequence:

## Agent Sequence

### 1. PLANNER - Strategic Analysis (⏱️ 15-30 min)
**Invokes**: `/planner "problem description"`
- Investigates root cause 
- Creates comprehensive WORK.md
- Designs multi-phase solution
- Specifies parallel execution opportunities
- **Output**: Detailed implementation plan

### 2. EXECUTER - Implementation (⏱️ 30-60 min)
**Invokes**: `/executer` (reads WORK.md Phase 1)
- Implements PowerShell code following patterns
- Creates/modifies functions per specifications
- Follows CLAUDE.md standards exactly
- Creates corresponding Pester tests
- **Output**: Working PowerShell implementation

### 3. VERIFIER - Quality Assurance (⏱️ 15-25 min)
**Invokes**: `/verifier` (reads WORK.md Phase 2)
- Runs PowerShell Script Analyzer
- Executes Pester tests (`./build.ps1 -Tasks test`)
- Validates CLAUDE.md pattern compliance
- Performs security and standards review
- **Output**: Pass/Fail quality report

### 4. TESTER - Functionality Validation (⏱️ 30-45 min)
**Invokes**: `/tester` (reads WORK.md Phase 3)
- Tests all function parameters and scenarios
- Validates API integration and authentication
- Tests edge cases and error handling
- Performs cross-platform compatibility checks
- **Output**: Comprehensive test results

### 5. DOCUMENTER - Knowledge Archival (⏱️ 15-25 min)
**Invokes**: `/documenter` (reads WORK.md Phase 4)
- Updates CLAUDE-IN-PROGRESS.md with patterns
- Updates CHANGELOG.md with changes
- Creates/updates docs/ files if needed
- Archives learnings and anti-patterns
- **Output**: Updated documentation

### 6. UPDATER - Version Control (⏱️ 5-10 min)
**Invokes**: `/updater` (reads WORK.md Phase 5)
- Creates detailed conventional commit
- Commits to test-github-actions branch
- Provides deployment confirmation
- **Output**: Clean git commit ready for PR

## Execution Flow
```
Problem → PLANNER → EXECUTER → VERIFIER → TESTER → DOCUMENTER → UPDATER → Complete
                        ↓           ↓         ↓          ↓
                   Working Code → Quality ✅ → Tests ✅ → Docs ✅ → Git ✅
```

## Parallel Opportunities
- VERIFIER + TESTER can run parallel after EXECUTER (if specified by PLANNER)
- DOCUMENTER updates can begin during TESTER execution
- Multiple functions can be implemented in parallel by EXECUTER

## Success Criteria
- ✅ All PowerShell Script Analyzer rules pass
- ✅ All Pester tests pass
- ✅ Documentation updated
- ✅ Clean commit created
- ✅ Safe deployment process followed

## When to Use
- **New Feature Development**: Complete workflow for new PowerShell functions
- **Bug Fixes**: Full workflow ensures proper testing and documentation
- **Refactoring**: Systematic approach to code improvements
- **API Integration**: Comprehensive approach to new endpoint integration

## When NOT to Use
- Simple documentation updates (use `/documenter` only)
- Minor parameter changes (use `/executer` + `/verifier`)
- Quick testing (use `/tester` only)
- Emergency hotfixes (manual process may be faster)

## Total Time Estimate
- **Simple Problems**: 1-2 hours
- **Medium Problems**: 2-4 hours  
- **Complex Problems**: 4-8 hours

The workflow ensures every problem is solved systematically with proper quality gates, testing, and documentation.