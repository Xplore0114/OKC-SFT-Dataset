# OKC-SFT Dataset

**Operation Knowledge Chain Supervised Fine-Tuning Dataset for Air Separation Unit Abnormal Operation Handling**

[English](#english) | [中文](#中文)

---

## English

### Overview

This dataset supports the paper **"Operation Knowledge Chain Supervised Fine-Tuning for Abnormal Operation Handling Instructions in Air Separation Units"** submitted to CAC 2026.

OKC-SFT (Operation Knowledge Chain Supervised Fine-Tuning) is a structured fine-tuning method that organizes operator handling logic into a six-element chain: **Diagnosis, Evidence, Causes, Actions, Verification, and Risk Boundary**. This dataset contains training data and evaluation benchmarks for reproducing the experimental results.

### Dataset Statistics

| Dataset | Samples | Task Types | Description |
|---------|---------|------------|-------------|
| `okc_sft_train.jsonl` | 611 | 6 | OKC-SFT training samples with structured 6-field targets |
| `qa_sft_train.jsonl` | 858 | 7 | QA-SFT baseline training samples (unstructured) |
| `test_set.jsonl` | 61 | 6 | Balanced evaluation set |

### Task Types

| Task Type | OKC-SFT | QA-SFT | Test Set | Description |
|-----------|---------|--------|----------|-------------|
| condition_recognition | 611 | 226 | 10 | Identify abnormal operating conditions |
| cause_analysis | - | 177 | 19 | Analyze root causes of faults |
| operation_recommendation | - | 131 | 15 | Generate operation action suggestions |
| post_operation_verification | - | 124 | 1 | Define verification criteria |
| safety_reminder | - | 119 | 4 | Provide safety warnings |
| tag_interpretation | - | 48 | 12 | Interpret process variables and tags |
| evidence_extraction | - | 33 | - | Extract supporting evidence |

### Data Format

#### OKC-SFT Training Sample

```json
{
  "instruction": "根据当前工况判断...",
  "input": "DCS监测显示...",
  "output": "Diagnosis: ...\nEvidence: ...\nPossible Causes: ...\nOperation Suggestions: ...\nVerification Indices: ...\nSafety Notes: ...",
  "metadata": {
    "task_type": "condition_recognition",
    "scenario": "nitrogen_plugging",
    "sample_id": 1,
    "knowledge_chain_ids": ["OKC001", "OKC004", "OKC010"],
    "source_trace": ["nitrogen_qa_Q1", "knowledge_chain_table"]
  }
}
```

#### QA-SFT Training Sample

```json
{
  "instruction": "请分析...的机理。",
  "input": "",
  "output": "氮塞是空分装置制氩系统运行中的一种典型故障工况...",
  "metadata": {
    "task_type": "cause_analysis",
    "scenario": "nitrogen_plugging",
    "sample_id": 1,
    "source_trace": ["nitrogen_qa_Q1"]
  }
}
```

#### Test Set Sample

```json
{
  "sample_id": "T001",
  "instruction": "请解释AI705在空分装置氮塞诊断中的作用...",
  "input": "",
  "expected_key_points": [
    "AI705表征粗氩纯度/粗氩氧含量，正常值≥99.9%",
    "持续下降是氮塞最核心的预警信号"
  ],
  "task_type": "tag_interpretation",
  "scenario": "nitrogen_plugging",
  "source_trace": ["nitrogen_qa_Q1", "nitrogen_qa_Q2"]
}
```

### OKC Structure Fields

The OKC (Operation Knowledge Chain) structure consists of six elements:

| Field | Description |
|-------|-------------|
| **Diagnosis** | Identifies the abnormal state and its severity |
| **Evidence** | Provides process variables, equipment states, or measurements supporting the judgment |
| **Causes** | Explains the causal mechanism and possible fault sources |
| **Operation Suggestions** | Specifies executable operating steps |
| **Verification Indices** | Defines post-action monitoring variables and recovery criteria |
| **Safety Notes** | Specifies conditions for stopping, slowing down, or escalating |

### Raw Materials

The `raw_materials/` directory contains:

- `scenarios.json`: Three representative abnormal operation scenarios
- `reference_answers.json`: Expert-validated reference answers with safety constraints
- `kg_evidence.json`: Knowledge graph entities, relations, and reasoning paths
- `scoring_rubric.json`: Evaluation criteria and scoring scale

### Usage

#### Quick Start

```python
import json

# Load OKC-SFT training data
with open('data/okc_sft_train.jsonl', 'r', encoding='utf-8') as f:
    okc_samples = [json.loads(line) for line in f]

# Load test set
with open('data/test_set.jsonl', 'r', encoding='utf-8') as f:
    test_samples = [json.loads(line) for line in f]

print(f"OKC-SFT samples: {len(okc_samples)}")
print(f"Test samples: {len(test_samples)}")
```

#### For LLaMA-Factory

The JSONL files can be directly used with [LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory) for fine-tuning:

```bash
# Copy data files to LLaMA-Factory data directory
cp data/okc_sft_train.jsonl /path/to/LLaMA-Factory/data/

# Add to dataset_info.json
{
  "okc_sft": {
    "file_name": "okc_sft_train.jsonl",
    "columns": {
      "prompt": "instruction",
      "query": "input",
      "response": "output"
    }
  }
}
```

### Citation

If you use this dataset, please cite:

```bibtex
@inproceedings{hu2026okcsft,
  title={Operation Knowledge Chain Supervised Fine-Tuning for Abnormal Operation Handling Instructions in Air Separation Units},
  author={Hu, Zhangquan and Zhao, Jun and Xu, Zuhua},
  booktitle={Proceedings of the Chinese Automation Congress (CAC)},
  year={2026}
}
```

### License

This dataset is licensed under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

### Contact

- Zhangquan Hu: zju_hzq@163.com
- Jun Zhao: jzhao@zju.edu.cn
- Zuhua Xu: zhxu@zju.edu.cn

---

## 中文

### 概述

本数据集支撑论文 **"面向空分装置异常操作处置指令的操作知识链监督微调"**（投稿至 CAC 2026）。

OKC-SFT（操作知识链监督微调）是一种结构化微调方法，将操作人员的处置逻辑组织为六元素链：**诊断、证据、原因、操作、验证和风险边界**。本数据集包含训练数据和评估基准，用于复现实验结果。

### 数据集统计

| 数据集 | 样本数 | 任务类型 | 说明 |
|--------|--------|----------|------|
| `okc_sft_train.jsonl` | 611 | 6 | OKC-SFT 训练样本，含结构化六字段目标 |
| `qa_sft_train.jsonl` | 858 | 7 | QA-SFT 基线训练样本（非结构化） |
| `test_set.jsonl` | 61 | 6 | 均衡评估集 |

### 任务类型

| 任务类型 | OKC-SFT | QA-SFT | 测试集 | 说明 |
|----------|---------|--------|--------|------|
| condition_recognition | 611 | 226 | 10 | 工况识别 |
| cause_analysis | - | 177 | 19 | 原因分析 |
| operation_recommendation | - | 131 | 15 | 操作建议生成 |
| post_operation_verification | - | 124 | 1 | 操作后验证 |
| safety_reminder | - | 119 | 4 | 安全提示 |
| tag_interpretation | - | 48 | 12 | 工艺变量解读 |
| evidence_extraction | - | 33 | - | 证据提取 |

### 数据格式

详见 [data_format.md](docs/data_format.md)。

### OKC 结构字段

OKC（操作知识链）结构由六个元素组成：

| 字段 | 说明 |
|------|------|
| **Diagnosis（诊断）** | 识别异常状态及其严重程度 |
| **Evidence（证据）** | 提供支撑判断的过程变量、设备状态或测量值 |
| **Possible Causes（原因）** | 解释因果机制和可能的故障来源 |
| **Operation Suggestions（操作）** | 规定可执行的操作步骤 |
| **Verification Indices（验证）** | 定义操作后的监控变量和恢复标准 |
| **Safety Notes（风险边界）** | 规定应停止、放缓或升级处置的条件 |

### 原始材料

`raw_materials/` 目录包含：

- `scenarios.json`：三个代表性异常操作场景
- `reference_answers.json`：专家验证的参考答案（含安全约束）
- `kg_evidence.json`：知识图谱实体、关系和推理路径
- `scoring_rubric.json`：评估标准和评分量表

### 使用方法

#### 快速开始

```python
import json

# 加载 OKC-SFT 训练数据
with open('data/okc_sft_train.jsonl', 'r', encoding='utf-8') as f:
    okc_samples = [json.loads(line) for line in f]

# 加载测试集
with open('data/test_set.jsonl', 'r', encoding='utf-8') as f:
    test_samples = [json.loads(line) for line in f]

print(f"OKC-SFT 样本数: {len(okc_samples)}")
print(f"测试集样本数: {len(test_samples)}")
```

#### 用于 LLaMA-Factory

JSONL 文件可直接用于 [LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory) 进行微调：

```bash
# 将数据文件复制到 LLaMA-Factory 数据目录
cp data/okc_sft_train.jsonl /path/to/LLaMA-Factory/data/

# 添加到 dataset_info.json
{
  "okc_sft": {
    "file_name": "okc_sft_train.jsonl",
    "columns": {
      "prompt": "instruction",
      "query": "input",
      "response": "output"
    }
  }
}
```

### 引用

如果使用本数据集，请引用：

```bibtex
@inproceedings{hu2026okcsft,
  title={面向空分装置异常操作处置指令的操作知识链监督微调},
  author={胡章权 and 赵军 and 徐祖华},
  booktitle={中国自动化大会 (CAC)},
  year={2026}
}
```

### 许可证

本数据集采用 [知识共享署名 4.0 国际许可协议 (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)。

### 联系方式

- 胡章权：zju_hzq@163.com
- 赵军：jzhao@zju.edu.cn
- 徐祖华：zhxu@zju.edu.cn
