require! <[fs]>

data = JSON.parse(fs.read-file-sync \result.json .toString!)
data = [[k,v] for k,v of data]
data = data.map ->
  it.1.file = k
  it.1
data.sort (a,b) -> if a.date > b.date => 1 else -1
data.map ->
  console.log "#{it.date},#{it.type},#{it.rate}"
