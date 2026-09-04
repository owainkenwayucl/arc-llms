# Notes in configuring LiteLLM

## Qwen + Claude code

Qwen models need system messages to be at the start of a query. Claude Code messes this up. vLLM has fixes for this which means Claude Code -> vLLM works. Unfortunately LiteLLM tries to map `/v1/messages` to `/v1/chat...` and messes this up.

To fix this, add the following JSON to `Model Info` in the UI:

```json
  "supported_endpoints": [
    "/v1/chat/completions",
    "/v1/messages"
  ]
```

### Qwen 3.8 + xhigh

In addition to the above, Qwen 3.8 doesn't support "high" reasoning and LiteLLM likes re-writing "xhigh" to "high". To fix this add the following JSON in addition to the above to `Model Info`:

```json
  "supports_reasoning": true,
  "reasoning_effort_levels": [
    "low",
    "medium",
    "xhigh"
  ]
```
