--ask user for .md file name (TO INCLUDE DIRECTORY)
print("enter file name: ")
mdfilename=io.read()
--gsub the user's input to go from dir/[NAME].md to [NAME].html
htmlfilename=string.gsub(mdfilename, "[md,/,.]", "")..".html"

-- write input table t to file with filename f
function printtable(t, f)
  io.output(f)
  for k,v in pairs(t) do
    io.write(v)
    io.write("\n")
  end
  io.output(io.stdout)
end

-- see if the file exists
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then print("file DNE") return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

-- get the length of a table
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


local mdlines = lines_from(mdfilename) --output of the .md file
local hlines = lines_from("blog/blog-template.html") --output of the template html file
local headings = {} --table to store headings
local paragraphs = {} --table to store paragraphs
local title = "" --string to store the title (to be used for main heading and webpage title)
local writelines = {} --output of the combination of the .md file and template html file
local m = 1 --various variables used for counting
local n = 1 
local c = 1 

--loop through all lines in the .md file
for k,v in pairs(mdlines) do
  --use the header "%%" to denote the title, remove the header, and set
  --the "title" variable to that string
  if (string.find(v, "%%")) then
    title = string.gsub(v, "%%", "")
  --do the same thing for the headings and paragraphs, but use the header "# " 
  --and add the output to the header table
  elseif (string.find(v, "# ")) then
    table.insert(headings, mdlines[k])
    table.insert(paragraphs, mdlines[k + 2])
  end
end

--loop through the html template file and replace keywords with respective
--table content
for k,v in pairs(hlines) do
  if (string.find(v, string.format("heading%s",m)) and m <= tablelength(headings)) then
    writelines[k] = string.gsub(headings[m], "# ", "")
    m = m + 1
  elseif (string.find(v, string.format("paragraph%s",n)) and n <= tablelength(paragraphs)) then
    writelines[k] = paragraphs[n]
    n = n + 1
  elseif (string.find(v, "TITLE")) then
    writelines[k] = title
  else
    table.insert(writelines, v)
  end
end

--delete remaining keywords and surrounding html tags
while (c <= 10) do
  for k,v in pairs(writelines) do
    if (string.find(v, string.format("heading%s",c)) or string.find(v, string.format("paragraph%s",c))) then
      print("found!")
      writelines[k-1] = ""
      writelines[k] = ""
      writelines[k+1] = ""
    end
  end
  c = c + 1
end

--print combined .md and .html to a new html file with the same name as the
--.md file!
printtable(writelines,"blog/"..htmlfilename)
