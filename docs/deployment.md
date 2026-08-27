# Deployment

## Architecture

Deploy the Vite frontend to Vercel and the FastAPI backend to Render:

```text
Browser -> Vercel frontend -> Render /query -> MySQL and OpenAI
```

The frontend sends `POST /query` to the URL in `VITE_API_URL`. The backend has
no inbound webhook endpoints.

## Render

The root-level `render.yaml` defines the web service. If configuring Render
manually, use:

- Root directory: `backend`
- Build command: `pip install -r requirements.txt`
- Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`

Set `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`,
`OPENAI_API_KEY`, and `CORS_ORIGINS` as Render environment variables. Set
`CORS_ORIGINS` to the deployed Vercel origin, without a trailing slash. Add a
second comma-separated origin if a custom frontend domain is used.

Verify the service at `https://<render-service>.onrender.com/health`.

## Vercel

Create a Vercel project with `frontend/` as its root directory. Vercel detects
Vite automatically; the build command is `npm run build` and the output
directory is `dist`.

Set this production environment variable in Vercel:

```text
VITE_API_URL=https://<render-service>.onrender.com
```

Redeploy after changing it because Vite embeds `VITE_*` variables at build
time. No Vercel serverless API route is required.

## Local development

The backend defaults to `http://localhost:5173` and
`http://127.0.0.1:5173` for CORS. The frontend defaults to
`http://localhost:8000` through `frontend/.env.example`.

Run the services from their respective directories:

```text
cd backend
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

cd frontend
npm install
npm run dev
```