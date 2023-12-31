## Huntit

This is supposed to be a fast WebSec automation tool that I'm developing on the weekends to help with a few things:

- Finds alive subdomains;
- Removes out-of-scope subdomains;
- Takes screenshots of alive hosts;
- Query for waybackurls;
- Finds parameters;
- Parses sitemap.xml of all hosts;
- Generates a custom directory wordlist specific to your target;
- Generates a custom parameter wordlist specific to your target;
- Greps for "XSS" patterns;
- Checks for reflected parameters;
- Greps for "Open Redirect" patterns;
- Generates "Open Redirect" payloads specific to each host;
- Tests for "XSS" vulnerabilities;
- Tests for "Open Redirect" vulnerabilities.

#### Extra Functions (takes longer to run depending on the target):

- Bruteforces Directories/Paths;
- Scan Ports really fast.

## Installation

In the linux shell, navigate to where you cloned the Huntit repository, then run the following command: <br>
```./huntitRequirements.sh -i```

After installation is completed and you change your mind about where the Huntit repository should <br> be kept on your computer, you can update its location on the PATH Environment using the following command: <br>
```./huntitRequirements.sh -p```

## Usage

```
Usage:
   Required: Input the top level domain and your blind payload from https://xsshunter.com
   Optional: Input an out-of-scope subdomain list and an in-scope subdomain list
   Required Syntax: huntit -d tesla.com -b https://blindxss.xss.ht
   Optional Syntax: huntit -d tesla.com -b https://blindxss.xss.ht -ol offScopeList.txt -il inScopeList.txt

Flags:
   -d,  --domain                  string     Add your target top domain            -d tesla.com
   -b,  --blind                   string     Add your xsshunter blind xss file     -b https://yourUserAccount.xss.ht
   -ol, --off-scope               string     Add out of scope subdomains list      -ol offScopeList.txt
   -il, --in-scope                string     Add in scope subdomain list           -il inScopeList.txt
   -u,  --update-requirements                Updates required tools for huntit
   -h,  --help                               Help for huntit
   -v,  --version                            Your current huntit version
```

## Special Thanks

These amazing guys made the third party tools used in this project:

https://github.com/hahwul <br>
https://github.com/tomnomnom <br>
https://github.com/RustScan <br>
https://github.com/ffuf <br>
https://github.com/KathanP19 <br>
https://github.com/projectdiscovery <br>
https://github.com/1ndianl33t <br>
https://github.com/devanshbatham <br>
https://github.com/cujanovic <br>