# Flask Backend Server

This is the backend server for generating puzzle games (Netwalk, Shikaku, Star Battle, and Takuzu).

## Setup

1. **Create and activate virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## Running the Server

**Option 1: Using the run script**
```bash
./run.sh
```

**Option 2: Manual activation**
```bash
source venv/bin/activate
python3 app.py
```

The server will start on `http://localhost:6000`

## API Endpoints

### Health Check
- `GET /health` - Check if server is running

### Generate Puzzles

All endpoints support both GET (query parameters) and POST (JSON body):

1. **Netwalk/Pipes** - `GET/POST /api/generate/netwalk`
   - Parameters: `rows`, `cols`, `seed`, `allow_cross`, `prefer_source_degree_at_least`
   - Example: `http://localhost:6000/api/generate/netwalk?rows=6&cols=6`

2. **Shikaku** - `GET/POST /api/generate/shikaku`
   - Parameters: `rows`, `cols`, `target_rects`, `max_rect_area`, `seed`
   - Example: `http://localhost:6000/api/generate/shikaku?rows=8&cols=10`

3. **Star Battle/Kings** - `GET/POST /api/generate/starbattle`
   - Parameters: `size`, `ensure_unique`, `seed`, `max_star_tries`, `max_region_tries_per_star`
   - Example: `http://localhost:6000/api/generate/starbattle?size=8`

4. **Takuzu** - `GET/POST /api/generate/takuzu`
   - Parameters: `size`, `givens_ratio`, `ensure_unique`, `seed`, `max_removal_attempts`
   - Example: `http://localhost:6000/api/generate/takuzu?size=8`

## Testing

Visit `http://localhost:6000` in your browser to see the root endpoint response.

Visit `http://localhost:6000/health` to check server health.

## Troubleshooting

If you see "about:blank" in your browser:
1. Make sure the server is actually running (check terminal for Flask output)
2. Check that you're accessing `http://localhost:6000` (not just `localhost:6000`)
3. Verify the server started without errors in the terminal
4. Try accessing `http://127.0.0.1:6000` instead

