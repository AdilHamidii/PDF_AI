# PDF AI

A full-stack AI-powered document generation platform. Users describe a document (CV, cover letter, formal letter, etc.) via an iOS app, and a serverless AWS pipeline generates a professional PDF in seconds using Claude AI + LaTeX compilation.

Built as a personal project to explore **cloud engineering**, **serverless architecture**, and **AI integration** in a production-grade pipeline.

---

## Cloud Architecture

```
                            ┌─────────────────────────────────────────────────────────┐
                            │                    AWS Cloud (eu-west-1)                │
                            │                                                         │
┌──────────────┐            │  ┌───────────────┐    ┌──────────────────────────────┐  │
│              │  HTTPS     │  │               │    │     AWS Lambda (Docker)      │  │
│   iOS App    │ POST ──────┼─►│ API Gateway   │───►│                              │  │
│  (SwiftUI)   │ /generate  │  │ (HTTP API)    │    │  ┌────────┐   ┌───────────┐  │  │
│              │            │  │               │    │  │ Claude  │──►│  pdflatex │  │  │
│              │            │  │  - CORS       │    │  │  API    │   │  compiler │  │  │
│              │            │  │  - Auto-deploy│    │  │        │   │           │  │  │
│              │            │  └───────────────┘    │  │ Prompt  │   │ LaTeX ──► │  │  │
│              │            │                       │  │ ──► LaTeX│   │   PDF    │  │  │
│              │            │                       │  └────────┘   └─────┬─────┘  │  │
│              │            │                       │                     │         │  │
│              │            │  ┌───────────────┐    │  ┌────────────────┐ │         │  │
│              │◄───────────┼──│    Amazon S3   │◄───┼──│  Upload PDF   │◄┘         │  │
│  Download    │ presigned  │  │               │    │  └────────────────┘           │  │
│  PDF file    │ URL        │  │  - Lifecycle  │    │                              │  │
│              │            │  │    90-day TTL  │    │  ┌────────────────┐           │  │
└──────────────┘            │  │  - Presigned   │    │  │ SSM Parameter │           │  │
                            │  │    URLs (7d)   │    │  │ Store         │           │  │
                            │  └───────────────┘    │  │ (API key)     │           │  │
                            │                       │  └────────────────┘           │  │
                            │  ┌───────────────┐    └──────────────────────────────┘  │
                            │  │  Amazon ECR   │──── Docker image (Python + TeX Live) │
                            │  └───────────────┘                                      │
                            │                                                         │
                            │  ┌───────────────┐    ┌───────────────┐                 │
                            │  │  CloudWatch   │    │     IAM       │                 │
                            │  │  (Logs)       │    │  (Roles +     │                 │
                            │  │               │    │   Policies)   │                 │
                            │  └───────────────┘    └───────────────┘                 │
                            └─────────────────────────────────────────────────────────┘
```

## Data Flow — End to End

```
1. USER INPUT
   iOS App → User types prompt or fills guided form
   ↓
2. API REQUEST
   POST https://<api-id>.execute-api.eu-west-1.amazonaws.com/prod/generate
   Body: { "prompt": "...", "documentType": "cv", "formData": {...} }
   ↓
3. API GATEWAY
   HTTP API receives request → validates CORS → proxies to Lambda
   ↓
4. LAMBDA EXECUTION (Docker container: Python 3.12 + TeX Live)
   a. Fetch Claude API key from SSM Parameter Store (SecureString, decrypted at runtime)
   b. Call Claude API (claude-sonnet-4-20250514) with system prompt constraining output to raw LaTeX
   c. Post-process response: strip markdown code fences if present
   d. Write LaTeX to temp file → run pdflatex → read compiled PDF bytes
   e. Upload PDF to S3 with unique key (pdfs/<uuid>.pdf)
   f. Generate presigned URL (7-day expiry) for client download
   ↓
5. API RESPONSE
   { "pdfUrl": "<presigned-s3-url>", "pdfKey": "pdfs/<uuid>.pdf", "latex": "..." }
   ↓
6. CLIENT DOWNLOAD
   iOS app downloads PDF from presigned URL → saves to local temp file
   ↓
7. LOCAL PERSISTENCE
   Document metadata (title, type, prompt, PDF URL, LaTeX source) saved to SwiftData
   ↓
8. PDF VIEWER
   QuickLook renders the PDF → user can share, save to Files, regenerate, or delete
```

## AWS Services Used

