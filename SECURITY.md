# Reporting Vulnerabilities

Vulnerabilities discovered in WebTreeView can be reported on 
github.com/ThalesGroup/WebTreeView issue tracker.

!!!!!!! IT IS BAD SECURITY PRACTICE TO EXECUTE EXCEL MACROS FROM SOURCES YOU DON'T TRUST !!!!!!
This tool assumes the user trusts the Excel file, its macro and the HTML files produced.
Do not execute Excel macros from an untrusted source. The .bas file is the export of the VBA Macro for review before use.
After review, you can then copy and paste it in the Excel file before allowing macro execution in case you don't trust it.
If your environment does not allow Excel Macro execution, contact us to elaborate other ways of generating JSON from the Excel file (python script for ex).

If you intend to use the HTML template in a MVC web like architecture, you'll need to consider the HTML injection risk via malevolent modification of the input JSON.