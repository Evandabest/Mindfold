from flask import Flask, jsonify, request
from flask_cors import CORS
import sys
import os

# Add Generators directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'Generators'))

from Netwalkgen import generate_network, build_tiles_from_puzzle
from Shikakugen import generate_shikaku_board
from Starbattlegen import generate_starbattle_1star
from Takuzugen import generate_binary_puzzle, EMPTY

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route('/')
def index():
    """Root endpoint"""
    return jsonify({
        'message': 'Flask server is running',
        'status': 'success'
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy'
    })

@app.route('/api/generate/netwalk', methods=['GET', 'POST'])
def generate_netwalk():
    """Generate a Netwalk/Pipes puzzle"""
    try:
        # Get parameters from request
        if request.method == 'POST':
            data = request.get_json() or {}
        else:
            data = request.args.to_dict()
        
        rows = int(data.get('rows', 6))
        cols = int(data.get('cols', 6))
        seed = int(data.get('seed')) if data.get('seed') else None
        allow_cross = data.get('allow_cross', 'true').lower() == 'true'
        prefer_source_degree = int(data.get('prefer_source_degree_at_least', 2))
        
        # Generate puzzle
        puzzle_masks, solution_masks, rotations, source = generate_network(
            rows, cols,
            seed=seed,
            allow_cross=allow_cross,
            prefer_source_degree_at_least=prefer_source_degree
        )
        
        # Build tiles for easier JSON serialization
        tiles = build_tiles_from_puzzle(puzzle_masks, rotations, source)
        
        # Convert to JSON-serializable format
        puzzle_grid = []
        solution_grid = []
        rotations_grid = []
        tiles_data = []
        
        for r in range(rows):
            puzzle_row = []
            solution_row = []
            rotations_row = []
            tiles_row = []
            for c in range(cols):
                tile = tiles[r][c]
                puzzle_row.append(tile.mask)
                solution_row.append(solution_masks[r][c])
                rotations_row.append(tile.rotation)
                tiles_row.append({
                    'row': tile.row,
                    'col': tile.col,
                    'mask': tile.mask,
                    'rotation': tile.rotation,
                    'openings': list(tile.openings),
                    'degree': tile.degree,
                    'kind': tile.kind,
                    'is_source': tile.is_source,
                    'is_powered': tile.is_powered
                })
            puzzle_grid.append(puzzle_row)
            solution_grid.append(solution_row)
            rotations_grid.append(rotations_row)
            tiles_data.append(tiles_row)
        
        return jsonify({
            'success': True,
            'rows': rows,
            'cols': cols,
            'source': {'row': source[0], 'col': source[1]},
            'puzzle_masks': puzzle_grid,
            'solution_masks': solution_grid,
            'rotations': rotations_grid,
            'tiles': tiles_data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

@app.route('/api/generate/shikaku', methods=['GET', 'POST'])
def generate_shikaku():
    """Generate a Shikaku puzzle"""
    try:
        # Get parameters from request
        if request.method == 'POST':
            data = request.get_json() or {}
        else:
            data = request.args.to_dict()
        
        rows = int(data.get('rows', 8))
        cols = int(data.get('cols', 10))
        target_rects = int(data.get('target_rects')) if data.get('target_rects') else None
        max_rect_area = int(data.get('max_rect_area')) if data.get('max_rect_area') else None
        seed = int(data.get('seed')) if data.get('seed') else None
        
        # Generate puzzle
        board, rects = generate_shikaku_board(
            rows, cols,
            target_rects=target_rects,
            max_rect_area=max_rect_area,
            seed=seed
        )
        
        # Convert rects to JSON-serializable format
        rects_data = [
            {
                'r0': r.r0,
                'c0': r.c0,
                'r1': r.r1,
                'c1': r.c1,
                'h': r.h,
                'w': r.w,
                'area': r.area
            }
            for r in rects
        ]
        
        return jsonify({
            'success': True,
            'rows': rows,
            'cols': cols,
            'board': board,
            'rectangles': rects_data,
            'num_rectangles': len(rects)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

@app.route('/api/generate/starbattle', methods=['GET', 'POST'])
def generate_starbattle():
    """Generate a Star Battle (Kings) puzzle"""
    try:
        # Get parameters from request
        if request.method == 'POST':
            data = request.get_json() or {}
        else:
            data = request.args.to_dict()
        
        n = int(data.get('size', 8))
        ensure_unique = data.get('ensure_unique', 'true').lower() == 'true'
        seed = int(data.get('seed')) if data.get('seed') else None
        max_star_tries = int(data.get('max_star_tries', 2000))
        max_region_tries = int(data.get('max_region_tries_per_star', 200))
        
        # Generate puzzle
        regions, solution_stars = generate_starbattle_1star(
            n,
            ensure_unique=ensure_unique,
            seed=seed,
            max_star_tries=max_star_tries,
            max_region_tries_per_star=max_region_tries
        )
        
        # Convert to JSON-serializable format
        regions_grid = [[int(regions[r][c]) for c in range(n)] for r in range(n)]
        stars_grid = [[bool(solution_stars[r][c]) for c in range(n)] for r in range(n)]
        
        # Find star positions
        star_positions = []
        for r in range(n):
            for c in range(n):
                if solution_stars[r][c]:
                    star_positions.append({'row': r, 'col': c})
        
        return jsonify({
            'success': True,
            'size': n,
            'regions': regions_grid,
            'solution_stars': stars_grid,
            'star_positions': star_positions
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

@app.route('/api/generate/takuzu', methods=['GET', 'POST'])
def generate_takuzu():
    """Generate a Takuzu/Binary puzzle"""
    try:
        # Get parameters from request
        if request.method == 'POST':
            data = request.get_json() or {}
        else:
            data = request.args.to_dict()
        
        n = int(data.get('size', 8))
        givens_ratio = float(data.get('givens_ratio', 0.45))
        ensure_unique = data.get('ensure_unique', 'true').lower() == 'true'
        seed = int(data.get('seed')) if data.get('seed') else None
        max_removal_attempts = int(data.get('max_removal_attempts', 50000))
        
        # Generate puzzle
        puzzle, solution = generate_binary_puzzle(
            n,
            givens_ratio=givens_ratio,
            ensure_unique=ensure_unique,
            seed=seed,
            max_removal_attempts=max_removal_attempts
        )
        
        # Convert EMPTY (-1) to None for cleaner JSON, or keep as -1
        puzzle_grid = [[int(puzzle[r][c]) if puzzle[r][c] != EMPTY else None for c in range(n)] for r in range(n)]
        solution_grid = [[int(solution[r][c]) for c in range(n)] for r in range(n)]
        
        return jsonify({
            'success': True,
            'size': n,
            'puzzle': puzzle_grid,
            'solution': solution_grid,
            'givens_ratio': givens_ratio
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=6000)

