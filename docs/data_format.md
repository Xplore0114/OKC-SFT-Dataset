# Data Format Documentation

## Overview

This document describes the data format for the OKC-SFT Dataset, including training sets and test set.

## File Structure

```
OKC-SFT-Dataset/
├── data/
│   ├── okc_sft_train.jsonl     # OKC-SFT training samples
│   ├── qa_sft_train.jsonl      # QA-SFT baseline training samples
│   └── test_set.jsonl          # Evaluation test set
├── raw_materials/
│   ├── scenarios.json          # Scenario definitions
│   ├── reference_answers.json  # Reference answers
│   ├── kg_evidence.json        # Knowledge graph evidence
│   └── scoring_rubric.json     # Scoring criteria
└── docs/
    ├── data_format.md          # This file
    └── usage_guide.md          # Usage guide
```

## Training Data Format

### OKC-SFT Training Set (`okc_sft_train.jsonl`)

Each line is a JSON object with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `instruction` | string | Input instruction/question for the model |
| `input` | string | Additional context (e.g., DCS monitoring data) |
| `output` | string | Structured OKC response (6 fields) |
| `metadata` | object | Metadata about the sample |

#### OKC Output Structure

The `output` field contains six structured sections separated by newlines:

```
Diagnosis: [Abnormal state identification and severity assessment]

Evidence: [Process variables, equipment states, measurements supporting the judgment]

Possible Causes: [Causal mechanisms and fault sources]

Operation Suggestions: [Executable operating steps]

Verification Indices: [Post-action monitoring variables and recovery criteria]

Safety Notes: [Stop/slowdown/escalation conditions]
```

#### Metadata Fields

| Field | Type | Description |
|-------|------|-------------|
| `task_type` | string | Type of task (see Task Types below) |
| `scenario` | string | Abnormal operation scenario |
| `sample_id` | integer | Unique sample identifier |
| `knowledge_chain_ids` | array | Related OKC chain IDs |
| `source_trace` | array | Source references |

### QA-SFT Training Set (`qa_sft_train.jsonl`)

Each line is a JSON object with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `instruction` | string | Input instruction/question |
| `input` | string | Additional context (usually empty) |
| `output` | string | Unstructured answer text |
| `metadata` | object | Metadata about the sample |

## Test Set Format

### Test Set (`test_set.jsonl`)

Each line is a JSON object with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `sample_id` | string | Unique test sample ID (e.g., "T001") |
| `instruction` | string | Input instruction/question |
| `input` | string | Additional context |
| `expected_key_points` | array | Expected key points in the response |
| `task_type` | string | Type of task |
| `scenario` | string | Abnormal operation scenario |
| `source_trace` | array | Source references |

## Task Types

| Task Type | Description | Example |
|-----------|-------------|---------|
| `condition_recognition` | Identify abnormal operating conditions | "判断当前工况是否正常" |
| `cause_analysis` | Analyze root causes of faults | "分析氮塞的原因" |
| `operation_recommendation` | Generate operation suggestions | "给出处置建议" |
| `post_operation_verification` | Define verification criteria | "验证操作效果" |
| `safety_reminder` | Provide safety warnings | "需要注意哪些安全事项" |
| `tag_interpretation` | Interpret process variables | "解释AI705的含义" |
| `evidence_extraction` | Extract supporting evidence | "找出支持判断的证据" |

## Raw Materials Format

### scenarios.json

```json
{
  "scenarios": [
    {
      "id": "scenario_1",
      "name": "空压机跳车",
      "description": "空分装置运行中，空压机突然跳车..."
    }
  ]
}
```

### reference_answers.json

```json
{
  "scenario_1": {
    "answer": {
      "actions": ["立即启动备用空压机", ...],
      "priority": "高",
      "risk_level": "高",
      "expected_outcome": "恢复空分装置正常运行"
    },
    "must_have": [...],
    "unsafe_actions": [...],
    "monitoring_indicators": [...],
    "stop_conditions": [...]
  }
}
```

### kg_evidence.json

```json
{
  "scenario_1": {
    "entities": [
      {"id": "e1", "type": "设备", "name": "空压机"},
      ...
    ],
    "relations": [...],
    "paths": [...]
  }
}
```

### scoring_rubric.json

