

#This is the maximum number of pages that will get populated with links
max_populated = 10

#Number of lijnks to put on each page
links_per_page = 10

domain = 'file:///home/sdevos/shelob/mock/pages'

#Return the head of the file
def head
	%{
  <head>
    <title>Shelob</title>
  </head>
	}
end

#Generate and return the body of the file
def body start_index, links_per_page, domain
	end_index = start_index + links_per_page
	result = "<body>\n"
	for i in start_index..end_index
		if i % ((rand 25) + 1) == 0
			result += "    <a href=\"/#{i}.html\">#{i}</a>\n"
		else
			result += "    <a href=\"#{domain}/#{i}.html\">#{i}</a>\n"
		end
	end
	result += "  </body>\n"

	result
end

begin
	if !File.directory? "pages"
		`mkdir pages`
	end

	#Start at page 1
	page = 1

	#Links will start at 2
	links = 2

	#Generate populated pages
	while page <= max_populated do 
		f = File.new("pages/#{page}.html", 'w')
		f.write "<html>"
		f.write head
		f.write body links, links_per_page, domain
		f.write '</html>'
		f.close
		links += links_per_page
		page += 1
	end

	#Generate rest of pages (so we don't get 404's)
	while page <= links do
		f = File.new("pages/#{page}.html", 'w')
		f.write "<html>"
		f.write head
		f.write %{
  <body>
    empty
  </body>
}
		f.write '</html>'
		f.close
		page += 1
	end
end