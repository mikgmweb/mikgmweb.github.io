print("enter file name: ")
mdfilename=io.read()
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


local mdlines = lines_from(mdfilename)
local hlines = lines_from("blog/blog-template.html")
local headings = {}
local paragraphs = {}
local title = ""
local writelines = {}
local m = 1
local n = 1
local c = 1

for k,v in pairs(mdlines) do
  if (string.find(v, "%%")) then
    title = string.gsub(v, "%%", "")
  elseif (string.find(v, "# ")) then
    table.insert(headings, mdlines[k])
    table.insert(paragraphs, mdlines[k + 2])
  end
end

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

printtable(writelines,"blog/"..htmlfilename)
