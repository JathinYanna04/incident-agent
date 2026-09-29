# Autonomous Incident Triage Agent

RAG + PostgreSQL checkpointing + Human-in-the-Loop approval, built on a zero-cost stack
(Gemini via Google AI Studio, Supabase pgvector, LangGraph, Render).

## Setup

1. **Get credentials**
   - Google AI Studio API key: https://aistudio.google.com/ → Get API key
   - Supabase project + pooler connection string (port 6543, Transaction mode):
     https://supabase.com/ → project → Connect → Connection pooler

2. **Configure `.env`**

   Edit `.env` in this folder and fill in your real values:
   ```env
   GEMINI_API_KEY="your_gemini_api_key_here"
   DATABASE_URL="postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?sslmode=require"
   ```
   `.env` is already gitignored — never commit it.

3. **Create the database schema**

   In the Supabase SQL Editor, run `schema.sql` (enables pgvector, creates
   `incident_docs` table and the `match_incident_docs` RPC).

4. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

5. **Seed the knowledge base** (one-time)
   ```bash
   python seed_rag.py
   ```

6. **Run locally**
   ```bash
   python app.py
   ```
   - UI: http://localhost:7860
   - REST docs: http://localhost:7860/docs

## REST API

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| POST | `/chat` | `thread_id`, `message` | `COMPLETED` or `AWAITING_APPROVAL` |
| POST | `/approve` | `thread_id`, `approved`, `rejection_reason?` | `RESOLVED` or `REJECTED_AND_RESUMED` |

## Deploying to Render

1. Push this folder to a GitHub repo (`.env` stays out — confirm it's not in `git status`).
2. Render dashboard → New → Web Service → connect the repo.
3. Settings:
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn app:app --host 0.0.0.0 --port $PORT`
   - Instance Type: Free
4. Environment variables: `GEMINI_API_KEY`, `DATABASE_URL`, `PYTHON_VERSION=3.11.9`
5. Deploy. App will be live at `https://<service-name>.onrender.com/`.

Free Render instances spin down after ~15 min idle; incident state survives restarts
because LangGraph's checkpointer persists to Supabase Postgres.
