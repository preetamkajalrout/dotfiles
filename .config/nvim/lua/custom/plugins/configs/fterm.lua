local fterm_present, fterm = pcall(require, "FTerm")
if not fterm_present then
	vim.notify("fterm couldn't be loaded!", "erro", {
		title = "numToStr/FTerm.nvim",
	})
	return
end

fterm.setup({
	border = "rounded",
	dimensions = {
		height = 0.9,
		width = 0.9,
	},
})

local km = vim.keymap.set

-- Keybinding for fterm
local nopts = { silent = true, noremap = true }
local topts = { silent = true, noremap = true }

km("n", "<A-t>", "<cmd>lua require('FTerm').toggle()<CR>", nopts)
km("t", "<A-t>", "<C-\\><C-n><cmd>lua require('FTerm').toggle()<CR>", topts)

-- Custom functions for tools
local fn = vim.fn

--- Strip leading and lagging whitespace
local function trim(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end

local function get_root(cwd)
  local status, job = pcall(require, 'plenary.job')
  if not status then
    return fn.system('git rev-parse --show-toplevel')
  end

  local gitroot_job = job:new({
    'git',
    'rev-parse',
    '--show-toplevel',
    cwd=cwd
  })

  local path, code = gitroot_job:sync()
  if (code ~= 0) then
    return nil
  end

  return table.concat(path, "")
end

--- Get project_root_dir for git repository
local function project_root_dir()
	-- always use bash on Unix based systems.
	local oldshell = vim.o.shell
	if vim.fn.has("win32") == 0 then
		vim.o.shell = "bash"
	end

	local cwd = fn.getcwd() 
	local root = get_root(cwd)
	if root == nil then
		return nil
	end

	local cmd = string.format(
		'cd "%s" && git rev-parse --show-toplevel',
		fn.fnamemodify(fn.resolve(fn.expand("%:p")), ":h"),
		root
	)
	-- try symlinked file location instead
	local gitdir = fn.system(cmd)
	local isgitdir = fn.matchstr(gitdir, "^fatal:.*") == ""

	if isgitdir then
		vim.o.shell = oldshell
		return trim(gitdir)
	end

	-- revert to old shell
	vim.o.shell = oldshell

	local repo_path = fn.getcwd(0, 0)

	-- just return current working directory
	return repo_path
end

local lazygit = fterm:new({
	ft = "fterm_lazygit",
	cmd = "lazygit --path " .. project_root_dir(),
	dimensions = {
		height = 0.9,
		width = 0.9,
	},
})

local pyrepl = fterm:new({
	ft = "fterm_pyrepl",
	cmd = "python",
	dimensions = {
		height = 0.9,
		width = 0.9,
	},
})


local noderepl = fterm:new({
	ft = "fterm_noderepl",
	cmd = "node",
	dimensions = {
		height = 0.9,
		width = 0.9,
	},
})

local top = fterm:new({
	ft = "fterm_btop",
	cmd = "top",
})

km("n", "<A-f>l", function()
	lazygit:toggle()
end)
km("n", "<A-f>b", function()
	top:toggle()
end)
km("n", "<A-f>n", function()
	noderepl:toggle()
end)
km("n", "<A-f>p", function()
	pyrepl:toggle()
end)
