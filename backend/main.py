from io import BytesIO
from typing import List
import json
import os
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
from dotenv import load_dotenv
from PyPDF2 import PdfReader

# Load API key
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY", "")
if not API_KEY:
    raise RuntimeError("Missing GEMINI_API_KEY in environment")
genai.configure(api_key=API_KEY)

app = FastAPI()

# Allow Flutter to access API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def _extract_text(file: UploadFile) -> str:
    mime = (file.content_type or "").lower()
    filename = (file.filename or "").lower()
    file.file.seek(0)
    if mime == "application/pdf" or filename.endswith(".pdf"):
        data = file.file.read()
        reader = PdfReader(BytesIO(data))
        return "\n".join((page.extract_text() or "") for page in reader.pages)
    # Fallback to utf-8 text
    data = file.file.read()
    try:
        return data.decode("utf-8", errors="ignore")
    except Exception:
        return ""

def _build_prompt(doc_text: str) -> str:
    doc_text = (doc_text or "").strip()
    if not doc_text:
        raise HTTPException(status_code=400, detail="Could not extract text from file")
    # Trim to avoid prompt overflow
    if len(doc_text) > 20000:
        doc_text = doc_text[:20000]
    return f''' 
You are an assistant that creates multiple-choice quizzes.
From the following study material, create 5 questions:
- 4 options per question (A–D)
- Exactly one correct answer
- Keep questions concise and relevant

Return JSON only with this schema:
[
  {{
    "question": "string",
    "options": ["A","B","C","D"],
    "answer": "A"
  }}
]

Material:
"""{doc_text}"""
'''

@app.post("/generate_quiz")
async def generate_quiz(file: UploadFile = File(...)):
    try:
        text = _extract_text(file)
        prompt = _build_prompt(text)
        model = genai.GenerativeModel("gemini-1.5-flash-latest")
        resp = model.generate_content(prompt)

        output = (resp.text or "").strip()
        if not output:
            raise HTTPException(status_code=502, detail="Empty response from model")

        cleaned = output
        if cleaned.startswith("```"):
            cleaned = cleaned.strip("`")
            cleaned = cleaned.split("\n", 1)[1] if "\n" in cleaned else cleaned
            if cleaned.lower().startswith("json"):
                cleaned = cleaned[4:].lstrip()

        quiz = json.loads(cleaned)
        if not isinstance(quiz, list):
            raise ValueError("Model did not return a JSON list")

        return {"quiz": quiz}
    except json.JSONDecodeError:
        return {"quiz": None, "raw": output}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
