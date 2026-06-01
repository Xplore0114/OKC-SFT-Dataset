# Dataset Statistics Summary

## Overview

This document provides detailed statistics for the OKC-SFT Dataset.

## Dataset Files

| File | Samples | Size (KB) | Description |
|------|---------|-----------|-------------|
| `okc_sft_train.jsonl` | 611 | 2,003.2 | OKC-SFT training samples |
| `qa_sft_train.jsonl` | 858 | 696.3 | QA-SFT baseline training samples |
| `test_set.jsonl` | 61 | 37.2 | Balanced evaluation test set |
| **Total** | **1,530** | **2,736.7** | |

## Task Type Distribution

### OKC-SFT Training Set (611 samples)

| Task Type | Count | Percentage |
|-----------|-------|------------|
| condition_recognition | 611 | 100.0% |

### QA-SFT Training Set (858 samples)

| Task Type | Count | Percentage |
|-----------|-------|------------|
| condition_recognition | 226 | 26.3% |
| cause_analysis | 177 | 20.6% |
| operation_recommendation | 131 | 15.3% |
| post_operation_verification | 124 | 14.5% |
| safety_reminder | 119 | 13.9% |
| tag_interpretation | 48 | 5.6% |
| evidence_extraction | 33 | 3.8% |

### Test Set (61 samples)

| Task Type | Count | Percentage |
|-----------|-------|------------|
| cause_analysis | 19 | 31.1% |
| operation_recommendation | 15 | 24.6% |
| tag_interpretation | 12 | 19.7% |
| condition_recognition | 10 | 16.4% |
| safety_reminder | 4 | 6.6% |
| post_operation_verification | 1 | 1.6% |

## Scenario Distribution

All samples in all datasets are from the **nitrogen_plugging** scenario (氮塞场景).

## OKC Structure Fields

The OKC (Operation Knowledge Chain) structure consists of six elements:

| Field | Chinese Name | Description |
|-------|--------------|-------------|
| Diagnosis | 诊断 | Abnormal state identification and severity assessment |
| Evidence | 证据 | Process variables, equipment states, measurements |
| Possible Causes | 原因 | Causal mechanisms and fault sources |
| Operation Suggestions | 操作 | Executable operating steps |
| Verification Indices | 验证 | Post-action monitoring and recovery criteria |
| Safety Notes | 风险边界 | Stop/slowdown/escalation conditions |

## Sample Length Statistics

### OKC-SFT Training Set

- **Instruction length**: ~50-200 characters
- **Input length**: ~30-150 characters
- **Output length**: ~300-800 characters (6 structured fields)

### QA-SFT Training Set

- **Instruction length**: ~30-100 characters
- **Input length**: 0 characters (empty)
- **Output length**: ~200-600 characters (unstructured)

### Test Set

- **Instruction length**: ~50-150 characters
- **Input length**: 0 characters (empty)
- **Expected key points**: 2-5 items per sample

## Knowledge Chain IDs

The OKC-SFT training samples reference the following knowledge chain IDs:

- OKC001: Basic nitrogen plugging diagnosis
- OKC004: Evidence collection for nitrogen plugging
- OKC010: Operation actions for nitrogen plugging
- (and others)

## Source Traces

All samples include source trace information for reproducibility:

- `nitrogen_qa_Q1` to `nitrogen_qa_QN`: Original QA pairs
- `knowledge_chain_table`: Knowledge chain reference table
- `expert_experience`: Expert experience documentation
- `operating_procedure`: Standard operating procedures

## Data Quality

### Validation Checks

- ✅ All JSONL files are valid JSON
- ✅ All required fields are present
- ✅ No duplicate sample IDs
- ✅ Consistent task type labels
- ✅ UTF-8 encoding throughout

### Quality Control Process

1. **Expert Review**: Domain experts reviewed all samples for factual correctness
2. **Field Completeness**: All OKC fields must be non-empty
3. **Operational Feasibility**: Actions must be executable in real ASU operations
4. **Safety Verification**: Risk boundaries must be clearly defined

## Comparison with Paper Results

The dataset statistics match the experimental setup described in the paper:

| Metric | Paper | Dataset |
|--------|-------|---------|
| OKC-SFT training samples | 611 | 611 ✅ |
| QA-SFT training samples | 858 | 858 ✅ |
| Test set size | 90 | 61 (subset) ⚠️ |
| Task types | 6 | 6 ✅ |
| Scenario | nitrogen_plugging | nitrogen_plugging ✅ |

**Note**: The test set in this repository contains 61 samples, while the paper reports 90 samples. The additional 29 samples may be from a separate validation or extended test set.

## Usage Statistics

### For Training

- **Recommended split**: Use `okc_sft_train.jsonl` for OKC-SFT, `qa_sft_train.jsonl` for QA-SFT baseline
- **Batch size**: 4-8 samples per batch
- **Epochs**: 3-5 epochs recommended

### For Evaluation

- **Test set**: Use `test_set.jsonl` for all evaluations
- **Metrics**: Structural field completeness, keypoint coverage, hallucination rate
- **Evaluation method**: Automated metrics + LLM-as-a-Judge

## Citation

If you use this dataset, please cite:

```bibtex
@inproceedings{hu2026okcsft,
  title={Operation Knowledge Chain Supervised Fine-Tuning for Abnormal Operation Handling Instructions in Air Separation Units},
  author={Hu, Zhangquan and Zhao, Jun and Xu, Zuhua},
  booktitle={Proceedings of the Chinese Automation Congress (CAC)},
  year={2026}
}
```

## License

This dataset is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Contact

For questions or issues:
- Zhangquan Hu: zju_hzq@163.com
- Jun Zhao: jzhao@zju.edu.cn
- Zuhua Xu: zhxu@zju.edu.cn
