require 'json'

def open_file(filename)
  File.open(filename, 'r:UTF-8')
end

def json_disposition_from_file(filename)
  JSON.parse(open_file(filename).read)
end

def erb_template_from_file(filename)
  open_file(filename).read
end
