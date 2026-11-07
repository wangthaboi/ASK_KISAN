cd backend

python -m app.scripts.migrate_vector_embeddings       # add derived-layer metadata columns once
python -m app.scripts.generate_embeddings --backfill-metadata  # hash existing canonical source content
python -m app.scripts.generate_embeddings --dry-run  # inspect proposed changes
python -m app.scripts.generate_embeddings            # synchronize records and vectors
python -m app.scripts.test_retrieval                 # run representative retrieval checks
python -m app.scripts.test_chat                      # chat with retrieved context
uvicorn app.main:app --reload                        # run the API


cd backend
python -m pip install -r requirements.txt
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000 (WEB)

cd frontend
Copy-Item .env.example .env
npm install
npm run dev

## Docker Deployment

Build the container image:
```bash
docker build -t ask-kisan-backend -f backend/Dockerfile backend
```

Run the container locally:
```bash
docker run -d -p 8000:8000 --env-file backend/.env --name ask-kisan-backend ask-kisan-backend
```

Or run via Docker Compose from the root workspace:
```bash
docker compose up --build
```
