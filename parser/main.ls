require! <[fs fast-csv]>

repo = '/Users/tkirby/workspace/other/kiang/db.cec.gov.tw'

files = fs.readdir-sync "#{repo}/elections"
hash = {}
files.map ->
  ret = /([^-]+)-?(\d+)?\.csv/.exec it
  if !ret => console.log "bug"
  name = ret.1
  idx = ret.2
  if !idx => hash.[][name].push it
result = {}

calcrate = (item,data,cb)->
  data.splice(0,1)
  area = {}
  data.map -> area[it.0] = 1
  count = [a for a of area].length
  r = data.filter -> if it.8 == "*" and it.9 == "是" => true else false
  console.log item.0, r.length, count, data.length
  rate = parseInt(100 * (r.length / count))
  result[item.0] = {date: item.2, name: item.1, rate: rate}
  cb!

loader = (item, cb) ->
  files = hash[item.0]
  data = []
  count = 0
  for f in files
    csv-stream = fs.createReadStream "#repo/elections/#f" .pipe(fast-csv!)
      .on \data, (d) -> data.push d
      .on \end, ->
        count := count + 1
        if count == files.length => calcrate item, data, cb

finalizer = ->
  ks = [k for k of result]
  for k in ks
    n = result[k].name
    if /議員/.exec result[k].name => result[k].type = "議員"
    else if /直轄市長/.exec n => result[k].type = "直轄市長"
    else if /縣市長/.exec n => result[k].type = "縣市長"
    else if /鄉鎮市長/.exec n => result[k].type = "鄉鎮市長"
    else if /省議員/.exec n => result[k].type = "省議員"
    else if /省長/.exec n => result[k].type = "省長"
    else if /里長/.exec n => result[k].type = "里長"
    else if /民代/.exec n => result[k].type = "民代"
    else if /國大代表/.exec n => result[k].type = "國大代表"
    else if /總統/.exec n => result[k].type = "總統"
    else if /立委/.exec(n) or /立法委員/.exec(n) => result[k].type = "立委"
    else console.log result[k].name
  toremove = <[立委 議員 國大代表 總統 民代 省長]>
  for k in ks
    if result[k].type in toremove  => delete result[k]
  fs.write-file-sync "result.json", JSON.stringify(result)
handler = ->
  console.log "#{flist.length} remains.."
  if !flist.length => return finalizer!
  item = flist.splice(0,1).0
  loader item, -> handler!


exclude = <[20050501R1A9 20080101T4A2 20120101T4A2]>

flist = []
csv-stream = fs.createReadStream "#repo/elections.csv" .pipe(fast-csv!)
  .on \data, (data) -> flist.push data
  .on \end, -> 
    flist.splice(0,1)
    flist := flist.filter -> !(it in exclude)
    handler!
