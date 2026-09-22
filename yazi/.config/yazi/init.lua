require("git"):setup {
	order = 1500,
}

-- Z jumps with zoxide; this records each directory while navigating.
require("zoxide"):setup {
	update_db = true,
}
