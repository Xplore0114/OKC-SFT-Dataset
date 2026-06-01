# Usage Guide

## Overview

This guide explains how to use the OKC-SFT Dataset for training and evaluating language models on air separation unit (ASU) abnormal operation handling tasks.

## Prerequisites

- Python 3.8+
- Required packages: `json`, `pandas` (optional), `transformers` (for model training)

## Quick Start

### 1. Load the Dataset

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

print(f"OKC-SFT training samples: {len(okc_train)}")
print(f"QA-SFT training samples: {len(qa_train)}")
print(f"Test samples: {len(test_set)}")
```

### 2. Explore the Data

```python
# View a sample OKC-SFT entry
sample = okc_train[0]
print("Instruction:", sample['instruction'][:100], "...")
print("Input:", sample['input'][:100], "...")
print("Output:", sample['output'][:200], "...")
print("Task type:", sample['metadata']['task_type'])
print("Scenario:", sample['metadata']['scenario'])
```

### 3. Parse OKC Output

```python
def parse_okc_output(output_text):
    """Parse OKC structured output into dictionary."""
    fields = {}
    current_field = None
    current_content = []
    
    field_markers = {
        'Diagnosis:': 'diagnosis',
        'Evidence:': 'evidence',
        'Possible Causes:': 'causes',
        'Operation Suggestions:': 'operations',
        'Verification Indices:': 'verification',
        'Safety Notes:': 'safety'
    }
    
    for line in output_text.split('\n'):
        matched = False
        for marker, field_name in field_markers.items():
            if line.startswith(marker):
                if current_field:
                    fields[current_field] = '\n'.join(current_content).strip()
                current_field = field_name
                current_content = [line[len(marker):].strip()]
                matched = True
                break
        
        if not matched and current_field:
            current_content.append(line)
    
    if current_field:
        fields[current_field] = '\n'.join(current_content).strip()
    
    return fields

# Example usage
sample = okc_train[0]
parsed = parse_okc_output(sample['output'])

print("=== Parsed OKC Structure ===")
for field, content in parsed.items():
    print(f"{field.capitalize()}: {content[:100]}...")
```

## Training with LLaMA-Factory

### 1. Prepare Data

Copy the data files to your LLaMA-Factory installation:

```bash
# Copy data files
cp data/okc_sft_train.jsonl /path/to/LLaMA-Factory/data/
cp data/qa_sft_train.jsonl /path/to/LLaMA-Factory/data/
```

### 2. Configure Dataset

Add the following to `/path/to/LLaMA-Factory/data/dataset_info.json`:

```json
{
  "okc_sft": {
    "file_name": "okc_sft_train.jsonl",
    "columns": {
      "prompt": "instruction",
      "query": "input",
      "response": "output"
    }
  },
  "qa_sft": {
    "file_name": "qa_sft_train.jsonl",
    "columns": {
      "prompt": "instruction",
      "query": "input",
      "response": "output"
    }
  }
}
```

### 3. Start Training

```bash
# OKC-SFT training
python src/train_bash.py \
    --model_name_or_path Qwen/Qwen2.5-7B-Instruct \
    --dataset okc_sft \
    --finetuning_type lora \
    --lora_rank 16 \
    --lora_alpha 32 \
    --lora_dropout 0.05 \
    --output_dir outputs/okc_sft \
    --per_device_train_batch_size 4 \
    --gradient_accumulation_steps 4 \
    --num_train_epochs 3 \
    --learning_rate 2e-4 \
    --fp16

# QA-SFT training
python src/train_bash.py \
    --model_name_or_path Qwen/Qwen2.5-7B-Instruct \
    --dataset qa_sft \
    --finetuning_type lora \
    --lora_rank 16 \
    --lora_alpha 32 \
    --lora_dropout 0.05 \
    --output_dir outputs/qa_sft \
    --per_device_train_batch_size 4 \
    --gradient_accumulation_steps 4 \
    --num_train_epochs 3 \
    --learning_rate 2e-4 \
    --fp16
```

## Evaluation

### 1. Generate Predictions

```python
import json
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel

def generate_response(model, tokenizer, instruction, input_text=""):
    """Generate response from model."""
    prompt = f"Instruction: {instruction}\nInput: {input_text}\nOutput:"
    inputs = tokenizer(prompt, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=1024,
            temperature=0.7,
            do_sample=True
        )
    
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return response.split("Output:")[-1].strip()

