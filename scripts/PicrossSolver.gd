extends Node
class_name PicrossSolver

func simpleLeftMost(seq, line):
	var blocks = [];
	var last_block_end = 0;

	var loop_continue = false
	var first_loop = true
	while first_loop or loop_continue:
		first_loop = false
		loop_continue = false
		for i in range(seq.size()):
			var placed = false;
			for j in range(last_block_end,line.size() + 1):
				# check if the ith block can be placed at idx i
				# i.e (1) it doesn't overlap a blank cell
				# and (2) it doesn't have painted cells immediately before or after the block
	
				var end = j + seq[i];
	
				# checking (1)
				var overlaps_blank = false
				for state in line.slice(j, end):
					if state == PicrossTypes.CellState.blank:
						overlaps_blank = true
						break
	
				# checking (2)
				var next_to_painted_cell = false
				if (j != 0 && line[j - 1] == PicrossTypes.CellState.painted ||
					end < line.size() && line[end] == PicrossTypes.CellState.painted):
					next_to_painted_cell = true
	
				if (!(overlaps_blank || next_to_painted_cell)):
					# a valid position has been found
					blocks.push_back(PicrossTypes.BlockPosition.new(j,seq[i]))
	
					last_block_end = end + 1;
					placed = true;
					loop_continue = true
					break
					
			if loop_continue:
				break
	
			if (!placed):
				return null;
				# throw new Error(`Could not find a valid position for block ${i + 1} of length ${seq[i]}`);

	return blocks;

func rightMostUnassignedBlock(blocks, line) -> PicrossTypes.BlockPosition:
	var length = 0
	var end = 0

	var i = line.size()
	while i >= 0:
		if (line[i] == PicrossTypes.CellState.painted):
			# check if any block covers this cell
			var test_some = false
			for b in blocks:
				if i >= b.start && i < b.start + b.length:
					test_some = true
					break
			if (! test_some):
				if (length == 0):
					end = i;

				length += 1;
		elif (length != 0):
			return PicrossTypes.BlockPosition.new(end + 1 - length,length)
		i -= 1

	if (length != 0):
		return PicrossTypes.BlockPosition.new(end + 1 - length, length)

	return null;

func isLineValid(blocks, line) -> bool:
	for block in blocks:
		var end = block.start + block.length;

		var overlaps_blank = false
		for state in line.slice(block.start, end):
			if (state == PicrossTypes.CellState.blank):
				overlaps_blank = true
				break

		if (overlaps_blank): return false;

		var next_to_painted_cell = false
		if (block.start != 0 && line[block.start - 1] == PicrossTypes.CellState.painted ||
			end < line.size() && line[end] == PicrossTypes.CellState.painted):
			next_to_painted_cell = true

		if (next_to_painted_cell): return false;

	return true;

func leftMost(seq, line):
	var blocks = simpleLeftMost(seq, line);
	if (blocks == null): return null;

	var rightmost_unassigned = rightMostUnassignedBlock(blocks, line)

	while (rightmost_unassigned != null):
		# get the rightmost block to the left of the unassigned block
		var block_idx = null

		var i = blocks.size()
		while i >= 0:
			if (blocks[i].start < rightmost_unassigned.start):
				block_idx = i;
				break;
			i -= 1

		if (block_idx == null):
			return null;

		var block = blocks[block_idx];

		# move the block so that its right edge overlaps the unassigned block
		var offset = (rightmost_unassigned.start + rightmost_unassigned.length) - (block.start + block.length);

		block.start += offset;
		var shifts = 0;

		while (shifts != (block.length - rightmost_unassigned.length) &&
			   block.start + block.length < line.size() &&
			   ! isLineValid(blocks, line)):
			block.start += 1;
			shifts += 1;

		if (!isLineValid(blocks, line)):
			# if we get here then there is no valid way to overlap this block and the unassigned block

			if (block_idx > 0):
				# get the block to the left of the one we just tried
				i = block_idx - 1
				while i >= 0:
					block = blocks[i];
					# move the block so that its right edge overlaps the unassigned block
					offset = (rightmost_unassigned.start + rightmost_unassigned.len) - (block.start + block.len);

					block.start += offset;
					shifts = 0;

					while (!isLineValid([block], line) &&
						   block.start + block.len < line.length &&
						   shifts != (block.len - rightmost_unassigned.len)):
						block.start += 1;
						shifts += 1;

					if (isLineValid([block], line)):
						# reposition all blocks to the right of this block
						if (i != blocks.size() - 1):
							var seq2 = []
							for b in blocks.slice(i + 1):
								seq2.append(b.length);
							var offset2 = block.start + block.length + 1;
							var new_pos = leftMost(seq2, line.slice(offset2));

							if (new_pos == null): return null;

							var j = i+1
							var c = 0
							while j < blocks.size():
								new_pos[c].start += offset2;
								blocks[j] = new_pos[c];
								j += 1
								c += 1

						break;
					i -= 1
		rightmost_unassigned = rightMostUnassignedBlock(blocks, line)

	return blocks;

