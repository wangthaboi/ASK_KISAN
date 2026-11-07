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

---

## AWS EC2 & Supabase Deployment (WhatsApp Bot)

### 1. Supabase Setup
1. Create a project in [Supabase](https://supabase.com).
2. Open the **SQL Editor** in Supabase and execute [`database/supabase_schema.sql`](file:///Users/synkee/Documents/ASK_KISAN/database/supabase_schema.sql).
3. Under **Project Settings -> Database -> Connection string**, copy the URI (choose Transaction Pooler or Direct connection).

### 2. EC2 Free-Tier Setup (t2.micro / t3.micro Ubuntu 24.04 LTS)
1. Launch instance:
   - Security Group: Allow inbound Port 22 (SSH), Port 80 (HTTP), Port 443 (HTTPS).
   - Elastic IP: Associate a static Elastic IP to your instance.
2. SSH into instance and configure a 2GB swap file to prevent memory exhaustion:
   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```
3. Install system dependencies:
   ```bash
   sudo apt update && sudo apt install -y python3-pip python3-venv git nginx certbot python3-certbot-nginx
   ```
4. Clone develop branch and set up environment:
   ```bash
   git clone -b develop https://github.com/wangthaboi/ASK_KISAN.git /home/ubuntu/ASK_KISAN
   cd /home/ubuntu/ASK_KISAN/backend
   python3 -m venv venv
   source venv/bin/activate
   pip install --upgrade pip
   pip install -r requirements.txt
   ```
5. Configure `.env` in `backend/.env`:
   ```ini
   DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[REF].supabase.co:5432/postgres
   OPENAI_API_KEY=<your-openai-api-key>
   CHAT_MODEL=gpt-4.1-mini
   EMBEDDING_MODEL=text-embedding-3-small

   # WhatsApp Cloud API
   WHATSAPP_TOKEN=<your-meta-access-token>
   WHATSAPP_PHONE_NUMBER_ID=<your-meta-phone-number-id>
   WHATSAPP_VERIFY_TOKEN=<your-chosen-verify-token>
   WHATSAPP_APP_SECRET=<your-meta-app-secret>
   ```
6. Run as a systemd service (`/etc/systemd/system/askkisan.service`):
   ```ini
   [Unit]
   Description=ASK KISAN FastAPI WhatsApp Backend
   After=network.target

   [Service]
   User=ubuntu
   WorkingDirectory=/home/ubuntu/ASK_KISAN/backend
   ExecStart=/home/ubuntu/ASK_KISAN/backend/venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
   Restart=always
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```
   Enable and start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable askkisan
   sudo systemctl start askkisan
   ```
7. Configure Nginx reverse proxy with Let's Encrypt SSL (`/etc/nginx/sites-available/askkisan`):
   ```nginx
   server {
       server_name bot.yourdomain.com;

       location / {
           proxy_pass http://127.0.0.1:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```
   Issue SSL certificate:
   ```bash
   sudo ln -s /etc/nginx/sites-available/askkisan /etc/nginx/sites-enabled/
   sudo rm -f /etc/nginx/sites-enabled/default
   sudo nginx -t
   sudo systemctl restart nginx
   sudo certbot --nginx -d bot.yourdomain.com
   ```
8. Register webhook in Meta App Dashboard:
   - **Callback URL**: `https://bot.yourdomain.com/whatsapp/webhook`
   - **Verify Token**: `<your-chosen-verify-token>`
   - Subscribe to the **`messages`** webhook field.

---

## Docker Container Deployment

The backend includes a production-grade multi-stage Dockerfile (`backend/Dockerfile`) with non-root security execution, built-in healthcheck, and dynamic port binding.

### 1. Build the Docker Image
From the repository root:
```bash
docker build -t ask-kisan-backend -f backend/Dockerfile backend
```

### 2. Run the Container
```bash
docker run -d \
  --name ask-kisan-backend \
  -p 8000:8000 \
  --env-file backend/.env \
  --restart unless-stopped \
  ask-kisan-backend
```

### 3. Run with Docker Compose
```bash
docker compose up -d --build
```

Healthcheck status can be monitored with:
```bash
docker inspect --format='{{json .State.Health.Status}}' ask-kisan-backend
```