# Load model
base_model = AutoModelForCausalLM.from_pretrained("Qwen/Qwen2.5-7B-Instruct")
model = PeftModel.from_pretrained(base_model, "outputs/okc_sft")
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen2.5-7B-Instruct")

# Generate predictions for test set
predictions = []
for sample in test_set:
    response = generate_response(
        model, 
        tokenizer, 
        sample['instruction'],
        sample.get('input', '')
    )
    predictions.append({
        'sample_id': sample['sample_id'],
        'prediction': response,
        'expected_key_points': sample['expected_key_points']
    })

# Save predictions
with open('predictions.jsonl', 'w', encoding='utf-8') as f:
    for pred in predictions:
        f.write(json.dumps(pred, ensure_ascii=False) + '\n')
```

### 2. Calculate Metrics

```python
def calculate_keypoint_coverage(predictions):
    """Calculate relaxed keypoint coverage."""
    total_covered = 0
    total_keypoints = 0
    
    for pred in predictions:
        response = pred['prediction'].lower()
        keypoints = pred['expected_key_points']
        
        for kp in keypoints:
            total_keypoints += 1
            # Relaxed matching: check if key concepts are present
            kp_words = kp.lower().split()
            if any(word in response for word in kp_words if len(word) > 2):
                total_covered += 1
    
    return total_covered / total_keypoints if total_keypoints > 0 else 0

def check_okc_structure(response):
    """Check if response follows OKC structure."""
    required_fields = ['diagnosis:', 'evidence:', 'possible causes:', 
                      'operation suggestions:', 'verification indices:', 'safety notes:']
    
    response_lower = response.lower()
    present_fields = sum(1 for field in required_fields if field in response_lower)
    
    return present_fields / len(required_fields)

# Calculate metrics
coverage = calculate_keypoint_coverage(predictions)
structure_scores = [check_okc_structure(p['prediction']) for p in predictions]
avg_structure = sum(structure_scores) / len(structure_scores)

print(f"Relaxed Keypoint Coverage: {coverage:.4f}")
print(f"Structural Field Completeness: {avg_structure:.4f}")
```

### 3. Hallucination Detection

```python
def detect_hallucinations(response, valid_parameters):
    """Detect potential hallucinations in response."""
    hallucinations = []
    response_lower = response.lower()
    
    # Check for fabricated parameter values
    import re
    numbers = re.findall(r'\d+\.?\d*', response)
    
    # Check for non-existent equipment names
    valid_equipment = ['空压机', '冷箱', '液氮泵', '粗氩塔', '上塔', '下塔']
    mentioned_equipment = [eq for eq in valid_equipment if eq in response]
    
    # Simple heuristic: if response mentions equipment not in valid list
    # or contains suspiciously specific numbers without context
    # (This is a simplified example - real implementation would be more sophisticated)
    
    return hallucinations

# Example usage
for pred in predictions[:5]:
    hallucinations = detect_hallucinations(pred['prediction'], [])
    if hallucinations:
        print(f"Sample {pred['sample_id']}: {len(hallucinations)} potential hallucinations")
```

## Data Analysis

### 1. Statistical Analysis

```python
import pandas as pd

def analyze_dataset(samples):
    """Analyze dataset statistics."""
    data = []
    for sample in samples:
        meta = sample.get('metadata', sample)
        data.append({
            'task_type': meta.get('task_type', 'unknown'),
            'scenario': meta.get('scenario', 'unknown'),
            'instruction_length': len(sample['instruction']),
            'output_length': len(sample.get('output', ''))
        })
    
    df = pd.DataFrame(data)
    
    print("=== Dataset Statistics ===")
    print(f"Total samples: {len(df)}")
    print(f"\nTask type distribution:")
    print(df['task_type'].value_counts())
    print(f"\nAverage instruction length: {df['instruction_length'].mean():.0f} characters")
    print(f"Average output length: {df['output_length'].mean():.0f} characters")
    
    return df

# Analyze each dataset
print("OKC-SFT Training Set:")
okc_df = analyze_dataset(okc_train)

print("\nQA-SFT Training Set:")
qa_df = analyze_dataset(qa_train)

print("\nTest Set:")
test_df = analyze_dataset(test_set)
```

### 2. Visualization

```python
import matplotlib.pyplot as plt

