begin
	if File.directory? "pages"
		`rm -rf pages`
	end
end