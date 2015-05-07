# SQLi-Hunter

SQLi-Hunter is a simple HTTP proxy server and a sqlmap api wrapper that makes dig SQLi easily.

## 0x0 Requirement

- Ruby: > 2.0.0
- sqlmap


## 0x1 Installation

```
git clone https://github.com/sqlmapproject/sqlmap.git
git clone https://github.com/zt2/sqli-hunter.git
cd sqli-hunter
gem install bundle
bundle install
```

## 0x2 Usage

```
➜  sqli-hunter git:(master) ruby sqli-hunter.rb 

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|

      sqlmap api wrapper by ztz (ztz@ztz.me)

Usage: sqli-hunter.rb [options]

Common options:
    -p, --port=<PORT>                Port of the Proxy-Server (default is 8888)
        --api-host=<HOST>            Host of the sqlmapapi (default is localhost:8775)
    -s, --save=<SAVE PATH>           Specify the path for request files (default is /tmp)
    -v <VERBOSE>                     Verbosity level: 0-3 (default 1)
        --version                    Show version

sqlmap options
        --technique=<TECH>           SQL injection techniques to use (default "BEUSTQ")
        --threads=<THREADS>          Max number of concurrent HTTP(s) requests (default 5)
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
ruby sqli-hunter.rb -p 8888
```

configure proxy server settings in your browser

```
➜  sqli-hunter git:(master) ruby sqli-hunter.rb -v 2 --dbms=mysql --threads=10 

 _____ _____ __    _     _____         _
|   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
|__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
|_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
         |__|

      sqlmap api wrapper by ztz (ztz@ztz.me)

[00:59:18] Proxy server started... listening on port 8888
[00:59:23] POST http://testphp.vulnweb.com/search.php?test=query HTTP/1.1
[00:59:23] Saving to /private/tmp/96c915d5fe6becf373e2095cfa2da458
[00:59:24] [0d8f471e77a3bd65] Create task
[00:59:24] [0d8f471e77a3bd65] Set options success
[00:59:24] [0d8f471e77a3bd65] Task running
[00:59:27] [0d8f471e77a3bd65] Fetching result
[00:59:27] [0d8f471e77a3bd65] Task vulnerable, use "sqlmap -r /private/tmp/96c915d5fe6becf373e2095cfa2da458" to exploit
[00:59:33] GET http://testphp.vulnweb.com/artists.php HTTP/1.1
[00:59:33] Saving to /private/tmp/1a5669ae3c25b5b952b2667f11d9becc
[00:59:33] [bf9b7e10f9d04559] Create task
[00:59:33] [bf9b7e10f9d04559] Set options success
[00:59:33] [bf9b7e10f9d04559] Task running
[00:59:36] [bf9b7e10f9d04559] Fetching result
[00:59:36] [bf9b7e10f9d04559] All tested parameters appear to be not injectable

```

use `sqlmap -r /private/tmp/96c915d5fe6becf373e2095cfa2da458` to exploit