| Service | Resource | Role in Pipeline | Config Details |
|---------|----------|-----------------|----------------|
| **API Gateway** | `pdfai-api` (HTTP API) | Entry point — receives POST requests from iOS app | CORS enabled, `prod` stage with auto-deploy |
| **Lambda** | `pdfai-generate` | Core compute — runs Claude API call + LaTeX compilation | Docker image, 512MB RAM, 60s timeout, `linux/amd64` |
| **ECR** | `pdfai-lambda` | Container registry — stores the Lambda Docker image | Image: Python 3.12 base + TeX Live packages |
| **S3** | `pdfai-generated-pdfs` | Object storage — stores generated PDF files | Public access blocked, 90-day lifecycle auto-delete |
| **SSM Parameter Store** | `/pdfai/claude-api-key` | Secrets management — encrypted API key storage | `SecureString` type, decrypted at runtime by Lambda |
| **IAM** | `pdfai-lambda-role` | Access control — Lambda execution permissions | Policies: `AWSLambdaBasicExecutionRole` + custom S3 `PutObject`/`GetObject` |
| **CloudWatch** | Auto-configured | Observability — Lambda execution logs | 5GB free tier |

## Lambda Docker Image

The Lambda function requires a custom Docker image because it needs **TeX Live** installed alongside Python to compile LaTeX to PDF.

```dockerfile
FROM public.ecr.aws/lambda/python:3.12

# Install TeX Live (pdflatex + fonts + common packages)
RUN dnf install -y texlive-latex texlive-collection-fontsrecommended \
    texlive-collection-latexrecommended && dnf clean all

# Pre-generate format files (Lambda filesystem is read-only at runtime)
RUN fmtutil-sys --all 2>/dev/null || true

# Redirect writable paths to /tmp (only writable dir in Lambda)
ENV TEXMFVAR=/tmp/texmf-var
ENV TEXMFCONFIG=/tmp/texmf-config
ENV HOME=/tmp

COPY lambda_function.py ${LAMBDA_TASK_ROOT}/
CMD ["lambda_function.handler"]
```

**Key challenges solved:**
- Lambda's root filesystem is **read-only** — TeX Live needs writable paths for temp files, solved by setting `TEXMFVAR` and `TEXMFCONFIG` to `/tmp`
- `pdflatex` format files must be **pre-generated** at build time (`fmtutil-sys --all`) since they can't be created at runtime
- Docker builds must use `--provenance=false` to avoid multi-architecture manifest issues that Lambda rejects

## Lambda Function Logic

```python
handler(event, context)
├── Parse request body (prompt, documentType, formData)
├── get_api_key()
│   └── SSM.get_parameter("/pdfai/claude-api-key", WithDecryption=True)
├── call_claude(api_key, prompt, document_type, form_data)
│   ├── Build system prompt (constrain output to raw LaTeX)
│   ├── Build user message (from prompt or structured form data)
│   ├── POST to https://api.anthropic.com/v1/messages
│   └── Strip code fences from response if present
├── compile_latex(latex_code)
│   ├── Write .tex file to temp directory
│   ├── Run: pdflatex -interaction=nonstopmode document.tex
│   └── Return PDF bytes or compilation error
├── Upload PDF to S3 (pdfs/<uuid>.pdf)
├── Generate presigned URL (7-day expiry)
└── Return { pdfUrl, pdfKey, latex }
```

## IAM Security Model

```
pdfai-lambda-role
├── AWSLambdaBasicExecutionRole (AWS managed)
│   └── CloudWatch Logs: CreateLogGroup, CreateLogStream, PutLogEvents
├── pdfai-s3-access (inline policy)
│   └── s3:PutObject, s3:GetObject on arn:aws:s3:::pdfai-generated-pdfs/*
└── pdfai-ssm-access (inline policy)
    └── ssm:GetParameter on /pdfai/claude-api-key
```

Follows **least-privilege**: Lambda can only read its own API key and write to its own S3 bucket.

## API Reference

### `POST /generate`

**Request:**
```json
{
  "prompt": "Create a professional CV for a data engineer with 3 years of experience",
  "documentType": "cv",
  "formData": {
    "fullName": "Adil Hamidi",
    "email": "adil@example.com",
    "experience": "3 years in data engineering..."
  }
}
```

- `prompt` (string) — Natural language description (used for freeform mode)
- `documentType` (string) — One of: `freeform`, `cv`, `coverLetter`, `letter`, `receipt`, `businessCard`
- `formData` (object) — Structured key-value pairs from guided form (used for template mode)
- At least one of `prompt` or `formData` is required

**Success (200):**
```json
{
  "pdfUrl": "https://pdfai-generated-pdfs.s3.eu-west-1.amazonaws.com/pdfs/550e8400-e29b-41d4-a716-446655440000.pdf?X-Amz-Algorithm=...",
  "pdfKey": "pdfs/550e8400-e29b-41d4-a716-446655440000.pdf",
  "latex": "\\documentclass[11pt,a4paper]{article}\n\\usepackage{geometry}..."
}
```

**Error (400/500):**
```json
{
  "error": "LaTeX compilation failed",
  "details": "! Undefined control sequence...",
  "latex": "\\documentclass{article}..."
}
```

