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
➜  sqli-hunter git:(master)  ruby sqli-hunter.rb

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|

          sqlmap api wrapper by ztz

Usage: sqli-hunter.rb [options]

Common options:
    -s, --server                     Act as a Proxy-Server
    -p, --port=<PORT>                Port of the Proxy-Server (default is 8888)
        --api-host=<HOST>            Host of the sqlmapapi (default is localhost:8775)
        --version                    Show version

sqlmap options
        --random-agent               Use randomly selected HTTP User-Agent header value
        --technique=<TECH>           SQL injection techniques to use (default "BEUSTQ")
        --threads=<THREADS>          Max number of concurrent HTTP(s) requests (default 10)
        --dbms=<DBMS>                Force back-end DBMS to this value
        --os=<OS>                    Force back-end DBMS operating system to this value
        --tamper=<TAMPER>            Use given script(s) for tampering injection data
        --level=<LEVEL>              Level of tests to perform (1-5, default 1)
        --risk=<RISK>                Risk of tests to perform (0-3, default 1)
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
➜  sqli-hunter git:(master)  ruby sqli-hunter.rb -s --smart

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|

          sqlmap api wrapper by ztz

[*] Proxy server started... listening on port 8080
[+] Vulnerable: ef412a4bb8a1ed14 requestFile: /tmp/b6a2ac492360ed63de4fbf643839ee4f
[-] 066816d40bd9fcd4: all tested parameters appear to be not injectable
[-] f1420b0f28bcb42f: all tested parameters appear to be not injectable
[+] Vulnerable: 87f339ddf519b082 requestFile: /tmp/d671f7ee08d200a347a52cecf5129b86
```

start sqlmap to exploit it

```
python sqlmap.py -r /tmp/d671f7ee08d200a347a52cecf5129b86
```
