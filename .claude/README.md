# CLAUDE Agent Commands

This directory contains the Claude Code slash commands for the CLAUDE Agent System adapted for PowerShell module development.

## Available Commands

### Individual Agents
- `/planner` - Strategic Problem Analysis & Solution Design
- `/executer` - PowerShell Implementation Specialist  
- `/verifier` - Code Quality Guardian & Standards Enforcer
- `/tester` - Functionality Validator & Quality Assurance
- `/documenter` - Knowledge Keeper & Pattern Archivist
- `/updater` - Version Control & Deployment Manager

### Workflow
- `/workflow` - Complete CLAUDE Agent Sequence (runs all agents sequentially)

## Usage Examples

```bash
# Individual agent usage
/planner "Get-SEPCloudDevice function failing with authentication errors"
/executer  # (reads WORK.md Phase 1)
/verifier  # (reads WORK.md Phase 2) 
/tester    # (reads WORK.md Phase 3)
/documenter # (reads WORK.md Phase 4)
/updater   # (reads WORK.md Phase 5)

# Complete workflow
/workflow "Need to implement pagination support for Get-SEPCloudDevice"
```

## Agent Sequence

The agents work in this sequential order:
1. **PLANNER** → Creates WORK.md with detailed execution plan
2. **EXECUTER** → Implements PowerShell code following patterns
3. **VERIFIER** → Validates code quality and runs tests
4. **TESTER** → Comprehensive functionality testing
5. **DOCUMENTER** → Updates documentation and patterns
6. **UPDATER** → Creates git commit and deployment

Each agent is self-contained with complete instructions and follows PowerShell module development best practices.