def plot_task_distribution(df, title):
    """Plot task type distribution."""
    task_counts = df['task_type'].value_counts()
    
    plt.figure(figsize=(10, 6))
    task_counts.plot(kind='bar')
    plt.title(title)
    plt.xlabel('Task Type')
    plt.ylabel('Count')
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig(f'{title.lower().replace(" ", "_")}.png', dpi=150)
    plt.show()

# Plot distributions
plot_task_distribution(okc_df, "OKC-SFT Task Distribution")
plot_task_distribution(qa_df, "QA-SFT Task Distribution")
plot_task_distribution(test_df, "Test Set Task Distribution")
```

## Advanced Usage

### 1. Custom Evaluation Metrics

```python
def evaluate_response_quality(prediction, expected_key_points, reference_answer=None):
    """Comprehensive response quality evaluation."""
    scores = {}
    
    # 1. Keypoint coverage
    pred_lower = prediction.lower()
    covered = sum(1 for kp in expected_key_points 
                  if any(word in pred_lower for word in kp.lower().split() if len(word) > 2))
    scores['keypoint_coverage'] = covered / len(expected_key_points) if expected_key_points else 0
    
    # 2. Structure completeness
    required_fields = ['diagnosis:', 'evidence:', 'possible causes:', 
                      'operation suggestions:', 'verification indices:', 'safety notes:']
    present = sum(1 for field in required_fields if field in pred_lower)
    scores['structure_completeness'] = present / len(required_fields)
    
    # 3. Output length (not too short, not too long)
    length = len(prediction)
    if length < 100:
        scores['length_score'] = 0.5
    elif length > 2000:
        scores['length_score'] = 0.8
    else:
        scores['length_score'] = 1.0
    
    # 4. Overall score (weighted average)
    scores['overall'] = (
        scores['keypoint_coverage'] * 0.4 +
        scores['structure_completeness'] * 0.4 +
        scores['length_score'] * 0.2
    )
    
    return scores

# Evaluate all predictions
evaluation_results = []
for pred in predictions:
    scores = evaluate_response_quality(
        pred['prediction'],
        pred['expected_key_points']
    )
    evaluation_results.append({
        'sample_id': pred['sample_id'],
        **scores
    })

# Summary statistics
eval_df = pd.DataFrame(evaluation_results)
print("\n=== Evaluation Summary ===")
print(eval_df.describe())
```

### 2. Cross-validation

```python
from sklearn.model_selection import KFold

def cross_validate_model(samples, n_folds=5):
    """Perform cross-validation on the dataset."""
    kf = KFold(n_splits=n_folds, shuffle=True, random_state=42)
    
    fold_results = []
    for fold, (train_idx, val_idx) in enumerate(kf.split(samples)):
        train_samples = [samples[i] for i in train_idx]
        val_samples = [samples[i] for i in val_idx]
        
        # Train model on train_samples
        # Evaluate on val_samples
        # Store results
        
        fold_results.append({
            'fold': fold,
            'train_size': len(train_samples),
            'val_size': len(val_samples),
            # ... other metrics
        })
    
    return fold_results
```

## Troubleshooting

### Common Issues

1. **Encoding Error**: Ensure all files are UTF-8 encoded
   ```python
   with open(filepath, 'r', encoding='utf-8') as f:
       data = f.read()
   ```

2. **JSON Parse Error**: Check for malformed JSON lines
   ```python
   import json
   with open(filepath, 'r', encoding='utf-8') as f:
       for i, line in enumerate(f):
           try:
               json.loads(line)
           except json.JSONDecodeError as e:
               print(f"Error on line {i+1}: {e}")
   ```

3. **Memory Issues**: Load data in chunks for large datasets
   ```python
   def load_jsonl_chunked(filepath, chunk_size=1000):
       with open(filepath, 'r', encoding='utf-8') as f:
           chunk = []
           for line in f:
               chunk.append(json.loads(line))
               if len(chunk) >= chunk_size:
                   yield chunk
                   chunk = []
           if chunk:
               yield chunk
   ```

## Contact

For questions or issues, please contact:
- Zhangquan Hu: zju_hzq@163.com
- Jun Zhao: jzhao@zju.edu.cn
- Zuhua Xu: zhxu@zju.edu.cn
