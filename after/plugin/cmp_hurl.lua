local has_cmp, cmp = pcall(require, "cmp")

if not has_cmp or cmp == nil then
	return
end

cmp.register_source("nvim_hurl", require("nvim-hurl.completions").new())