func rightMost(seq, line):
	var lm = leftMost(Utils.reverse(seq), Utils.reverse(line));
	if (lm == null): return null;

	var blocks = Utils.reverse(lm);

	# reverse the solution
	for block in blocks:
		block.start = line.size() - (block.start + block.length);

	return blocks;

func __block_start_sort(a,b):
	return a.start - b.start < 0

func generateLine(blocks, line):
	var result = line.duplicate()

	var sorted_blocks = blocks.duplicate()
	sorted_blocks.sort_custom(self,'__block_start_sort')
	for idx in range(sorted_blocks.size()):
		var block = sorted_blocks[idx]
		var i = block.start
		while i < block.start + block.length:
			result[i] = -(idx + 1);
			i += 1

	return result;

func lineSolveSequence(seq, line) -> PicrossTypes.LineInfo:

	# handle simple cases first

	if (seq.size() == 1):
		# empty line
		if (seq[0] == 0):
			return PicrossTypes.LineInfo.new([],[PicrossTypes.BlockPosition.new(0,line.size())])

		# filled line
		if (seq[0] == line.size()):
			return PicrossTypes.LineInfo.new([PicrossTypes.BlockPosition.new(0,line.size())],[])

	# general case

	var lm_blocks = leftMost(seq, line);
	var rm_blocks = rightMost(seq, line);

	if (lm_blocks == null || rm_blocks == null): return null;

	var lm = generateLine(leftMost(seq, line), line);
	var rm = generateLine(rightMost(seq, line), line);

	var blocks = [];
	var in_block = false;
	var current_block = PicrossTypes.BlockPosition.new(0,0)

	for i in range(line.size()):
		if (lm[i] < 0 && rm[i] < 0 && lm[i] == rm[i]):
			if (in_block):
				current_block.length += 1;
			else:
				current_block.start = i;
				current_block.length = 1;
				in_block = true;
		elif (in_block): # end of current block
			in_block = false;
			blocks.push_back(current_block.duplicate());

	if (in_block):
		blocks.push_back(current_block.duplicate());

	return PicrossTypes.LineInfo.new(blocks,findBlanks(rm_blocks, lm_blocks, line.size()))

func findBlanks(rm_blocks, lm_blocks, line_len: int):
	if (lm_blocks == null || rm_blocks == null): return null;

	var block_ranges = []
	for i in range(rm_blocks.size()):
		var b = rm_blocks[i];
		var lm_start = lm_blocks[i].start;
		block_ranges.append(PicrossTypes.BlockPosition.new(lm_start,(b.start + b.length) - lm_start))

	var blanks = [];# BlockPosition[]
	var in_blank = false;
	var current_blank = PicrossTypes.BlockPosition.new(0,0)

	for i in range(line_len):
		var every_res = true
		for b in block_ranges:
			every_res = every_res && (i < b.start) || i >= (b.start + b.length)
		if (every_res):
			if (in_blank):
				current_blank.length+= 1;
			else:
				current_blank.start = i;
				current_blank.length = 1;
				in_blank = true;
		elif (in_blank): # end of current block
			in_blank = false;
			blanks.push_back(current_blank.duplicate());

	if (in_blank):
		blanks.push_back(current_blank.duplicate());

	return blanks;

