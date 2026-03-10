"""
PDF AI Lambda — generates LaTeX via Claude API, compiles to PDF, stores in S3.
"""

import json
import os
import subprocess
import tempfile
import uuid
import urllib.request
import boto3

s3 = boto3.client("s3")
ssm = boto3.client("ssm")

BUCKET = os.environ.get("S3_BUCKET", "pdfai-generated-pdfs")
CLAUDE_MODEL = "claude-sonnet-4-20250514"


def get_api_key():
    resp = ssm.get_parameter(Name="/pdfai/claude-api-key", WithDecryption=True)
    return resp["Parameter"]["Value"]


def call_claude(api_key, prompt, document_type, form_data=None):
    """Call Claude API to generate LaTeX code."""

    system_prompt = (
        "You are a LaTeX document generator. You ONLY output valid, compilable LaTeX code. "
        "Do not include any explanation, markdown, or code fences. Output raw LaTeX only. "
        "Use standard packages: geometry, fontenc, inputenc, hyperref, enumitem, titlesec, fancyhdr. "
        "The document must compile with pdflatex in a single pass."
    )

    if form_data:
        user_msg = (
            f"Generate a professional {document_type} PDF using LaTeX.\n\n"
            f"Form data:\n{json.dumps(form_data, indent=2)}\n\n"
            "Create a clean, modern, professional layout."
        )
    else:
        user_msg = (
            f"Generate a professional {document_type} PDF using LaTeX.\n\n"
            f"User request: {prompt}\n\n"
            "Create a clean, modern, professional layout."
        )

    body = json.dumps({
        "model": CLAUDE_MODEL,
        "max_tokens": 4096,
        "system": system_prompt,
        "messages": [{"role": "user", "content": user_msg}],
    }).encode()

    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=body,
        headers={
            "Content-Type": "application/json",
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
        },
        method="POST",
    )

    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())

    latex_code = data["content"][0]["text"]

    # Strip code fences if Claude adds them despite instructions
    if latex_code.startswith("```"):
        lines = latex_code.split("\n")
        lines = lines[1:]  # remove opening fence
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        latex_code = "\n".join(lines)

    return latex_code


def compile_latex(latex_code):
    """Compile LaTeX to PDF using pdflatex."""
    with tempfile.TemporaryDirectory() as tmpdir:
        tex_path = os.path.join(tmpdir, "document.tex")
        pdf_path = os.path.join(tmpdir, "document.pdf")

        with open(tex_path, "w") as f:
            f.write(latex_code)

        result = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", "-output-directory", tmpdir, tex_path],
            capture_output=True,
            text=True,
            timeout=30,
        )

        if not os.path.exists(pdf_path):
            return None, result.stdout + "\n" + result.stderr

        with open(pdf_path, "rb") as f:
            return f.read(), None


def handler(event, context):
    """Lambda entry point."""
    try:
        # Parse request
        body = json.loads(event.get("body", "{}"))
        prompt = body.get("prompt", "")
        document_type = body.get("documentType", "freeform")
        form_data = body.get("formData")

        if not prompt and not form_data:
            return response(400, {"error": "prompt or formData is required"})

        # Get API key
        api_key = get_api_key()

        # Generate LaTeX
        latex_code = call_claude(api_key, prompt, document_type, form_data)

        # Compile to PDF
        pdf_bytes, compile_error = compile_latex(latex_code)

        if pdf_bytes is None:
            return response(500, {
                "error": "LaTeX compilation failed",
                "details": compile_error[:1000] if compile_error else "Unknown error",
                "latex": latex_code[:2000],
            })

        # Upload to S3
        pdf_key = f"pdfs/{uuid.uuid4()}.pdf"
        s3.put_object(
            Bucket=BUCKET,
            Key=pdf_key,
            Body=pdf_bytes,
            ContentType="application/pdf",
        )

        # Generate presigned URL (valid 7 days)
        presigned_url = s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": BUCKET, "Key": pdf_key},
            ExpiresIn=604800,
        )

        return response(200, {
            "pdfUrl": presigned_url,
            "pdfKey": pdf_key,
            "latex": latex_code,
        })

    except Exception as e:
        return response(500, {"error": str(e)})


def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(body),
    }
