# Tasks

## 1. Health Check

- [x] 1.1 Add `GET /healthz` to `app.py` returning a static success response with no external
      calls; verify with `curl` returning 200 with no dependency on Gemini/Postgres being
      reachable

## 2. Secrets Hygiene

- [x] 2.1 Confirm `.env` is listed in `.gitignore` and absent from tracked files; verify with
      `git ls-files | grep .env` returning nothing

## 3. Deploy

- [x] 3.1 Push the repository to GitHub; verify the push succeeds and `.env` is not present in
      the remote repository's file listing
- [x] 3.2 Create a Render free web service with build command
      `pip install -r requirements.txt`, start command
      `uvicorn app:app --host 0.0.0.0 --port $PORT`, and `GEMINI_API_KEY`, `DATABASE_URL`,
      `PYTHON_VERSION` set; verify the deploy reaches `status: live`
- [x] 3.3 Smoke-test the deployed `/`, `/docs`, `/healthz`, `/chat`, and `/approve` endpoints;
      verify each returns the expected status/content
- [x] 3.4 Document deployment steps and free-tier cold-start behavior in `README.md`; verify
      by following the documented steps produce the same result independently
