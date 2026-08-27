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