## Infrastructure Provisioning

All AWS resources were provisioned via **AWS CLI** commands. The full setup script is in `aws-setup-commands.sh` and covers:

1. **S3 bucket** — Create bucket, block public access, set 90-day lifecycle policy
2. **IAM role** — Create execution role, attach managed + inline policies
3. **ECR repository** — Create container registry for Lambda image
4. **Lambda function** — Create function from Docker image with environment variables
5. **API Gateway** — Create HTTP API, Lambda integration, route, stage with auto-deploy
6. **SSM Parameter** — Store Claude API key as encrypted SecureString

### Deploy / Update Lambda

```bash
# Authenticate with ECR
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com

# Build, tag, push
cd lambda
docker build --platform linux/amd64 --provenance=false -t pdfai-lambda .
docker tag pdfai-lambda:latest $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/pdfai-lambda:latest
docker push $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/pdfai-lambda:latest

# Update Lambda function
aws lambda update-function-code \
  --function-name pdfai-generate \
  --image-uri $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/pdfai-lambda:latest \
  --region eu-west-1
```

## iOS App

### Tech Stack
- **SwiftUI** (iOS 17+) — Declarative UI framework
- **SwiftData** — Local persistence for users and document history
- **QuickLook** — Native PDF rendering
- **Speech** — Voice-to-text input via `SFSpeechRecognizer`

### App Structure

```
API AI app/
├── App/
│   ├── API_AI_appApp.swift          # Entry point, SwiftData model container
│   └── Config.swift                 # API endpoint URL, feature flags
├── Core/
│   ├── Models/
│   │   ├── UserModel.swift          # @Model: user profile (Apple ID, usage tracking)
│   │   ├── DocumentModel.swift      # @Model: generated documents (title, PDF URL, LaTeX)
│   │   ├── Models.swift             # DocumentType enum (cv, coverLetter, letter, etc.)
│   │   └── FormField.swift          # Form field definitions for guided templates
│   ├── Services/
│   │   └── PDFService.swift         # Async API client — calls Lambda endpoint
│   └── Design/
│       ├── Color+Brand.swift        # Brand palette (lavender theme)
│       └── DesignConstants.swift    # Spacing, corner radii, shadow styles
├── Views/
│   ├── Create/
│   │   ├── CreateBottomSheet.swift  # Freeform prompt + template picker
│   │   ├── StepFormView.swift       # Multi-step guided form wizard
│   │   ├── GeneratingView.swift     # Real-time progress UI + API call
│   │   └── VoiceInputView.swift     # Speech recognition input
│   ├── PDFViewer/
│   │   └── PDFViewerView.swift      # QuickLook PDF preview + share/save/delete
│   ├── Home/
│   │   ├── HomeView.swift           # Dashboard with recent documents
│   │   └── MainTabView.swift        # Tab bar, navigation, sheet management
│   └── ...                          # Onboarding, Search, Account, Sidebar, Notifications
lambda/
├── Dockerfile                       # Python 3.12 + TeX Live for Lambda
└── lambda_function.py               # Handler: Claude API → LaTeX → pdflatex → S3
```

## Free Tier Usage

All AWS resources fit within the **AWS Free Tier**:

| Service | Free Tier Limit | Estimated Usage |
|---------|----------------|-----------------|
| Lambda | 1M requests, 400K GB-sec/month | ~100 requests/month |
| S3 | 5GB storage, 20K GET, 2K PUT | ~500MB (90-day auto-delete) |
| API Gateway | 1M calls/month (12 months) | ~100 calls/month |
| ECR | 500MB storage | ~400MB (single image) |
| SSM | Free (standard params) | 1 parameter |
| CloudWatch | 5GB logs | Minimal |

## Tech Decisions & Trade-offs

| Decision | Why |
|----------|-----|
| **LaTeX over HTML-to-PDF** | LaTeX produces typographically superior documents — proper kerning, ligatures, math support. Worth the added complexity of TeX Live in the Docker image. |
| **Docker Lambda over zip** | TeX Live requires system-level packages (~300MB) that can't be bundled in a standard Lambda zip deployment. Docker images support up to 10GB. |
| **Presigned URLs over direct S3** | No need to expose the S3 bucket publicly. Presigned URLs are time-limited (7 days) and scoped to individual objects. |
| **SSM over environment variables** | API keys should never be in environment variables or code. SSM SecureString provides encryption at rest with KMS. |
| **SwiftData over Core Data** | Modern, declarative persistence that integrates naturally with SwiftUI. Macro-based `@Model` reduces boilerplate. |
| **Single Lambda over Step Functions** | The pipeline is sequential and completes in <60s. Step Functions would add cost and complexity for no benefit at this scale. |

---

*Built by Adil Hamidi*