func blocksIntersection(a: PicrossTypes.BlockPosition, b: PicrossTypes.BlockPosition) -> PicrossTypes.BlockPosition:
	# make sure that b.start >= a.start
	# [a, b] = [a, b].sort((a, b) => a.start - b.start);

	if (a.start > b.start):
		var temp = a
		a = b
		b = temp

	if (a.start + a.length > b.start):
		return PicrossTypes.BlockPosition.new(b.start,int(min((a.start + a.length) - b.start, b.length)))

	return null;

func lineIntersections(a: PicrossTypes.LineInfo, b: PicrossTypes.LineInfo) -> PicrossTypes.LineInfo:
	var blocks = [];# BlockPosition[]
	var blanks = [];# BlockPosition[]

	for i in range(a.blocks.size()):
		for j in range(b.blocks.size()):
			var block_inter = blocksIntersection(a.blocks[i], b.blocks[j]);
			if (block_inter != null):
				blocks.push_back(block_inter);

	for i in range(a.blanks.size()):
		for j in range(b.blanks.size()):
			var blank_inter = blocksIntersection(a.blanks[i], b.blanks[j]);
			if (blank_inter != null):
				blanks.push_back(blank_inter);

	return PicrossTypes.LineInfo.new(blocks, blanks);

func lineSolveCircle(sum: int, state) -> PicrossTypes.LineInfo:
	var lineInfo = null

	for n in range(1,sum):
		var line = lineSolveSequence([n, sum - n], state);
		if (line != null):
			if (lineInfo != null):
				lineInfo = lineIntersections(line, lineInfo);
			else:
				lineInfo = line;

			if (lineInfo == null || (lineInfo.blocks.size() == 0 && lineInfo.blanks.size() == 0)):
				return null;

	return lineInfo;

func lineSolveRectangle(sum: int, state) -> PicrossTypes.LineInfo:
	var lineInfo = null# LineInfo

	for comp in Utils.compositions(sum):
		if (comp.size() >= 3):
			var line = lineSolveSequence(comp, state);
			if (line != null):
				if (lineInfo != null):
					lineInfo = lineIntersections(line, lineInfo);
				else:
					lineInfo = line;

				if (lineInfo == null || (lineInfo.blocks.size() == 0 && lineInfo.blanks.size() == 0)):
					return null;

	return lineInfo;

func lineSolve(hint, state) -> PicrossTypes.LineInfo:
	if (hint == null):
		return null;

	match (hint.type):
		PicrossPuzzle.HintType.simple:
			return lineSolveSequence([hint.num], state);

		PicrossPuzzle.HintType.circle:
			return lineSolveCircle(hint.num, state);

		PicrossPuzzle.HintType.square:
			return lineSolveRectangle(hint.num, state);

	return null;

func isLineSolved(line) -> bool:
	var every = true
	for cell in line:
		every = every && cell != PicrossTypes.CellState.unknown
	return every

# bruteforce
func bruteForceSolve(puzzle) -> PicrossShape:
	puzzle.restart();
	var shape = puzzle.shape;

	var remaining_lines = [
		Utils.make_2d_array(shape.dims[1], shape.dims[2], true),
		Utils.make_2d_array(shape.dims[0], shape.dims[2], true),
		Utils.make_2d_array(shape.dims[0], shape.dims[1], true)
	];

	var incomlete_lines_count = [
		shape.dims[1] * shape.dims[2],
		shape.dims[0] * shape.dims[2],
		shape.dims[0] * shape.dims[1]
	];

	var changed = true;

	while (changed):
		changed = false;
		for d in range(3):
			if (incomlete_lines_count[d] != 0):
				for x in range(puzzle.shape.dims[PuzzleGenerator.coord_x[d]]):
					for y in range(puzzle.shape.dims[PuzzleGenerator.coord_y[d]]):
						if (remaining_lines[d][x][y]):
							var state = shape.getLine(x, y, d);
							if (isLineSolved(state)):
								remaining_lines[d][x][y] = false;
								incomlete_lines_count[d] -= 1;
							else:
								var info = lineSolve(puzzle.getLineHint(x, y, d), state);
								if (info != null):
									changed = shape.setLine(x, y, d, info) || changed;

	if (incomlete_lines_count[0] > 0 &&
		incomlete_lines_count[1] > 0 &&
		incomlete_lines_count[2] > 0):
		return null; # not line solvable

	return shape;

