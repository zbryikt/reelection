// Generated by LiveScript 1.3.0
(function(){
  var fs, fastCsv, repo, files, hash, result, calcrate, loader, finalizer, handler, flist, csvStream;
  fs = require('fs');
  fastCsv = require('fast-csv');
  repo = '/Users/tkirby/workspace/other/kiang/db.cec.gov.tw';
  files = fs.readdirSync(repo + "/elections");
  hash = {};
  files.map(function(it){
    var ret, name, idx;
    ret = /([^-]+)-?(\d+)?\.csv/.exec(it);
    if (!ret) {
      console.log("bug");
    }
    name = ret[1];
    idx = ret[2];
    return (hash[name] || (hash[name] = [])).push(it);
  });
  result = {};
  calcrate = function(item, data, cb){
    var r, rate;
    r = data.map(function(it){
      if (it[8] === "*" && it[9] === "是") {
        return true;
      } else {
        return false;
      }
    });
    rate = parseInt(100 * (r.length / data.length));
    result[item[0]] = {
      date: item[2],
      name: item[1],
      rate: rate
    };
    return cb();
  };
  loader = function(item, cb){
    var files, data, count, i$, len$, f, csvStream, results$ = [];
    files = hash[item[0]];
    data = [];
    count = 0;
    for (i$ = 0, len$ = files.length; i$ < len$; ++i$) {
      f = files[i$];
      results$.push(csvStream = fs.createReadStream(repo + "/elections/" + f).pipe(fastCsv()).on('data', fn$).on('end', fn1$));
    }
    return results$;
    function fn$(d){
      return data.push(d);
    }
    function fn1$(){
      count = count + 1;
      if (count === files.length) {
        return calcrate(item, data, cb);
      }
    }
  };
  finalizer = function(){
    return fs.writeFileSync("result.json", JSON.stringify(result));
  };
  handler = function(){
    var item;
    console.log(flist.length + " remains..");
    if (!flist.length) {
      finalizer();
    }
    item = flist.splice(0, 1)[0];
    return loader(item, function(){
      return handler();
    });
  };
  flist = [];
  csvStream = fs.createReadStream(repo + "/elections.csv").pipe(fastCsv()).on('data', function(data){
    return flist.push(data);
  }).on('end', function(){
    flist.splice(0, 1);
    return handler();
  });
}).call(this);
