# SQLi-Hunter

SQLi-Hunter is a simple HTTP proxy server and a sqlmap api wrapper that makes dig SQLi easily.

## 0x0 Requirement

- Ruby
- SQLMAP

## 0x1 Installation

```
git clone https://github.com/sqlmapproject/sqlmap.git
git clone https://github.com/zt2/sqli-hunter.git
cd sqli-hunter
gem install bundler
bundler install
```

## 0x2 Usage

```
➜  sqli-hunter git:(master) ruby bin/sqli-hunter.rb 

  _____ _____ __    _     _____         _
  |   __|     |  |  |_|___|  |  |_ _ ___| |_ ___ ___
  |__   |  |  |  |__| |___|     | | |   |  _| -_|  _|
  |_____|__  _|_____|_|   |__|__|___|_|_|_| |___|_|
  |__|

      SQLMAP API wrapper by ztz (github.com/zt2)

  Usage: bin/sqli-hunter.rb [options]

Common options:
    -h, --host=[HOST]                Bind host for proxy server (default is localhost)
    -p, --port=<PORT>                Bind port for proxy server (default is 8080)
        --sqlmap-host=[HOST]         Host for sqlmap api (default is localhost)
        --sqlmap-port=[PORT]         Port for sqlmap api (default is 8775)
        --targeted-hosts=[HOSTS]     Targeted hosts split by comma (default is all)
        --version                    Display version

SQLMAP options
        --technique=[TECH]           SQL injection techniques to use (default "BEUSTQ")
        --threads=[THREADS]          Max number of concurrent HTTP(s) requests (default 5)
        --dbms=[DBMS]                Force back-end DBMS to this value
        --os=[OS]                    Force back-end DBMS operating system to this value
        --tamper=[TAMPER]            Use given script(s) for tampering injection data
        --level=[LEVEL]              Level of tests to perform (1-5, default 1)
        --risk=[RISK]                Risk of tests to perform (0-3, default 1)
        --mobile                     Imitate smartphone through HTTP User-Agent header
        --smart                      Conduct through tests only if positive heuristic(s)
        --random-agent               Use randomly selected HTTP User-Agent header value
```

start sqlmap api

```
python sqlmapapi.py -s
```

run sqli-hunter

```
ruby bin/sqli-hunter.rb
```

configure proxy server settings in your browser

```
➜  sqli-hunter git:(master) ruby bin/sqli-hunter.rb --targeted-hosts=demo.aisec.cn --threads=15 --random-agent --smart
  [01:50:17] [INFO] [bdf9f3495bb70fbc] task created
  [01:50:17] [INFO] [bdf9f3495bb70fbc] task started
  [01:50:20] [INFO] [bdf9f3495bb70fbc] task finished
  [01:50:20][SUCCESS] [bdf9f3495bb70fbc] task vulnerable, use 'sqlmap -r /var/folders/kb/rwf8j7051x71q4flc_s39wzm0000gn/T/d20191021-40013-17a62ve/5f8a3ad452a15777219b8a5c8c7ec3b6' to exploit
```