#func countHints(hints: LineHint[][][]) {
#	let count = 0;
#
#	for (let i = 0; i < hints.length; i+= 1) {
#		const h1 = hints[i];
#		for (let j = 0; j < h1.length; j+= 1) {
#			const h2 = hints[i][j];
#			for (let k = 0; k < h2.length; k+= 1) {
#				if (h2[k] != null) {
#					count+= 1;
#				}
#			}
#		}
#	}
#
#	return count;
#	# return hints.flat(2).filter(h => h != null).length;
#}
#
#func getHintsInfo(puzzle: PicrossPuzzle): InfoLineCoords[] {
#	const hint_info: InfoLineCoords[] = [];
#	let idx = 0;
#
#	for (let d: LineDirection = 0; d < 3; d+= 1) {
#		for (let x = 0; x < puzzle.shape.dims[coord_x[d]]; x+= 1) {
#			for (let y = 0; y < puzzle.shape.dims[coord_y[d]]; y+= 1) {
#				const hint = puzzle.getLineHint(x, y, d);
#				if (hint != null) {
#					hint_info.push({ x, y, d, idx, hint });
#				}
#				idx+= 1;
#			}
#		}
#	}
#
#	return hint_info;
#}
#
#func hierarchicalSolve(
#	puzzle: PicrossPuzzle
#): PicrossShape {
#
#	puzzle.restart();
#	const shape = puzzle.shape;
#
#	const scorer = (a: InfoLineCoords, b: InfoLineCoords) =>
#		(a.hint.num == 0 ? Infinity : (a.hint.num) / shape.dims[a.d]) -
#		(b.hint.num == 0 ? Infinity : (b.hint.num / shape.dims[a.d]))
#
#	const queue = new QueuedSet<InfoLineCoords, number>(({ idx }) => idx);
#	queue.add(...getHintsInfo(puzzle).sort(scorer));
#
#	const solved_lines = new Set<number>();
#	const nb_hints_to_solve = countHints(puzzle.hints);
#
#	const coords = [];
#
#	while (!queue.empty()) {
#		const { x, y, d, idx, hint } = queue.pop();
#		const state = shape.getLine(x, y, d);
#		const info = lineSolve(hint, state);
#
#		if (info) {
#			const changed = shape.setLine(x, y, d, info);
#			const new_state = shape.getLine(x, y, d);
#
#			if (isLineSolved(new_state)) {
#				solved_lines.add(idx);
#			}
#
#			if (changed) {
#				coords[coord_x[d]] = x;
#				coords[coord_y[d]] = y;
#
#				const perp_lines = [];
#
#				# Add perpendicular cells to the queue
#				for (coords[d] = 0; coords[d] < state.length; coords[d]+= 1) {
#					if (new_state[coords[d]] != state[coords[d]]) {
#						perp_lines.push(...PuzzleGenerator.getConnectedLines({
#							i: coords[0],
#							j: coords[1],
#							k: coords[2]
#						},
#							shape.dims
#						));
#					}
#				}
#
#				queue.add(...perp_lines
#					.map(({ x, y, d, idx }) => ({ x, y, d, idx, hint: puzzle.getLineHint(x, y, d) }))
#					.filter(({ idx, hint }) => !solved_lines.has(idx) && hint != null)
#					.sort(scorer)
#				);
#			}
#		}
#	}
#
#	if (solved_lines.size != nb_hints_to_solve) {
#		return null; # puzzle is not line solvable
#	}
#
#	return shape;
#}
#
#func removeHints(
#	puzzle: PicrossPuzzle,
#	max_fails = 100,
#	score_func: HintScorer = lineSolveHintScorer2
#): void {
#	const hints = puzzle.hints;
#	const scores: number[][][] = [];
#
#	# assign a score to each hint
#	for (let d: LineDirection = 0; d < 3; d+= 1) {
#		scores.push([]);
#		for (let x = 0; x < puzzle.shape.dims[coord_x[d]]; x+= 1) {
#			scores[d].push([]);
#			for (let y = 0; y < puzzle.shape.dims[coord_y[d]]; y+= 1) {
#				scores[d][x][y] = score_func(hints[d][x][y], x, y, d, puzzle.shape);
#			}
#		}
#	}
#
#	# take the top scoring hint
#	# test if the puzzle is linesolvable without it
#	# if it is remove it, else test next best scoring hint
#	let fails = 0;
#	while (fails < max_fails) {
#		const { x, y, z, value } = max3d(scores);
#
#		if (value == -Infinity) break;
#
#		const hint_copy = { ...hints[x][y][z] };
#
#		hints[x][y][z] = null;
#		# make sure this hint won't be selected in the future
#		scores[x][y][z] = -Infinity;
#
#		if (!puzzle.isSolvable()) {
#			# restore hint
#			hints[x][y][z] = hint_copy;
#			fails+= 1;
#		} else {
#			fails = 0;
#		}
#	}
#}
#
#func removeHintsHierarchical(
#	puzzle: PicrossPuzzle,
#	difficulty: PuzzleDifficulty = PuzzleDifficulty.hard
#): InfoLineCoords[] {
#	const shape = puzzle.shape;
#
#	let scorer: (a: InfoLineCoords, b: InfoLineCoords) => number;
#
#	if (difficulty == PuzzleDifficulty.hard) {
#		scorer = (a: InfoLineCoords, b: InfoLineCoords) =>
#			(a.hint.num == 0 ? Infinity : (a.hint.num) / shape.dims[a.d]) -
#			(b.hint.num == 0 ? Infinity : (b.hint.num / shape.dims[b.d]));
#	} else {
#		scorer = (a: InfoLineCoords, b: InfoLineCoords) =>
#			(b.hint.num == 0 ? Infinity : (b.hint.num / shape.dims[b.d])) -
#			(a.hint.num == 0 ? Infinity : (a.hint.num) / shape.dims[a.d]);
#	}
#
#	const solved_lines = new Set<number>();
#	const removed_hints: InfoLineCoords[] = [];
#
#	const coords = [];
#
#	const starters = new QueuedSet<InfoLineCoords>(
#		({ idx }) => idx,
#		...PuzzleGenerator.getInformativeHints(puzzle)
#			.sort(scorer)
#	);
#
#	while (!starters.empty()) {
#		const { x, y, d, idx, hint } = starters.pop();
#		const state = shape.getLine(x, y, d);
#		const info = lineSolve(hint, state);
#
#		const hint_copy = { ...hint };
#
#		puzzle.hints[d][x][y] = null;
#
#		const edit_hist_copy = { ...shape.editHistory };
#
#		if (!puzzle.isSolvable()) {
#			# restore hint
#			puzzle.hints[d][x][y] = hint_copy;
#			shape.editHistory = edit_hist_copy;
#			continue;
#		}
#
#		removed_hints.push({ x, y, d, idx, hint });
#		shape.editHistory = edit_hist_copy;
#
#		if (info) {
#			const changed = shape.setLine(x, y, d, info);
#			const new_state = shape.getLine(x, y, d);
#
#			if (isLineSolved(new_state)) {
#				solved_lines.add(idx);
#			}
#
#			if (changed) {
#				coords[coord_x[d]] = x;
#				coords[coord_y[d]] = y;
#
#				const perp_lines = [];
#
#				# Add perpendicular cells to the queue
#				for (coords[d] = 0; coords[d] < state.length; coords[d]+= 1) {
#					if (new_state[coords[d]] != state[coords[d]]) {
#						perp_lines.push(...PuzzleGenerator.getConnectedLines({
#							i: coords[0],
#							j: coords[1],
#							k: coords[2]
#						},
#							shape.dims
#						));
#					}
#				}
#
#				# add perpendicuar starters
#				starters.add(...perp_lines
#					.map(({ x, y, d, idx }) => ({ x, y, d, idx, hint: puzzle.getLineHint(x, y, d) }))
#					.filter(({ idx, hint, x, y, d }) => {
#						if (!solved_lines.has(idx) && hint != null) {
#							const info = lineSolve(hint, shape.getLine(x, y, d));
#							return info != null && (info.blanks.length != 0 || info.blocks.length != 0);
#						}
#
#						return false;
#					})
#					.sort(scorer)
#				);
#			}
#		}
#	}
#
#	for (const { x, y, d } of removed_hints) {
#		puzzle.hints[d][x][y] = null;
#	}
#
#	return removed_hints;
