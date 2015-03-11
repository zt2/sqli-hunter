# SQLi-Hunter
===

SQLi-Hunter is a simple HTTP proxy server and a sqlmap api wrapper that makes dig SQLi easily.

## Requirement
---

```
Ruby > 2.0.0
sqlmap
```

## Installation
---

install `sqlmap`

```
git clone https://github.com/sqlmapproject/sqlmap.git
```

clone this project

install gems

```
cd sqli-hunter
gem install bundle
bundle install
```

## Usage
---

```
➜  sqli-hunter git:(master) ruby sqli-hunter.rb 

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|


Usage: sqli-hunter.rb [options]

Common options:
    -s, --server                     Act as a Proxy-Server
    -p, --port=<PORT>                Port of the Proxy-Server (default is 8888)
        --api-host=<HOST>            Host of the sqlmapapi (default is localhost:8775)
        --version                    Show version

SQLMap options
        --random-agent               Use randomly selected HTTP User-Agent header value
        --threads=<THREADS>          Max number of concurrent HTTP(s) requests (default 10)
        --dbms=<DBMS>                Force back-end DBMS to this value
        --os=<OS>                    Force back-end DBMS operating system to this value
        --tamper=<TAMPER>            Use given script(s) for tampering injection data
        --level=<LEVEL>              Level of tests to perform (1-5, default 1)
        --risk=<RISK>                Risk of tests to perform (0-3, default 1)
        --batch                      Never ask for user input, use the default behaviour
        --mobile                     Imitate smartphone through HTTP User-Agent header
        --smart                      Conduct through tests only if positive heuristic(s)
```

start sqlmap api

```
python sqlmapapi.py -s
```

start sqli-hunter proxy server

```
ruby sqli-hunter.rb -s -p 8888
```

configure proxy server settings in your browser

```
~/Code/SQLi-Hunter(master) ruby sqli-hunter.rb -s -p 8888
[2015-01-08 17:17:27] INFO  WEBrick 1.3.1
[2015-01-08 17:17:27] INFO  ruby 2.1.3 (2014-09-19) [x86_64-linux]
[2015-01-08 17:17:27] INFO  WEBrick::HTTPProxyServer#start: pid=9533 port=8888
192.168.3.98 - - [08/Jan/2015:17:17:31 HKT] "GET http://testphp.vulnweb.com/artists.php?artist=1 HTTP/1.1" 200 5384
- -> http://testphp.vulnweb.com/artists.php?artist=1
[+] Vulnerable: e2f84b1494893827 requestFile: /tmp/c94863efe7bf03459aea27877426dada
```

start sqlmap to exploit it

```
python sqlmap.py -r /tmp/c94863efe7bf03459aea27877426dada
```