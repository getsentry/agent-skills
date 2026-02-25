---
name: sentry-python-setup
description: Setup Sentry in Python apps. Use when asked to add Sentry to Python, install sentry-sdk, or configure error monitoring, profiling, or logging for Python applications, Django, Flask, FastAPI.
license: Apache-2.0
---

# Sentry Python Setup

Install and configure Sentry in Python projects.

## Invoke This Skill When

- User asks to "add Sentry to Python" or "install Sentry" in a Python app
- User wants error monitoring, logging, or tracing in Python
- User mentions "sentry-sdk" or Python frameworks (Django, Flask, FastAPI)

**Important:** The configuration options and code samples below are examples. Always verify against [docs.sentry.io](https://docs.sentry.io) before implementing, as APIs and defaults may have changed.

## Install

```bash
pip install sentry-sdk
```

## Configure

Initialize as early as possible in your application:

```python
import sentry_sdk

sentry_sdk.init(
    dsn="YOUR_SENTRY_DSN",
    send_default_pii=True,
    
    # Tracing
    traces_sample_rate=1.0,
    
    # Profiling
    profile_session_sample_rate=1.0,
    profile_lifecycle="trace",
    
    # Logs
    enable_logs=True,
)
```

### Async Applications

For async apps, initialize inside an async function:

```python
import asyncio
import sentry_sdk

async def main():
    sentry_sdk.init(
        dsn="YOUR_SENTRY_DSN",
        send_default_pii=True,
        traces_sample_rate=1.0,
        enable_logs=True,
    )
    # ... rest of app

asyncio.run(main())
```

## Framework Integrations

Use the same `sentry_sdk.init()` call shown above. Place it where it runs before your app starts:

| Framework | Where to Init | Notes |
|-----------|--------------|-------|
| **Django** | Top of `settings.py` | Auto-detects Django, no extra install |
| **Flask** | Before `app = Flask(__name__)` | Auto-detects Flask |
| **FastAPI** | Before `app = FastAPI()` | Auto-detects FastAPI |
| **Celery** | In Celery worker config | Auto-detects Celery |
| **AIOHTTP** | Before app creation | Auto-detects AIOHTTP |

## Configuration Options

| Option | Description | Default | Min SDK |
|--------|-------------|---------|---------|
| `dsn` | Sentry DSN | `None` (SDK no-ops without it) | — |
| `send_default_pii` | Include user data | `None` | — |
| `traces_sample_rate` | % of transactions traced | `None` (tracing disabled) | — |
| `profile_session_sample_rate` | % of sessions profiled | `None` (profiling disabled) | 2.24.1+ |
| `profile_lifecycle` | Profiling mode (`"trace"` or `"manual"`) | `"manual"` | 2.24.1+ |
| `enable_logs` | Send logs to Sentry | `False` | 2.35.0+ |
| `environment` | Environment name | `"production"` (or `SENTRY_ENVIRONMENT` env var) | — |
| `release` | Release version | Auto-detected | — |

## Environment Variables

The SDK auto-reads these:

```bash
SENTRY_DSN=https://xxx@o123.ingest.sentry.io/456
SENTRY_ENVIRONMENT=production
SENTRY_RELEASE=1.0.0
```

For `sentry-cli` (source maps, releases), also set:

```bash
SENTRY_AUTH_TOKEN=sntrys_xxx
SENTRY_ORG=my-org
SENTRY_PROJECT=my-project
```

Or pass DSN in code:

```python
import os
import sentry_sdk

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN"),
    # ...
)
```

## Verification

```python
# Intentional error to test
division_by_zero = 1 / 0
```

Or capture manually:

```python
sentry_sdk.capture_message("Test message from Python")
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Errors not appearing | Ensure `init()` is called early, check DSN |
| No traces | Set `traces_sample_rate` > 0 |
| IPython errors not captured | Run from file, not interactive shell |
| Async errors missing | Initialize inside async function |