```json
{
  "criteria": {
    "root_cause_accuracy": {
      "weight": 20,
      "description": "根因识别准确性"
    },
    ...
  },
  "scale": {
    "excellent": 100,
    "good": 80,
    "fair": 60,
    "poor": 40,
    "very_poor": 20
  }
}
```

## Data Statistics

### OKC-SFT Training Set

- **Total samples**: 611
- **Task type**: condition_recognition (all samples)
- **Scenario**: nitrogen_plugging (all samples)
- **Average output length**: ~500 characters

### QA-SFT Training Set

- **Total samples**: 858
- **Task types**:
  - condition_recognition: 226
  - cause_analysis: 177
  - operation_recommendation: 131
  - post_operation_verification: 124
  - safety_reminder: 119
  - tag_interpretation: 48
  - evidence_extraction: 33
- **Scenario**: nitrogen_plugging (all samples)

### Test Set

- **Total samples**: 61
- **Task types**:
  - cause_analysis: 19
  - operation_recommendation: 15
  - tag_interpretation: 12
  - condition_recognition: 10
  - safety_reminder: 4
  - post_operation_verification: 1
- **Scenario**: nitrogen_plugging (all samples)

## Usage Examples

### Loading Data

```python
import json

def load_jsonl(filepath):
    """Load JSONL file and return list of dictionaries."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return [json.loads(line) for line in f]

# Load datasets
okc_train = load_jsonl('data/okc_sft_train.jsonl')
qa_train = load_jsonl('data/qa_sft_train.jsonl')
test_set = load_jsonl('data/test_set.jsonl')

print(f"OKC-SFT: {len(okc_train)} samples")
print(f"QA-SFT: {len(qa_train)} samples")
print(f"Test set: {len(test_set)} samples")
```

### Parsing OKC Output

```python
def parse_okc_output(output_text):
    """Parse OKC structured output into dictionary."""
    fields = {}
    current_field = None
    current_content = []
    
    for line in output_text.split('\n'):
        if line.startswith('Diagnosis:'):
            if current_field:
                fields[current_field] = '\n'.join(current_content).strip()
            current_field = 'diagnosis'
            current_content = [line[len('Diagnosis:'):].strip()]
        elif line.startswith('Evidence:'):
            if current_field:
                fields[current_field] = '\n'.join(current_content).strip()
            current_field = 'evidence'
            current_content = [line[len('Evidence:'):].strip()]
        elif line.startswith('Possible Causes:'):
            if current_field:
                fields[current_field] = '\n'.join(current_content).strip()
            current_field = 'causes'
            current_content = [line[len('Possible Causes:'):].strip()]
        elif line.startswith('Operation Suggestions:'):
            if current_field:
                fields[current_field] = '\n'.join(current_content).strip()
            current_field = 'operations'
            current_content = [line[len('Operation Suggestions:'):].strip()]
        elif line.startswith('Verification Indices:'):
            if current_field:
                fields[current_field] = '\n'.join(current_content).strip()
            current_field = 'verification'
            current_content = [line[len('Verification Indices:'):].strip()]
        elif line.startswith('Safety Notes:'):
            if current_field:
                fields[current_field] = '\n'.join(current_content).strip()
            current_field = 'safety'
            current_content = [line[len('Safety Notes:'):].strip()]
        elif current_field:
            current_content.append(line)
    
    if current_field:
        fields[current_field] = '\n'.join(current_content).strip()
    
    return fields

# Example usage
sample = okc_train[0]
parsed = parse_okc_output(sample['output'])
print(f"Diagnosis: {parsed.get('diagnosis', '')[:100]}...")
print(f"Evidence: {parsed.get('evidence', '')[:100]}...")
```

### Filtering by Task Type

```python
def filter_by_task_type(samples, task_type):
    """Filter samples by task type."""
    return [s for s in samples if s['metadata']['task_type'] == task_type]

# Get all cause analysis samples from QA-SFT
cause_analysis = filter_by_task_type(qa_train, 'cause_analysis')
print(f"Cause analysis samples: {len(cause_analysis)}")
```

## Notes

1. **Encoding**: All files use UTF-8 encoding
2. **Line format**: Each line in JSONL files is a valid JSON object
3. **Empty fields**: Some fields may be empty strings (e.g., `input` in QA-SFT)
4. **Metadata**: Metadata is optional but recommended for reproducibility
